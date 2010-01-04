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

use LWP::UserAgent;
use HTTP::Cookies;
use URI;
use Time::HiRes qw(usleep gettimeofday tv_interval);
use Digest::SHA qw(hmac_sha256_base64);
use URI::Escape qw(uri_escape);

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
        port => '80',
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

  my $response;
  my $amazon_look_up_pat1 = qr#http://www\.amazon\.[a-z.]+/exec/obidos/ASIN/(?<isbn>\d{10})/ref=nosim/deliciousmons-\d{2}#;
  my $amazon_look_up_pat2 = qr#http://www.amazon.com/gp/reader/(?<isbn>\d{10})#;

  if ($path =~ m{^/onca/xml}) {
      ( my $isbn ) = $req->uri->query =~ m{.*ItemId=(\d+)};

      if( $isbn =~ /^89\d{8}$/ ) {
          $response = aladdin_proxy($isbn);
      } else {
          $response = amazon_proxy($isbn);
      }

      return HTTP::Engine::Response->new( body => $response );
  } elsif ($req->uri =~ $amazon_look_up_pat1 or $req->uri =~ $amazon_look_up_pat2)  {
      my $isbn = $+{isbn};
      if( $isbn =~ /^89\d{8}$/ ) {
          my $ua = LWP::UserAgent->new;
          $ua->agent("Library/2.2 CFNetwork/454.4 Darwin/10.0.0 (i386) (MacBook1%2C1)");

          my $response = $ua->get('http://www.aladdin.co.kr/shop/wproduct.aspx?ISBN=' . $isbn);
          return HTTP::Engine::Response->new( body => $response->content );
      } else {
          my $ua = LWP::UserAgent->new;
          $ua->agent("Library/2.2 CFNetwork/454.4 Darwin/10.0.0 (i386) (MacBook1%2C1)");

          my $response = $ua->get($req->uri);
          return HTTP::Engine::Response->new( body => $response->content );
      }
  } else {
      return HTTP::Engine::Response->new( body => $req->uri );
  }
}

sub secret_key {
    return 'Ph2xMo/2Kmk3CVA5b8pTro2BKJ5nSOtY7am3jw5u';
}

sub token {
    return '19E64160MR69H1K90QG2';
}

sub aladdin_proxy {
    my ($isbn) = @_;
    my $aladdin = WebService::Aladdin->new;
    my $res = $aladdin->search($isbn, { Cover => 'Big' });
    my $vars = $res->{items}->[0];
    return undef unless $vars;

    $vars = process_res($vars);
    return undef if $@;

    my $t = Template->new();
    my $file = 'tt/proxy.xml';
    my $body; $t->process($file,$vars,\$body);
    return $body;
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

        return $param;
}

sub _filter {
	my ($param) = @_;

	$param->{$_} = Encode::decode('utf8', $param->{$_}) for keys %{ $param };
        $param->{url} = _url_encode($param->{url});
        $param->{image} = _url_encode($param->{image});
        $param->{ean} = '978' . $param->{isbn};
	$param->{features} =~ s/"/'/g;
	$param->{notes} =~ s/"/'/g;
        $param->{notes} =~ s/<br\s?\/?>/\n/g;
	$param->{notes} =~ s/<\/?[a-zA-Z]*\s?[a-zA-Z]*=[^>]*?\s*\/?>//g;

	return $param;
}

sub _url_encode {
    my ($url) = @_;

    my ($host,$query) = $url =~ m{(http://.*/)([^ ]+)$}i;
    return $host . uri_escape($query,"^A-Za-z0-9\-_.~");
}

sub amazon_proxy {
    my ($isbn) = @_;

    my %param = (
                    AWSAccessKeyId      => token(),
                    AssociateTag        => 'deliciousmons-20',
                    ItemId              => $isbn,
                    ItemPage            => '1',
                    Operation           => 'ItemLookup',
                    ResponseGroup       => 'Small,ItemAttributes,Tracks,Images,BrowseNodes,OfferSummary,EditorialReview,Reviews',
                    ReviewSort          => '-HelpfulVotes',
                    Service             => 'AWSECommerceService',
                    Version             => '2009-07-01',
            );

# Access webservices.amazon.com by Ip address 
    my $uri = URI->new('http://72.21.211.36/onca/xml');
    $uri->query_form(%param);

    my $ua = LWP::UserAgent->new;
    $ua->agent("Library/2.2 CFNetwork/454.4 Darwin/10.0.0 (i386) (MacBook1%2C1)");

    my $res = $ua->get(_sign_request($uri));

    return $res->content;
}


# $self->_sign_request( URI )
#
# Takes a URI object that corresponds to a Net::Amazon::Request
# adds the required Timestamp and Signature parameters, and returns it
# See http://docs.amazonwebservices.com/AWSECommerceService/2009-03-31/DG/Query_QueryAuth.html
sub _sign_request {
    my ($uri) = @_;
# This assumes no duplicated keys. Safe assumption?
    my %query = $uri->query_form;
    my @now = gmtime;
    $query{Timestamp} ||= sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ',$now[5]+1900,$now[4]+1,@now[3,2,1,0]);
    my $qstring = join '&', map {"$_=". uri_escape($query{$_},"^A-Za-z0-9\-_.~")} sort keys %query;
# Use chr(10), not "\n" which varies by platform
    my $signme = join chr(10),"GET",$uri->host,$uri->path,$qstring;
    my $sig = hmac_sha256_base64($signme, secret_key());
# Digest does not properly pad b64 strings
    $sig .= '=' while length($sig) % 4;
    $sig = uri_escape($sig,"^A-Za-z0-9\-_.~");
    $qstring .= "&Signature=$sig";
    $uri->query( $qstring );
    return $uri;
}

