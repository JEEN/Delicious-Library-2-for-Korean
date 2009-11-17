package DL2::Server;
use strict;
use warnings;
use HTTP::Engine;
use DL2::Request;
use DL2::Response;
use DL2::Updater;

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
		module => 'ServerSimple',
		args => {
		   host => 'localhost',
		   port => '8080',
		},
		request_handler => sub { my $req = shift; $class->handler($req); },
	});
	
  $engine->run;
}

sub handler {
   my ($class, $req) = @_;

   my $path = $req->uri->path;

   if ($path =~ /bookmarklet\/add/) {
	my $isbn = $req->param('id');
	warn $isbn;
	my $request = DL2::Request->new({ keyword => $isbn });
	my $res = DL2::Response->new( $request->get_item );
	if ($res->has_item) {
	    eval {
		DL2::Updater->update($res->item);
	    };
	    return $class->res_error($isbn) if $@;
	    return $class->response($res->item);
	}
    }
}

sub response {
    my ($class, $item) = @_;

    my $isbn = $item->{isbn};
    my $author = $item->{authors};
    my $title = $item->{title};
    my $html = <<HTML;
<html><body>
<script>alert("Added a Item into Delicious Library 2---\\nISBN: $isbn \\n"+ "Title: $title \\n"+ "Author: $author \\n"+ "---");</script>
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