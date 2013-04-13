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

subtest 'full set' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', '0.9970',
    git => 'git://github.com/plack/Plack.git', rev => '0.9970';
FILE

    my $file = Module::CPANfile->load;

    # backword compatibility
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => '0.9970' },
        },
    };

    my $got = $file->prereq_specs->{runtime}->{requires}->{Plack};
    isa_ok $got, 'Module::CPANfile::Requirement';
    is_deeply $got->as_hashref, {
        name    => 'Plack',
        version => '0.9970',
        git     => 'git://github.com/plack/Plack.git',
        rev     => '0.9970',
    };
};

subtest 'drop version' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', # drop version
    git => 'git://github.com/plack/Plack.git', rev => '0.9970';
FILE

    my $file = Module::CPANfile->load;

    # backword compatibility
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => 0 },
        },
    };

    my $got = $file->prereq_specs->{runtime}->{requires}->{Plack};
    isa_ok $got, 'Module::CPANfile::Requirement';
    is_deeply $got->as_hashref, {
        name    => 'Plack',
        version => '0',
        git     => 'git://github.com/plack/Plack.git',
        rev     => '0.9970',
    };
};

subtest 'no revision' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', '0.9970', git => 'git://github.com/plack/Plack.git';
FILE

    my $file = Module::CPANfile->load;

    # backword compatibility
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => '0.9970' },
        },
    };

    my $got = $file->prereq_specs->{runtime}->{requires}->{Plack};
    isa_ok $got, 'Module::CPANfile::Requirement';
    is_deeply $got->as_hashref, {
        name    => 'Plack',
        version => '0.9970',
        git     => 'git://github.com/plack/Plack.git',
    };
};

subtest 'name and git' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', git => 'git://github.com/plack/Plack.git';
FILE

    my $file = Module::CPANfile->load;

    # backword compatibility
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => 0 },
        },
    };

    my $got = $file->prereq_specs->{runtime}->{requires}->{Plack};
    isa_ok $got, 'Module::CPANfile::Requirement';
    is_deeply $got->as_hashref, {
        name    => 'Plack',
        version => 0,
        git     => 'git://github.com/plack/Plack.git',
    };
};

done_testing;
