#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

my $base_dir;
BEGIN {
	$base_dir = "$FindBin::Bin/..";
}

use lib "$base_dir/extlib";
use local::lib "$base_dir/cpanlib";
use lib "$base_dir/lib", "$base_dir/extlib";

use DL2::CLI::Server;

DL2::CLI::Server->new_with_options( root => "$base_dir/root")->run();

__END__