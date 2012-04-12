use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Module::CPANfile',
    VERSION_FROM => 'lib/Module/CPANfile.pm',
    ABSTRACT => 'A format for describing CPAN dependencies of Perl applications',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.31,
    },
    MIN_PERL_VERSION => '5.008001',
    AUTHOR => 'Tatsuhiko Miyagawa',
    LICENSE => "perl",
);
