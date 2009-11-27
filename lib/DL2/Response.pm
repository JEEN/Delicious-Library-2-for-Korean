package DL2::Response;
use strict;
use warnings;
use DL2::Filter;
use Carp;
use Data::Dumper;

sub new {
   my ($class, $res) = @_;

   my $self = bless {}, $class;
   $self->init($res);
   $self;
}

sub init {
    my ($class, $res) = @_;

    my $result = DL2::Filter->process($res);
    return unless $result;
    $class->_set_attr('res', $result);
}

sub _set_attr {
    my ($class, $key, $val) = @_;

    $class->{$key} = $val;
}

sub _get_attr {
    my ($class, $key) = @_;

    return unless $class->{$key};
    $class->{$key};
}

sub has_item {
   my ($class) = @_;

   $class->item ? 1 : 0;
}

sub item {
   my ($class) = @_;

   $class->_get_attr('res');
}

1;
