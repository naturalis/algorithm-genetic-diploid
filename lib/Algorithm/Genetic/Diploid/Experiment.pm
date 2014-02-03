package Algorithm::Genetic::Diploid::Experiment;
use Algorithm::Genetic::Diploid;
use base 'Algorithm::Genetic::Diploid::Base';

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

# probably the expected t+1 value
sub optimum {
	my ( $self, $gen ) = @_;
	# do something with env and generation
	return my $optimum;
}

# probably a data object that 
# gets passed to the gene functions
sub env {
	my $self = shift;
	$self->{'env'} = shift if @_;
	return $self->{'env'};
}

# the fraction of individuals in the 
# population that gets to reproduce
sub reproduction_rate {
	my $self = shift;
	$self->{'reproduction_rate'} = shift if @_;
	return $self->{'reproduction_rate'};
}

# amount of change to the weight 
# (and function) of a gene
sub mutation_rate {
	my $self = shift;
	$self->{'mutation_rate'} = shift if @_;
	return $self->{'mutation_rate'};
}

# proportion of genes that crossover
sub crossover_rate {
	my $self = shift;
	$self->{'crossover_rate'} = shift if @_;
	return $self->{'crossover_rate'};
}

# number of generations
sub ngens {
	my $self = shift;
	if ( @_ ) {
		$log->info("number of generations set to: @_");
		$self->{'ngens'} = shift;
	}
	return $self->{'ngens'};
}

# single Population
sub population {
	my $self = shift;
	if ( @_ ) {
		$log->info("assigning new population: @_");
		$self->{'population'} = shift;
	}
	return $self->{'population'};
}

# run the experiment!
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

# generally run this *after* an analysis
sub genecount {
	my $self = shift;
	my %genes = map { $_->id => $_ }
	            map { $_->genes }
				map { $_->chromosomes }
				map { $_->individuals } $self->population;
	return values %genes;
}

1;