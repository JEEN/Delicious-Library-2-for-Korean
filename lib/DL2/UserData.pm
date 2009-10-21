package DL2::UserData;
use Any::Moose;
use Any::Moose 'X::Types::Path::Class' => [ 'Dir' ];

has 'base' => (
	is => 'rw',
	isa => Dir,
	coerce => 1,
	default => sub { Path::Class::Dir->new($ENV{HOME}, '.dl2') },
);

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub path_to {
	my ($self, @path) = @_;
	
	my $base = $self->base;
	$base->mkpath(0, oct 777) unless -e $base;
	
	if (@path > 1) {
		my $file = pop @path;
		return $self->path_to_dir(@path)->file($file);
	} else {
		return $base->file($path[0]);
	}
}

sub path_to_dir {
	my ($self, @path) = @_;
	
	my $dir = $self->base->subdir(@path);
	$dir->mkpath(0, oct 777) unless -e $dir;
	
	return $dir;
}

1;
