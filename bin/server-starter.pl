#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
my $base_dir;
BEGIN {
    $base_dir = "$FindBin::Bin/..";
}

use FindBin;
use lib "$base_dir/extlib"; # to load local::lib
use local::lib "$base_dir/cpanlib";
use lib "$base_dir/lib", "$base_dir/extlib"; # to prefer extlib for URI::Fetch etc.
use DL2::Server;

DL2::Server->bootstrap();
