package DL2::JSON;
use strict;
use Carp;
use JSON::XS ();
use Encode ();
use overload ();

sub roundtrip {
	my ($class, $data) = @_;
	$class->decode($class->encode($data));
}

sub decode {
	my $class = shift;
	my ($str, $encode_utf8) = @_;
	
	$str = Encode::encode_utf8($str) if $encode_utf8;
	JSON::XS::decode_json($str);
}

sub encode {
	my $class = shift;
	my ($stuff) = @_;
	
	local *UNIVERSAL::TO_JSON = sub {
		my $obj = shift;
		if (my $method = overload::Method($obj, q(""))) {
			return $obj->$method();
		} else {
			croak sprintf qq(Can't locate object method "TO_JSON" via package "%s"), ref $obj;
		}
	};
	
	JSON::XS->new->allow_blessed->conver_blessed->ascii->encode($stuff);
}

1;