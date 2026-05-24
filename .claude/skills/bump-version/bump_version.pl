#!/usr/bin/env perl
use strict;
use warnings;
use File::Find ();

my $dry_run = 0;
my $date_arg;
my @args;
while (@ARGV) {
    my $a = shift @ARGV;
    if    ($a eq '--dry-run' || $a eq '-n') { $dry_run = 1 }
    elsif ($a eq '--date')                  { $date_arg = shift @ARGV }
    elsif ($a =~ /\A--date=(.+)\z/)         { $date_arg = $1 }
    else                                     { push @args, $a }
}

my $new_version = shift @args;
defined $new_version && length $new_version
    or die "Usage: $0 [--dry-run] [--date YYYY-MM-DD] <new-version>\n"
         . "  e.g. $0 3.104\n"
         . "       $0 --date 2026-06-01 3.104\n";

$new_version =~ /\A[0-9]+\.[0-9]+(?:_[0-9]+)?\z/
    or die "Invalid version '$new_version' (expected e.g. 3.104 or 3.104_01)\n";

-d 'lib' or die "No lib/ directory in $ENV{PWD} -- run from repo root.\n";

my $release_date = format_release_date($date_arg);

my @pm_files;
File::Find::find(
    sub { push @pm_files, $File::Find::name if /\.pm\z/ && -f $_ },
    'lib',
);
@pm_files = sort @pm_files;

my ($changed, $already, @no_match);

for my $file (@pm_files) {
    my $content = slurp($file);
    my $orig    = $content;

    my $hits = $content =~ s{
        ^( \s* our \s+ \$VERSION \s* = \s* ['"] )
        [^'"]+
        ( ['"] )
    }{$1$new_version$2}mxg;

    if (!$hits) {
        push @no_match, $file;
        next;
    }

    if ($content eq $orig) {
        $already++;
        print "  = $file (already $new_version)\n";
        next;
    }

    spew($file, $content) unless $dry_run;
    $changed++;
    print "  " . ($dry_run ? "[dry] " : "") . "updated $file\n";
}

# Update the POD =head1 VERSION prose line in lib/Template.pm.
my $template_pm = 'lib/Template.pm';
my $pod_status  = 'not found';
if (-f $template_pm) {
    my $content = slurp($template_pm);
    my $orig    = $content;

    my $pod_hits = $content =~ s{
        ^Template\s+Toolkit\s+version\s+
        [0-9]+\.[0-9]+(?:_[0-9]+)?
        ,\s+released\s+on\s+
        [^\n.]+
        \.\s*$
    }{Template Toolkit version $new_version, released on $release_date.}mx;

    if (!$pod_hits) {
        $pod_status = "no match for POD version line";
    }
    elsif ($content eq $orig) {
        $pod_status = "already $new_version / $release_date";
    }
    else {
        spew($template_pm, $content) unless $dry_run;
        $pod_status = ($dry_run ? "would update" : "updated")
                    . " ($new_version, $release_date)";
    }
}

print "\nPOD =head1 VERSION in $template_pm: $pod_status\n";

# Regenerate README.md from the updated POD.
my $readme_status;
if ($dry_run) {
    $readme_status = "[dry] would regenerate via pod2markdown $template_pm > README.md";
}
else {
    my $rc = system("pod2markdown $template_pm > README.md");
    $readme_status = $rc == 0
        ? "regenerated via pod2markdown"
        : "FAILED (pod2markdown exited with rc=$rc)";
}
print "README.md: $readme_status\n";

print "\n";
print "Scanned ", scalar(@pm_files), " .pm file(s) under lib/.\n";
print($dry_run ? "Would update" : "Updated", " $changed file(s) to $new_version.\n");
print "$already file(s) already at $new_version.\n" if $already;
if (@no_match) {
    print "\nSkipped (no \$VERSION declaration):\n";
    print "  $_\n" for @no_match;
}
exit 0;

sub slurp {
    my ($f) = @_;
    open my $fh, '<', $f or die "open $f: $!";
    local $/;
    return scalar <$fh>;
}

sub spew {
    my ($f, $data) = @_;
    open my $fh, '>', $f or die "write $f: $!";
    print $fh $data;
}

sub format_release_date {
    my ($iso) = @_;
    my @months = qw(January February March April May June
                    July August September October November December);
    my ($y, $m, $d);
    if (defined $iso) {
        ($y, $m, $d) = $iso =~ /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
            or die "Invalid --date '$iso' (expected YYYY-MM-DD)\n";
    }
    else {
        my @t = localtime;
        ($y, $m, $d) = ($t[5] + 1900, $t[4] + 1, $t[3]);
    }
    $m >= 1 && $m <= 12 or die "Invalid month in date: $m\n";
    return sprintf("%s %d %d", $months[$m - 1], $d + 0, $y);
}
