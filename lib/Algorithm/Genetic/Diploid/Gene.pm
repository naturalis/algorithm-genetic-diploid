package Algorithm::Genetic::Diploid::Gene;
use Algorithm::Genetic::Diploid::Base;
use base 'Algorithm::Genetic::Diploid::Base';

sub new {
	shift->SUPER::new(
		'weight' => 1,
		@_,
	);
}

# gene function is a subroutine ref that 
# results in a gene product based
# on environmental input
sub function {
	my $self = shift;
	$self->make_function;
}

# gene is expressed based on environmental 
# input, returns a gene product
sub express {
	my ( $self, $env ) = @_;
	return $self->function->($env);
}

# re-scale the weight of the function
sub mutate {
	my ( $self, $func ) = @_;
	my $mu = $self->experiment->mutation_rate;
	my $scale = rand($mu) - $mu / 2 + 1;
	my $weight = $self->weight;
	$self->weight( $weight * $scale );
	$self->function( $func ) if $func;
	return $self;
}

# weight of this gene product 
# in the total phenotype
sub weight {
	my $self = shift;
	$self->{'weight'} = shift if @_;
	return $self->{'weight'};
}

1;