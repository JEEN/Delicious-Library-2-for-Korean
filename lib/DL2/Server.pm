package DL2::Server;
use strict;
use warnings;
use HTTP::Engine;
use DL2::Request;
use DL2::Response;
use DL2::Updater;
use DL2::ISight::Handler;
use AnyEvent;
use Coro;
use Coro::AnyEvent;

sub bootstrap {
   my ($class) = @_;

   my $exit = sub { CORE::die('caught signal') };
   eval {
     local $SIG{INT}  = $exit;
     local $SIG{QUIT} = $exit;
     local $SIG{TERM} = $exit;
     $class->run;
   };
}

sub run {
   my ($class) = @_;
 
   my $engine = HTTP::Engine->new(
	interface => {
		module => 'AnyEvent',
		args => {
		   host => '127.0.0.1',
		   port => '8080',
		},
		request_handler => $class->make_request_handler,
	},
   );
	
   $engine->run;
   {
       my $t; $t = AnyEvent->timer(
           after => 0,
           interval => 1,
           cb => sub {
               scalar $t;
               schedule;
           },
       );
   }
  {
     my $isight = DL2::ISight::Handler->new;
     $isight->run;
   }

   AnyEvent->condvar->recv;
}

sub make_request_handler {
   my ($class) = @_;
 
   my $callback = unblock_sub {
	my ($req, $cb) = @_;
	my $res = $class->handle_request($req);
	$cb->($res);
   };

   return $callback;
}

sub handle_request {
   my ($class, $req) = @_;

   my $path = $req->uri->path;

   if ($path =~ /bookmarklet\/add/) {
	my $isbn = $req->param('id');
	my $request = DL2::Request->new({ keyword => $isbn });
	my $res = DL2::Response->new( $request->get_item );

	unless ($res->has_item) {
	   return $class->res_error($isbn);
	}
	    
	eval {
	   DL2::Updater->update($res->item);
	};
	return $class->res_error($isbn) if $@;
	return $class->response($res->item);
	
   } elsif ($path =~ /is_alive/) {

       return $class->response_alive();

   }
   return HTTP::Engine::Response->new( status => 200, body => 'Hello, DL2 Server!!' );
}

sub response_alive {
    my ($class) = @_;

    return HTTP::Engine::Response->new(
	headers => {
		'Content-Type' => qq{text/javascript; charset=utf-8},	
	},
	body => 'is_server_on=1;',
	status => 200,
    );
}

sub response {
    my ($class, $item) = @_;

    my $isbn = $item->{isbn};
    my $author = $item->{authors};
    my $title = $item->{title};
    my $html = <<HTML;
<html><body>
<script>alert("Added a Item into Delicious Library 2\\n---\\nISBN: $isbn");</script>
</body></html>
HTML
    return HTTP::Engine::Response->new(
	headers => {
		'Content-Type' => qq{text/html; charset=utf-8},
	},
	body => $html );
}

sub res_error {
    my ($class, $code) = @_;

    my $html = <<HTML;
<html><body>
<script>alert("can not found item by $code");</script>
</body></html>
HTML
    return HTTP::Engine::Response->new( status => '200', body => $html );

}
1;
