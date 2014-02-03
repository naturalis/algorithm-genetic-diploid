package Algorithm::Genetic::Diploid::Chromosome;
use Algorithm::Genetic::Diploid::Base;
use base 'Algorithm::Genetic::Diploid::Base';

my $log = __PACKAGE__->logger;

sub new {	
	shift->SUPER::new(
		'genes'  => [],
		'number' => 1,
		@_,
	);
}

# list of genes on the chromosome
sub genes {
	my $self = shift;
	if ( @_ ) {
		$log->debug("assigning new genes: @_");
		$self->{'genes'} = \@_;
	}
	return @{ $self->{'genes'} };
}

# chromosome number, i.e. in humans 
# that would be 1..22, X, Y
sub number {
	my $self = shift;
	$self->{'number'} = shift if @_;
	return $self->{'number'};
}

# exchanges genes with homologous chromosome
sub recombine {
	my ( $self, $other ) = @_;
	my @g1 = $self->genes;
	my @g2 = $other->genes;
	for my $i ( 0 .. $#g1 ) {
		if ( $self->experiment->crossover_rate > rand(1) ) {
			( $g1[$i], $g2[$i] ) = ( $g2[$i]->mutate, $g1[$i]->mutate );
		}
	}
	$self->genes(@g1);
	$other->genes(@g2);
}

1;