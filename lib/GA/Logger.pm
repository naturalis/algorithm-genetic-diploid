package GA::Logger;

use strict;
use base 'Exporter';

our $AUTOLOAD;

our @EXPORT_OK = qw(DEBUG INFO WARN ERROR FATAL);
our %EXPORT_TAGS = ( 'levels' => [@EXPORT_OK] );

our $VERBOSE = 2; # i.e. WARN, default 
our %VERBOSE;

# singleton constructor always returns reference to same object
my $SINGLETON;
sub new {
	my $class = shift;
	if ( not $SINGLETON ) {
		$SINGLETON = bless \$class, $class;
	}
	$SINGLETON->level(@_) if @_;
	return $SINGLETON;
}

# destructor does nothing
sub DESTROY {}

# constants for log levels
sub FATAL () { 0 }
sub ERROR () { 1 }
sub WARN ()  { 2 }
sub INFO ()  { 3 }
sub DEBUG () { 4 }

# constants mapped to string for AUTOLOAD
my %levels = (
	'fatal' => FATAL,
	'error' => ERROR,
	'warn'  => WARN,
	'info'  => INFO,
	'debug' => DEBUG,
);

# alter log level
sub level {
	my $self = shift;
	my %args = @_;
	
	# set verbosity at the level of methods
	if ( $args{'method'} ) {
		if ( ref $args{'method'} eq 'ARRAY' ) {
			$VERBOSE{$_} = $args{'level'} for @{ $args{'method'} };
		}
		else {
			$VERBOSE{$args{'method'}} = $args{'level'};
		}
	}
	
	# set verbosity at the level of classes
	elsif ( $args{'class'} ) {
		if ( ref $args{'class'} eq 'ARRAY' ) {
			$VERBOSE{$_} = $args{'level'} for @{ $args{'class'} };
		}
		else {
			$VERBOSE{$args{'class'}} = $args{'level'};
		}
	}
	
	# set verbosity globally
	else {
		$VERBOSE = $args{'level'};
	}
	return $self;
}

# this is where methods such as $log->info ultimately are routed to
sub AUTOLOAD {
	my ( $self, $msg ) = @_;
	my $method = $AUTOLOAD;
	$method =~ s/.+://;
	
	# only proceed if method was one of fatal..debug
	if ( exists $levels{$method} ) {
		my ( $package, $file1up, $line1up, $subroutine ) = caller( 1 );
		my ( $pack0up, $filename, $line, $sub0up )       = caller( 0 );
		
		# calculate what the verbosity is for the current context
		# (either at sub, package or global level)
		my $verbosity;
		if ( exists $VERBOSE{$subroutine} ) {
			$verbosity = $VERBOSE{$subroutine};
		}
		elsif ( exists $VERBOSE{$pack0up} ) {
			$verbosity = $VERBOSE{$pack0up};
		}
		else {
			$verbosity = $VERBOSE;
		}
		
		# we need to do something with the message
		if ( $verbosity >= $levels{$method} ) {
			printf STDERR "%s %s [%s, %s] - %s\n", uc $method, $subroutine, $filename, $line, $msg;
		}
	}
}

1;