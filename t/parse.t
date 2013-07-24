use strict;
use Module::CPANfile;
use Test::More;
use POSIX qw(locale_h);
use t::Utils;

{
    # Use the traditional UNIX system locale to check the error message string.
    my $old_locale = setlocale(LC_ALL);
    setlocale(LC_ALL, 'C');
    eval {
        my $file = Module::CPANfile->load('foo');
    };
    like $@, qr/No such file/;
    setlocale(LC_ALL, $old_locale);
}

{
    my $r = write_cpanfile(<<FILE);
foo();
FILE
    eval { Module::CPANfile->load };
    like $@, qr/cpanfile line 1/;
}

{
    my $r = write_cpanfile("# %4N bug");
    eval { Module::CPANfile->load };
    is $@, '';
}

{
    my $r = write_cpanfile(<<FILE);
configure_requires 'ExtUtils::MakeMaker', 5.5;

requires 'DBI';
requires 'Plack', '0.9970';
conflicts 'Moose', '< 0.8';

on 'test' => sub {
    requires 'Test::More';
};

on 'develop' => sub {
    requires 'Catalyst::Runtime', '> 5.8000, < 5.9';
    recommends 'Catalyst::Plugin::Foo';
};

test_requires 'Test::Warn', 0.1;
author_requires 'Module::Install', 0.99;
FILE

    my $file = Module::CPANfile->load;
    my $prereq = $file->prereq;

    is_deeply $prereq->as_string_hash, {
        configure => {
            requires => { 'ExtUtils::MakeMaker' => '5.5' },
        },
        test => {
            requires => { 'Test::More' => 0, 'Test::Warn' => '0.1' },
        },
        runtime => {
            requires => { 'Plack' => '0.9970', 'DBI' => 0 },
            conflicts => { 'Moose' => '< 0.8' },
        },
        develop => {
            requires => { 'Catalyst::Runtime' => '> 5.8000, < 5.9', 'Module::Install' => '0.99' },
            recommends => { 'Catalyst::Plugin::Foo' => 0 },
        }
    };
}

done_testing;
