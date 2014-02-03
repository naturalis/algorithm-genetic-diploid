package Algorithm::Genetic::Diploid;
use Algorithm::Genetic::Diploid::Logger;
use Algorithm::Genetic::Diploid::Base;
use Algorithm::Genetic::Diploid::Chromosome;
use Algorithm::Genetic::Diploid::Experiment;
use Algorithm::Genetic::Diploid::Gene;
use Algorithm::Genetic::Diploid::Individual;
use Algorithm::Genetic::Diploid::Population;

our $AUTOLOAD;

sub AUTOLOAD {
	my ( $self, %args ) = @_;
	my $method = $AUTOLOAD;
	$method =~ s/.+://;
	if ( $method =~ /^create_(\s+)$/ ) {
		my $class = $1;
		my $package = 'Algorithm::Genetic::Diploid::' . ucfirst $class;
		return $package->new(%args);
	}
}

1;