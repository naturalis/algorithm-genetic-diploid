package GA;
use GA::Logger;
use GA::Base;
use GA::Chromosome;
use GA::Experiment;
use GA::Gene;
use GA::Individual;
use GA::Population;

our $AUTOLOAD;

sub AUTOLOAD {
	my ( $self, %args ) = @_;
	my $method = $AUTOLOAD;
	$method =~ s/.+://;
	if ( $method =~ /^create_(\s+)$/ ) {
		my $class = $1;
		my $package = 'GA::' . ucfirst $class;
		return $package->new(%args);
	}
}

1;