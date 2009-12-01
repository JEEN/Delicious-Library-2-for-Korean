#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Term::ReadLine;
use DL2::Controller;

my $term = Term::ReadLine->new("Delicious Library 2 Shell");

while(defined(my $code = $term->readline("isbn> "))) {
   my $res = DL2::Controller->new({ keyword => $code });
   $res->update;
   if (!$res->is_error) { 
     printf("%s => %s\n", $code, $res->get_item->{title});
   }
}
