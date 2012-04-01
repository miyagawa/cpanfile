use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'CPAN::cpanfile',
    VERSION_FROM => 'lib/CPAN/cpanfile.pm',
    ABSTRACT => 'A format for describing CPAN dependencies of Perl applications',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.31,
    },
    MIN_PERL_VERSION => '5.008001',
    AUTHOR => 'Tatsuhiko Miyagawa',
    LICENSE => "perl",
);
