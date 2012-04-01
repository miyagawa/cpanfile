use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'CPANfile',
    VERSION_FROM => 'lib/CPANfile.pm',
    ABSTRACT => 'A format for describing CPAN dependencies of Perl applications',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.31,
    },
    LICENSE => "perl",
);
