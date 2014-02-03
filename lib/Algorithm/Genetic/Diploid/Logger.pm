package Algorithm::Genetic::Diploid::Logger;
use strict;
use Exporter;
use base 'Exporter';

our $AUTOLOAD;
our @EXPORT_OK = qw(DEBUG INFO WARN ERROR FATAL);
our %EXPORT_TAGS = ( 'levels' => [@EXPORT_OK] );
our $VERBOSE = 2; # i.e. WARN, default 
our %VERBOSE;

=head1 NAME

Algorithm::Genetic::Diploid::Logger - reports on progress of the experiment

=head1 METHODS

=over

=item new

This singleton constructor always returns reference to same object

=cut

my $SINGLETON;
sub new {
	my $class = shift;
	if ( not $SINGLETON ) {
		$SINGLETON = bless \$class, $class;
	}
	$SINGLETON->level(@_) if @_;
	return $SINGLETON;
}

=item level

Alters log level. Takes named arguments: C<method> provides a scalar or array of fully
qualified method names whose verbosity to alter. C<class> provides a scalar or array of
package names whose verbosity to alter. C<level> sets the verbosity to one of the levels
described below.

=cut

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

# destructor does nothing
sub DESTROY {}

=back

=head1 VERBOSITY LEVELS

The following constants are available when using this package with the use qualifier
':levels', i.e. C<use Algorithm::Genetic::Diploid::Logger ':levels';>. They represent
different verbosity levels that can be set globally, and/or at package level, and/or
at method level.

=over

=item FATAL

Only most severe messages are transmitted.

=cut

sub FATAL () { 0 }

=item ERROR

Possibly unrecoverable errors are transmitted.

=cut

sub ERROR () { 1 }

=item WARN

Warnings are transmitted. This is the default.

=cut

sub WARN ()  { 2 }

=item INFO

Informational messages are transmitted.

=cut

sub INFO ()  { 3 }

=item DEBUG

Everything is transmitted, including debugging messages.

=cut

sub DEBUG () { 4 }

# constants mapped to string for AUTOLOAD
my %levels = (
	'fatal' => FATAL,
	'error' => ERROR,
	'warn'  => WARN,
	'info'  => INFO,
	'debug' => DEBUG,
);

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

=back

=cut

1;