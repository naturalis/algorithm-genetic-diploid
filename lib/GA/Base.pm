package GA::Base;
use GA::Logger;
use YAML::Any qw(Load Dump);

my $id = 1;
my $experiment;
my $logger = GA::Logger->new;

# base constructor for everyone
sub new {
	my $package = shift;
	$logger->debug("instantiating new $package object");
	my %self = @_;
	$self{'id'} = $id++;
	
	# experiment is provided as an argument
	if ( $self{'experiment'} ) {
		$experiment = $self{'experiment'};
		delete $self{'experiment'};
	}
	
	# create the object
	my $obj = \%self;
	bless $obj, $package;
	
	# maybe the object was the experiment?
	if ( $obj->isa('GA::Experiment') ) {
		$experiment = $obj;
	}
	
	return $obj;
}

# the logger is a singleton object so there's no
# point in having each object carrying around its
# own object reference. Hence, we just return a
# static reference here.	
sub logger { $logger }

# we don't want there to be circular references from
# each object to the experiment and back because it
# will create recursive YAML serializations and
# interfere with object cloning. Hence this is a
# static method
sub experiment {
	my $self = shift;
	$experiment = shift if @_;
	return $experiment;
}

# the ID is read-only, obviously
sub id { shift->{'id'} }

# write the object to a YAML string
sub dump {
	my $self = shift;
	my $string = Dump($self);
	return $string;
}

# read an object from a YAML string (static method)
sub load {
	my ( $package, $raw ) = @_;
	return Load($raw);
}

# clone an object by writing, then reading
sub clone {
	return __PACKAGE__->load(shift->dump);
}

sub DESTROY {
	my $self = shift;
	$logger->debug("$self is being cleaned up");
}