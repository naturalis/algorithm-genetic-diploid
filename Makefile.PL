#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %params = (
	'NAME'          => 'Algorithm::Genetic::Diploid',
	'ABSTRACT_FROM' => 'lib/Algorithm/Genetic/Diploid.pm',
	'AUTHOR'        => 'Rutger Vos <rutger.vos@naturalis.nl>',
	'PREREQ_PM'     => { 'YAML::Any' => 0 },
	'VERSION_FROM'  => 'lib/Algorithm/Genetic/Diploid.pm',
);

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $params{'META_MERGE'} = {
        'resources' => {
            'bugtracker'  => 'https://github.com/naturalis/algorithm-genetic-diploid/issues',
            'license'     => 'mit',
            'repository'  => {
            	'type' => 'git',
            	'url'  => 'git://github.com/naturalis/algorithm-genetic-diploid.git',
            	'web'  => 'http://github.com/naturalis/algorithm-genetic-diploid',
            }
        },
    };
}


WriteMakefile( %params );
