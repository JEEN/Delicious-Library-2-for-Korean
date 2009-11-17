package DL2::Response;
use strict;
use warnings;
use DL2::Filter;
use Carp;
use Data::Dumper;

sub new {
   my ($class, $res) = @_;

   bless { _res => DL2::Filter->process($res) }, $class;
}

sub has_item {
   my ($class) = @_;

   $class->item ? 1 : 0;
}

sub item {
   my ($class) = @_;

   $class->{_res};
}

1;