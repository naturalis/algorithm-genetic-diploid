package Algorithm::Genetic::Diploid::Experiment;
use Algorithm::Genetic::Diploid;
use base 'Algorithm::Genetic::Diploid::Base';

=head1 NAME

Algorithm::Genetic::Diploid::Experiment - manages an evolutionary experiment

=head1 METHODS

=over

=item new

Constructor takes named arguments. Provides defaults for C<mutation_rate> (0.05), 
C<crossover_rate> (0.60), C<reproduction_rate> (0.35) and C<ngens> (50).

=cut

sub new {
	shift->SUPER::new(
		'mutation_rate'     => 0.05,
		'crossover_rate'    => 0.60,
		'reproduction_rate' => 0.35,
		'ngens'             => 50,
		'population'        => undef,
		'env'               => undef,
		@_
	);
}

=item optimum

Should be overridden in order to define an optimum fitness value at the provided 
generation.

=cut

# probably the expected t+1 value
sub optimum {
	my ( $self, $gen ) = @_;
	# do something with env and generation
	return my $optimum;
}

=item env

Getter and setter for a data object that gets passed to the gene functions

=cut

sub env {
	my $self = shift;
	$self->{'env'} = shift if @_;
	return $self->{'env'};
}

=item reproduction_rate

Getter and setter for the fraction of individuals in the population that 
gets to reproduce

=cut

sub reproduction_rate {
	my $self = shift;
	$self->{'reproduction_rate'} = shift if @_;
	return $self->{'reproduction_rate'};
}

=item mutation_rate

Amount of change to apply to the weight and/or function of a gene. 

=cut

sub mutation_rate {
	my $self = shift;
	$self->{'mutation_rate'} = shift if @_;
	return $self->{'mutation_rate'};
}

=item crossover_rate

Getter and setter for the proportion of genes that crossover

=cut

sub crossover_rate {
	my $self = shift;
	$self->{'crossover_rate'} = shift if @_;
	return $self->{'crossover_rate'};
}

=item ngens

Getter and setter for the number of generations in the experiment

=cut

sub ngens {
	my $self = shift;
	if ( @_ ) {
		$log->info("number of generations set to: @_");
		$self->{'ngens'} = shift;
	}
	return $self->{'ngens'};
}

=item population

Getter and setter for the L<Algorithm::Genetic::Diploid::Population> object

=cut

sub population {
	my $self = shift;
	if ( @_ ) {
		$log->info("assigning new population: @_");
		$self->{'population'} = shift;
	}
	return $self->{'population'};
}

=item run

Runs the experiment!

=cut

sub run {
	my $self = shift;
	my $log = $self->logger;
	
	$log->info("going to run experiment");
	my @results;
	for my $i ( 1 .. $self->ngens ) {
		my $optimum = $self->optimum($i);
		
		$log->info("optimum at generation $i is $optimum");
		my ( $fittest, $fitness ) = $self->population->turnover($i,$self->env,$optimum);
		push @results, [ $fittest, $fitness ];
	}
	my ( $fittest, $fitness ) = map { @{ $_ } } sort { $a->[1] <=> $b->[1] } @results;
	return $fittest, $fitness;
}

=item genecount

Returns the number of distinct genes that remained after an experiment.

=cut

sub genecount {
	my $self = shift;
	my %genes = map { $_->id => $_ }
	            map { $_->genes }
				map { $_->chromosomes }
				map { $_->individuals } $self->population;
	return values %genes;
}

=back

=cut

1;