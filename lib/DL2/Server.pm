package DL2::Server;
use strict;
use warnings;
use HTTP::Engine;
use DL2::Controller;
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
=for comment
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
=cut
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
	my $res = DL2::Controller->new({ keyword => $isbn });
	unless ($res->has_item) {
	   return $class->res_error($isbn);
	}
        $res->update;
	return $class->res_error($isbn) if res->is_error;
	return $class->response($res->get_item);
	
   } elsif ($path =~ /export/) {
        my $item = DL2::Controller->schema('Item');
        my $rs = $item->search({ ztype => 'Book' });
        my @isbn = map { $_->zisbn } $rs->all;    
        return $class->response_export(\@isbn);
   } elsif ($path =~ /is_alive/) {

       return $class->response_alive();

   }
   return HTTP::Engine::Response->new( status => 200, body => 'Hello, DL2 Server!!' );
}

sub response_export { 
    my ($class, $isbn) = @_;

    my $html = "<html><head><title>ExportISBN</title></head><body>";

    foreach my $val (@{ $isbn }) {
	$html .= $val.'<br/>';
    }
    $html .= '</body></html>';

    return HTTP::Engine::Response->new(
	status => 200,
	body => $html,
    );
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
