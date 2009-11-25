#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DL2::ISight::Handler;

$| = 1;

my $cv = AE::cv;

my $isight = DL2::ISight::Handler->new;
$isight->run;
$cv->recv;
