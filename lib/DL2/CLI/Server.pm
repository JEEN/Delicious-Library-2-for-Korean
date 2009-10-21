package DL2::CLI::Server;
use Any::Moose;
use Any::Moose 'X::Types::Path::Class' => [qw(File Dir)];
use DL2::Server;
use Pod::Usage;
use YAML::XS;
use DL2::UserData;
with any_moose('X::Getopt'),
	 any_moose('X::ConfigFromFile');
	
has '+configfile' => (
	default => DL2::UserData->new->path_to('config.yaml')->stringify,
);

has 'root' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'r',
	is => 'rw',
	isa => Dir,
	required => 1,
	coerce => 1,
	default => sub { Path::Class::Dir->new('root')->absolute },
);

has 'user_data' => (
	is => 'rw',
	isa => 'DL2::UserData',
	required => 1,
	default => sub { DL2::UserData->new },
);

has 'net_server' => (
	traits => [ 'Getopt' ],
	is => 'rw',
	isa => 'Str',
	required => 0,
);

has 'host' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'h',
	is => 'rw',
	isa => 'Str',
	default => sub { $^O eq 'darwin' ? '::' : '0.0.0.0'},
);

has 'port' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'p',
	is => 'rw',
	isa => 'Int',
	default => '10010',
	required => 1,
);

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
);

has 'help' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'h',
	is => 'rw',
	isa => 'Bool',
	default => 0,
);

has 'access_log' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'a',
	is => 'rw',
	isa => File,
	required => 1,
	lazy => 1,
	coerce => 1,
	builder => 'build_access_log',
);

has 'error_log' => (
	traits => [ 'Getopt' ],
	cmd_aliases => 'e',
	is => 'rw',
	isa => File,
	required => 1,
	lazy => 1,
	coerce => 1,
	builder => 'build_error_log',
);

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub build_access_log { shift->user_data->path_to('logs', 'access_log.log') }
sub build_error_log { shift->user_data->path_to('logs', 'error_log.log') }

sub get_config_from_file {
	my ($class, $file) = @_;
	
	if (-f $file) {
		return YAML::XS::LoadFile($file);
	} else {
		return {};
	}
}

sub run {
	my $self = shift;
	if ($self->help) {
		pod2usage(
			-input => (caller(0))[1],
			-exitval => 1,
		);
	}

	DL2::Server->bootstrap({
		host => $self->host,
		port => $self->port,
		net_server => $self->net_server,
		root => $self->root,
		error_log => $self->error_log,
		access_log => $self->access_log,
		debug => $self->debug,
		user_data => $self->user_data,
	});
}

1;
