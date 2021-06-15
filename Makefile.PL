use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Net::Payment::CCAvenue::NonSeamless',
    AUTHOR           => q{Rakesh Kumar Shardiwal <rakesh.shardiwal@gmail.com>},
    VERSION_FROM     => 'lib/Net/Payment/CCAvenue/NonSeamless.pm',
    ABSTRACT_FROM    => 'lib/Net/Payment/CCAvenue/NonSeamless.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'URI'              => '0',
        'Crypt::Mode::CBC' => '0',
        'Digest::MD5'      => '0',
        'CGI'              => '0',
        'DateTime'         => '0',
        'JSON::XS'         => '0',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Net-Payment-CCAvenue-NonSeamless-*' },
);
