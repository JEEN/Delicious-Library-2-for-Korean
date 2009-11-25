#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Term::ReadLine;
use DL2;
use DL2::Request;
use DL2::Response;
use DL2::Updater;

my $term = Term::ReadLine->new("Delicious Library 2 Shell");

while(defined(my $code = $term->readline("isbn> "))) {
   my $request = DL2::Request->new({ keyword => $code });
   my $res = DL2::Response->new( $request->get_item() );
   if ($res->has_item) {
      eval {
      	DL2::Updater->update($res->item);	
      };
      warn $@ if $@;
      printf("%s => %s\n", $code, $res->item->{title});r
   }
}
