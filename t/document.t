#============================================================= -*-perl-*-
#
# t/document.t
#
# Test the Template::Document module.
#
# Written by Andy Wardley <abw@kfs.org>
#
# Copyright (C) 1996-2000 Andy Wardley.  All Rights Reserved.
# Copyright (C) 1998-2000 Canon Research Centre Europe Ltd.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id$
#
#========================================================================

use strict;
use lib qw( ./lib ../lib );
use Template::Test;
use Template::Config;
use Template::Document;

$^W = 1;
$Template::Test::DEBUG = 0;
$Template::Document::DEBUG = 0;
my $DEBUG = 0;


#------------------------------------------------------------------------
# define a dummy context object for runtime processing
#------------------------------------------------------------------------
package Template::DummyContext;
sub new   { bless { }, shift }
sub visit { }
sub leave { }

package main;

#------------------------------------------------------------------------
# create a document and check accessor methods for blocks and metadata
#------------------------------------------------------------------------
my $doc = Template::Document->new(
    sub { my $c = shift; return "some output" },
    {
	foo => sub { return 'the foo block' },
	bar => sub { return 'the bar block' },
    },
    {
	author  => 'Andy Wardley',
	version => 3.14,
    }
);

my $c = Template::DummyContext->new();

ok( $doc );
ok( $doc->author()  eq 'Andy Wardley' );
ok( $doc->version() == 3.14 );
ok( $doc->process($c) eq 'some output' );
ok( ref($doc->block()) eq 'CODE' );
ok( ref($doc->blocks->{ foo }) eq 'CODE' );
ok( ref($doc->blocks->{ bar }) eq 'CODE' );
ok( &{ $doc->block }   eq 'some output' );
ok( &{ $doc->blocks->{ foo } } eq 'the foo block' );
ok( &{ $doc->blocks->{ bar } } eq 'the bar block' );

test_expect(\*DATA);

__END__
-- test --
# test metadata
[% META
   author = 'Tom Smith'
   version = 1.23 
-%]
version [% template.version %] by [% template.author %]
-- expect --
version 1.23 by Tom Smith
-- stop --

# test local block definitions are accessible
-- test --
[% BLOCK foo -%]
   This is block foo
[% INCLUDE bar -%]
   This is the end of block foo
[% END -%]
[% BLOCK bar -%]
   This is block bar
[% END -%]
[% PROCESS foo %]

-- expect --
   This is block foo
   This is block bar
   This is the end of block foo
