package DL2::Request;
use strict;
use warnings;
use WebService::Aladdin;

sub new { 
   my ($class, $param) = @_;

   my $aladdin = WebService::Aladdin->new();
   bless { _service => $aladdin, _param => $param }, $class;   
}

sub service {
   $_[0]->{_service};
}

sub param { 
   $_[0]->{_param};
}

sub get_item {
   my ($class) = @_;

   my $res = $class->service->search($class->param->{keyword}, { Cover => 'Big' });
   $res->{items}->[0];
}

sub get_items {
   my ($class) = @_;

=for comment
   my @array;
   while(my $data = ItemType->get($item_id)) {
      my $info = DL2::Filter->process($data);  
      push @array, $info;
   }
   return [ @array ];
=cut

}

1;
