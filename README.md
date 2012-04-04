# NAME

cpanfile - A format for describing CPAN dependencies for Perl applications

# SYNOPSIS

    requires 'Catalyst', '5.8000';
    requires 'CatalystX::Singleton', '>= 1.1000, < 2.000';

    recommends 'JSON::XS', '2.0';
    conflicts 'JSON', '< 1.0';

    osname 'MSWin32' => sub {
        requires 'Win32::File';
    };

    on 'test' => sub {
        requires 'Test::More', '>= 0.96, < 2.0';
        recommends 'Test::TCP', '1.12';
    };

    on 'develop' => sub {
        recommends 'Devel::NYTProf';
    };

    perl '< v5.10' => sub {
        requires 'Hash::Util::FieldHash::Compat';
    };

# VERSION

0.9000

# DESCRIPTION  

`cpanfile` describes CPAN dependencies required to execute associated
Perl code.

Place the `cpanfile` in the root of the directory containing the
associated code. For instance, in a Catalyst application, place the
`cpanfile` in the same directory as `myapp.conf`.

Tools supporting `cpanfile` format (e.g. [cpanm](http://search.cpan.org/perldoc?cpanm) and [carton](http://search.cpan.org/perldoc?carton)) will
automatically detect the file and install dependencies for the code to
run.

# AUTHOR

Tatsuhiko Miyagawa

# ACKNOWLEDGEMENTS

The format (DSL syntax) is inspired by [Module::Install](http://search.cpan.org/perldoc?Module::Install) and
[Module::Build::Functions](http://search.cpan.org/perldoc?Module::Build::Functions).

`cpanfile` specification (this document) is based on Ruby's
[Gemfile](http://gembundler.com/man/gemfile.5.html) specification.

# SEE ALSO

[CPAN::Meta::Spec](http://search.cpan.org/perldoc?CPAN::Meta::Spec) [Module::Install](http://search.cpan.org/perldoc?Module::Install) [Carton](http://search.cpan.org/perldoc?Carton)