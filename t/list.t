#============================================================= -*-perl-*-
#
# t/list.t
#
# Tests list references as variables, including pseudo-methods such
# as first(), last(), etc.
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
use Template::Constants qw( :status );
$^W = 1;

use Template::Parser;
$Template::Test::DEBUG = 0;

# sample data
my ($a, $b, $c, $d, $e, $f, $g, $h, $i, $j, $k, $l, $m, 
    $n, $o, $p, $q, $r, $s, $t, $u, $v, $w, $x, $y, $z) = 
	qw( alpha bravo charlie delta echo foxtrot golf hotel india 
	    juliet kilo lima mike november oscar papa quebec romeo 
	    sierra tango umbrella victor whisky x-ray yankee zulu );

my $data = [ $r, $j, $s, $t, $y, $e, $f, $z ];
my $vars = { 
    'a'  => $a,
    'b'  => $b,
    'c'  => $c,
    'd'  => $d,
    'e'  => $e,
    data => $data,
    days => [ qw( Mon Tue Wed Thu Fri Sat Sun ) ],
    wxyz => [ { id => $z, name => 'Zebedee', rank => 'aa' },
	      { id => $y, name => 'Yinyang', rank => 'ba' },
	      { id => $x, name => 'Xeexeez', rank => 'ab' },
	      { id => $w, name => 'Warlock', rank => 'bb' }, ]
};

my $config = {};

test_expect(\*DATA, $config, $vars);


__DATA__

#------------------------------------------------------------------------
# GET 
#------------------------------------------------------------------------
-- test --
[% data.0 %] and [% data.1 %]
-- expect --
romeo and juliet

-- test --
[% data.first %] - [% data.last %]
-- expect --
romeo - zulu

-- test --
[% data.size %] [% data.max %]
-- expect --
8 7

-- test --
[% data.join(', ') %]
-- expect --
romeo, juliet, sierra, tango, yankee, echo, foxtrot, zulu

-- test --
[% data.reverse.join(', ') %]
-- expect --
zulu, foxtrot, echo, yankee, tango, sierra, juliet, romeo

-- test --
[% data.sort.reverse.join(' - ') %]
-- expect --
zulu - yankee - tango - sierra - romeo - juliet - foxtrot - echo

-- test --
[% FOREACH item = wxyz.sort('id') -%]
* [% item.name %]
[% END %]
-- expect --
* Warlock
* Xeexeez
* Yinyang
* Zebedee

-- test --
[% FOREACH item = wxyz.sort('rank') -%]
* [% item.name %]
[% END %]
-- expect --
* Zebedee
* Xeexeez
* Yinyang
* Warlock

-- test --
[% FOREACH n = [0..6] -%]
[% days.$n +%]
[% END -%]
-- expect --
Mon
Tue
Wed
Thu
Fri
Sat
Sun

-- test --
[% data = [ 'one', 'two', data.first ] -%]
[% data.join(', ') %]
-- expect --
one, two, romeo
