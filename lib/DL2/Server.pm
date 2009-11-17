package DL2::Server;
use Any::Moose;
use HTTP::Engine;
use Path::Class;

use DL2::Log;

has 'conf' => ( is => 'rw');

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub bootstrap {
	my ($class, $conf) = @_;
	
	my $self = $class->new(conf => $conf );
		
	my $exit = sub { CORE::die "caught signal" };
	eval {
		local $SIG{INT} = $exit if !$ENV{DL2_DEBUG};
		local $SIG{QUIT} = $exit;
		local $SIG{TERM} = $exit;
		$self->run;
	};
	warn $@;
	DL2::Log->log( error => $@);
}


sub BUILD {
    my $self = shift;

    my $conf = $self->conf;
    local $ENV{DL2_ACCESS_LOG} = 
        $ENV{DL2_ACCESS_LOG} || $conf->{access_log} || 'access.log';
    local $ENV{DL2_ERROR_LOG} = 
        $ENV{DL2_ERROR_LOG} || $conf->{error_log} || 'error.log';
    local $ENV{DL2_DEBUG} = 
        $ENV{DL2_DEBUG} || $conf->{debug};

    DL2::Log->init();

    return $self;
}

sub run {
	my $self = shift;
	
	DL2::Log->log( debug => "Initializing with HTTP::Engine version $HTTP::Engine::VERSION" );
	my $engine = HTTP::Engine->new(
		interface => {
			module => 'ServerSimple',
			args => {
				host => 'localhost',
				port => '8080',
			},
			request_handler => sub { $self->handle_request(@_) },
		},
	);

	my $owner_name = $self->owner_name;
	
	$engine->run;
}

sub owner_name {
    my $self = shift;
    my $user = getlogin || getpwuid($<) || $ENV{USER};
    return eval { (getpwnam($user))[6] } || $user;
}

sub default_root {
	my ($self, $req) = @_;
	return "/static/html/index.html";
}

sub handle_request {
	my ($self, $req) = @_;
	
	my $path = $req->path;
	
	my $res = HTTP::Engine::Response->new;
	$path = $self->default_root($req) if $path eq '/';

	eval {
	  if ($path =~ s!^/static/!!) {
		$self->serve_static_file($path, $req, $res);
	  }
	};
	
	$res->status('200');
	$res->body('WTF?');
	
        DL2::Log->log_request($req, $res);

    	return $res;
}

sub dispatch {
	my ($self, $path, $req, $res) = @_;
	
	my @classes = split '/', $path;

        my $class = pop @classes;
}

sub serve_static_file {
	my ($self, $path, $req, $res) = @_;
	
	my $root = $self->conf->{root};
	my $file = ufile($root, 'static', $path);
	
	$self->do_serve_statiac($file, $req, $res);
}

sub do_serve_static {
	my ($self, $file, $req, $res) = @_;
	
	my $exists = -e $file;
	my $is_dir = -d _;
	my $is_readble = -r _;
	
	if ($exists) {
		if ($is_dir || !$is_readble) {
			die "Forbidden";
		}
		my $size = -s _;
		my $mtime = (stat(_))[9];
		my $ext = ($file =~ /\.(\w+)$/)[0];
		$res->content_type( MIME::Types->new->mimeTypeOf($ext) || "text/plain" );
		
		if (my $ims = $req->headers->header('If-Modified-Since')) {
			my $time = HTTP::Date::str2time($ims);
			if ($mtime <= $time) {
				$res->status(304);
				return;
			}
		}
		open my $fh, "<:raw", $file or die "$file: $!";
		$res->headers->header('Last-Modified' => HTTP::Date::time2str($mtime));
		$res->headers->header('Content-Length' => $size );
		$res->body($fh);
	} else {
		die "Not found";
	}
}

1;
