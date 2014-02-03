package GA::Individual;
use List::Util qw'sum shuffle';
use GA::Base;
use base 'GA::Base';

my $log = __PACKAGE__->logger;

sub new {
	shift->SUPER::new(
		'chromosomes' => [],
		'child_count' => 0,
		@_,
	);
}

# number of children
sub child_count {
	shift->{'child_count'};
}

# private method to increment 
# child count after breeding
sub _increment_cc { shift->{'child_count'}++ }

# list of chromosomes
sub chromosomes {
	my $self = shift;
	if ( @_ ) {
		$log->info("assigning new chromosomes: @_");
		$self->{'chromosomes'} = \@_;
	}
	return @{ $self->{'chromosomes'} }
}

# meiosis produces a gamete, i.e. n chromosomes 
# that have mutated and recombined
sub meiosis {
	my $self = shift;
	my $log = $self->logger;
	$log->debug("going to create gametes");
	
	# this is basically mitosis: cloning of chromosomes
	my @chro = map { $_->clone } $self->chromosomes;
	$log->debug("have cloned chromosomes (meiosis II)");
	
	# create pairs of homologous chromosomes, i.e. metafase
	my @pairs;
	for my $i ( 0 .. $#chro - 1 ) {
		for my $j ( ( $i + 1 ) .. $#chro ) {
			if ( $chro[$i]->number == $chro[$j]->number ) {
				push @pairs, [ $chro[$i], $chro[$j] ];
			}	
		}
	}
	
	# recombination happens during metafase
	for my $pair ( @pairs ) {
		$pair->[0]->recombine( $pair->[1] );
	}
	
	# telofase: homologues segregate
	my @gamete = map { $_->[0] } map { [ shuffle @{ $_ } ] } @pairs;
	return @gamete;
}

# produce a new individual from 
# $self and $mate's gametes
sub breed {
	my ( $self, $mate ) = @_;
	$self->logger->debug("going to breed $self with $mate");
	$self->_increment_cc;
	$mate->_increment_cc;
	__PACKAGE__->new( 
		'chromosomes' => [ $self->meiosis, $mate->meiosis ] 
	);
}

# express all the genes and weigh 
# them to produce a phenotype
sub phenotype {
	my ( $self, $env ) = @_;
	$self->logger->debug("computing phenotype in environment $env");
	if ( not defined $self->{'phenotype'} ) {
		my @genes = map { $_->genes } $self->chromosomes;
		my $total_weight = sum map { $_->weight } @genes;
		my $products = sum map { $_->weight * $_->express($env) } @genes;
		$self->{'phenotype'} = $products / $total_weight;
	}
	return $self->{'phenotype'};
}

# the fitness is the squared difference 
# between the optimum and the phenotype
sub fitness {
	my ( $self, $optimum, $env ) = @_;
	my $id = $self->id;
	my $phenotype = $self->phenotype( $env );
	my $diff = abs( $optimum - $phenotype );
	$self->logger->debug("fitness of $id against optimum $optimum is $diff");
	return $diff;
}

1;