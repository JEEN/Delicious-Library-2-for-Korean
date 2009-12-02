package DL2::Controller;
use strict;
use warnings;
use WebService::Aladdin;
use DL2::Filter;
use DL2::Updater;
use DL2::Schema;
use Carp;

sub new { 
   my ($class, $param) = @_;

   my $self = bless {}, $class;
   $self->init($param);
   $self;
}

sub schema {
    my ($class, $rs) = @_;

    my $schema = DL2::Schema->connect(sprintf 'dbi:SQLite:/Users/%s/Library/Application Support/Delicious Library 2/Delicious Library Items.deliciouslibrary2', $class->owner_name);

    $schema->resultset($rs);
}

sub owner_name {
    my $self = shift;
    my $user = getlogin;
    return $user;
}


sub init {
   my ($class, $param) = @_;
 
   my $aladdin = WebService::Aladdin->new();
   my $res = $aladdin->search($param->{keyword}, { Cover => 'Big'});
   $class->{result} = $res;
   $class->{key} = $param->{keyword};
}

sub has_item {
    my ($class) = @_;
    $class->get_item ? 1 : 0;
}

sub get_item {
   my ($class) = @_;

   DL2::Filter->process($class->{result}->{items}->[0]);
}

sub get_items {
   my ($class) = @_;

   $class->{result}->{items};
}

sub update {
   my ($class) = @_;

   Carp::croak("can not find item info") unless $class->has_item;

   eval { 
	DL2::Updater->update($class->get_item);
   };
   if ($@) {
      	$class->{_error} = @_;
   }
}

sub is_error {
   my ($class) = @_;

   $class->{_error} ? 1 : 0; 
}

1;
