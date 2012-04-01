use strict;
use CPAN::cpanfile;
use Test::More;
use Cwd;
use File::Basename qw(dirname);
use t::Utils;

eval { require CPAN::Meta::Prereqs; 1 }
  or plan skip_all => "CPAN::Meta::Prereqs not found";

chdir "t/samples";

{
    eval {
        my $file = CPAN::cpanfile->load;
    };
    like $@, qr/No such file/;
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

    my $file = CPAN::cpanfile->load;
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
