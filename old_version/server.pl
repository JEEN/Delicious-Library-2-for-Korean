use strict;
use warnings;
use HTTP::Engine;
use HTTP::Engine::Middleware;
use File::Spec;
use FindBin;
use Template;
use WebService::Aladdin;
use Encode qw/encode decode/;
use Mac::AppleScript qw(RunAppleScript);

my $mw = HTTP::Engine::Middleware->new;
$mw->install('HTTP::Engine::Middleware::Static' => {
    regexp => qr/^.*(\.txt|\.html|\.js|\.css|\.png)$/,
    docroot => File::Spec->catdir($FindBin::Bin, qw(public_html)),
});

HTTP::Engine->new(
    interface => {
      module => 'ServerSimple',
      args => {
        host => 'localhost',
        port => '8080',
      },
      request_handler => $mw->handler(\&handler),
    },
)->run;

sub handler {
  my $req = shift;
  my $path = $req->uri->path;
 
  my $vars = {
	req => $req,
  };

  if ($path =~ /input/) {
	warn $req->param('isbn');
	my $aladdin = WebService::Aladdin->new;
	my $res = $aladdin->search($req->param('isbn'), { Cover => "Big" });
	my $result = $res->{items}->[0];
	return _error() unless $result;
	process_res($result);
	return _error() if $@;
	return _res('{ is_ok: 1 }');
  } else {
  	my $t = Template->new();
  	my $file = "tt/default.html";
  	my $body; $t->process($file, $vars, \$body);
  	return HTTP::Engine::Response->new( body => $body );
  }
}

sub process_res {
	my ($result) = @_;

	my $param = {
		book_name => $result->{title},
		authors   => $result->{author},
		genres    => $result->{categoryName},
		image     => $result->{cover},
		publisher => $result->{publisher},
		isbn      => $result->{isbn},
		features  => $result->{description},
		notes     => $result->{content},
		url       => $result->{link},
		pages     => $result->{itemPage},
		price     => $result->{priceStandard},
	};
	
	$param = _filter($param);
	return __run_apple_script($param);
}

sub _filter {
	my ($param) = @_;

	$param->{$_} = Encode::decode('utf8', $param->{$_}) for keys %{ $param };
	$param->{features} =~ s/"/'/g;
	$param->{notes} =~ s/"/'/g;
    $param->{notes} =~ s/<br\s?\/?>/\n/g;
	$param->{notes} =~ s/<\/?[a-zA-Z]*\s?[a-zA-Z]*=[^>]*?\s*\/?>//g;
	$param;
}

sub __run_apple_script {
	my ($param) = @_;

	my $script = <<SCRIPT;
tell first document of application "Delicious Library 2"
set selected media to make new book with properties {name:"$param->{book_name}", creators:"$param->{authors}", publisher:"$param->{publisher}", genres:"$param->{genres}", cover URL:"$param->{image}", isbn:"$param->{isbn}", price:"$param->{price}", associated URL:"$param->{url}", features:"$param->{features}", notes:"$param->{notes}"}
end tell
SCRIPT

	return RunAppleScript($script);
}

sub _res {
	return HTTP::Engine::Response->new( body => shift );
}

sub _error {
	return HTTP::Engine::Response->new( status => 404, body => "Not Found" );
}
