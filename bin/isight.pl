#!/usr/bin/env perl
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Handle;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DL2;
use DL2::Request;
use DL2::Response;
use DL2::Updater;

$| = 1;

my $file = $ENV{HOME} . "/Library/Application Support/Delicious Library 2/Scanned UPCs Log.txt";

open my $fh, '<', $file or die "Do you rellay have Delicious Library 2?";
my $cv = AE::cv;

my $handle = create_handle();
my $flag = 0;
my $cache = {};

sub create_handle {
    new AnyEvent::Handle
        fh => $fh,
        on_error => sub {
            my ($handle, $fatal, $message) = @_;
            $handle->destroy;
            undef $handle;
            $cv->send("$fatal: $message");
    	},
    	on_eof => sub {
	    $handle->destroy;
	    undef $handle;
	    unless ($flag) { print "Start to scan your Items!!\n" }
            $flag = 1;
	    $handle = create_handle();
    	},
    	on_read => sub {
	    my $handle = shift;
	    $handle->push_read(line => sub {
	    	my ($handle, $code) = @_;
  	    	if ($flag && !$cache->{$code}) {
		   my $request = DL2::Request->new({ keyword => $code });
		   my $res = DL2::Response->new( $request->get_item() );
		   if ($res->has_item) {
		      eval {
		      	DL2::Updater->update($res->item);	
		      };
		      warn $@ if $@;
		      print sprintf("%s => %s\n", $code, $res->item->{title});
		   }
		   $cache->{$code} = 1;
            	}
       		})
    	};
}

$cv->recv;