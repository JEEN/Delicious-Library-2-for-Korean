use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use AnyEvent::ReverseHTTP;
use DL2::Controller;
use Data::Dumper;
my $name = $ARGV[0];

my $guard = AnyEvent::ReverseHTTP->new(
	label => $name,
	token => '-',
	on_request => \&handle_request,
)->connect;

AnyEvent->condvar->recv;

sub handle_request { 
  my $req = shift;
 
  my $uri = $req->uri;
  my ($code) = $uri =~ /q=(.+)$/;
  
  if ($code) {
   my $res = DL2::Controller->new({ keyword => $code });
   $res->update;
   if (!$res->is_error) { 
     printf("%s => %s\n", $code, $res->get_item->{title});
   }
  }
}