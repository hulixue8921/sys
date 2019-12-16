#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 1.pl
#
#        USAGE: ./1.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/16/2019 02:28:11 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Encode;

my $y="胡";

sub p {
    my $y=shift;
Encode::_utf8_off($y);
    my $x={$y => 1};
    say keys %$x;

}
&p($y);
say $y;


