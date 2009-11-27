package DL2::Filter;
use strict;
use warnings;
use Encode;

sub process {
   my ($class, $result) = @_;
   
   return unless $result;

   my $param = {
	title => $result->{title},
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
	
   my $info = {};
   $info->{$_} = Encode::decode('utf8', $param->{$_}) for keys %{ $param };
   $info->{features} =~ s/"/'/g;
   $info->{notes} =~ s/"/'/g;
   $info->{notes} =~ s/<br\s?\/?>/\n/g;
   $info->{notes} =~ s/<\/?[a-zA-Z]*\s?[a-zA-Z]*=[^>]*?\s*\/?>//g;
   $info;
}

1;
