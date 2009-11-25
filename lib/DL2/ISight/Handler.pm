package DL2::ISight::Handler;
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Handle;
use Carp;
use DL2::Request;
use DL2::Response;
use DL2::Updater;

sub new { 
  my ($class) = shift;
  my %args = @_;	

  my $file = $args{file} || '';

  my $self = bless { 
	handle => sub {}, 
	file => $file,
	on_eof => sub {},
	flag => 0,
  }, $class;

  $self->{fh} = $self->get_fh();
  $self;
}

sub run {
  my ($class) = @_;

  $class->{handle} = $class->create_handle();
}

sub get_fh {
  my ($class) = @_;

  my $file = $class->{file} || $ENV{HOME} . "/Library/Application Support/Delicious Library 2/Scanned UPCs Log.txt";
  open my $fh, '<', $file or croak "Do you rellay have Delicious Library 2?";  
  return $fh;
}

sub handle {
   my $class = shift;
   $class->{handle};
}

sub create_handle {
   my ($class) = @_;

   my $hdl; $hdl = AnyEvent::Handle->new(
	fh => $class->{fh},
	on_error => sub {
	   $hdl->destroy;
	   undef $hdl;
	   $hdl = $class->create_handle();
	},
	on_eof => sub {
	   $hdl->destroy;
	   undef $hdl;
	   $class->{flag} = 1;
	   $hdl = $class->create_handle();
	},
	on_read => sub {
	   my $hdl = shift;
	
	   $hdl->push_read(line => sub {
	     my ($hdl, $code) = @_;
	     return unless $class->{flag};

	     my $request = DL2::Request->new({ keyword => $code });                                       
	     my $res = DL2::Response->new( $request->get_item() );                                        
	     if ($res->has_item) {                                                                        
	       eval {                                                                                    
	         DL2::Updater->update($res->item);                                                       
	       };                                                                                        
	       warn $@ if $@;                                                                            
	     }
	   });
	},
   );
   $hdl;
}

1;
