use strict;
use Module::CPANfile;
use Test::More;
use lib ".";
use t::Utils;

{
    my $r = write_cpanfile(<<FILE);
on test => sub {
  requires 'Test::More', '0.90';
};

feature 'sqlite' => sub {
  on runtime => sub { requires 'DBD::SQLite' },
};
FILE
    my $cpanfile = Module::CPANfile->load;
    my @features = $cpanfile->features;
    is $features[0]->identifier, 'sqlite';
    is $features[0]->description, 'sqlite';
}

{
    my $r = write_cpanfile(<<FILE);
on test => sub {
  requires 'Test::More', '0.90';
};

feature 'sqlite', 'SQLite support' => sub {
  on runtime => sub { requires 'DBD::SQLite' },
};
FILE
    my $cpanfile = Module::CPANfile->load;

    my @features = $cpanfile->features;
    is @features, 1;
    ok $features[0]->isa('CPAN::Meta::Feature');
    is $features[0]->identifier, 'sqlite';
    is $features[0]->description, 'SQLite support';
    ok $features[0]->prereqs;

    is_deeply $features[0]->prereqs->as_string_hash, { runtime => { requires => { 'DBD::SQLite' => '0' } } };

    {
        my $prereqs = $cpanfile->prereqs;
        is_deeply $prereqs->as_string_hash, {
            test => { requires => { 'Test::More' => '0.90' } },
        };
    }

    {
        my $prereqs = $cpanfile->effective_prereqs;
        is_deeply $prereqs->as_string_hash, {
            test => { requires => { 'Test::More' => '0.90' } },
        };
    }

    {
        my $prereqs = $cpanfile->prereqs_with('sqlite');
        is_deeply $prereqs->as_string_hash, {
            test => { requires => { 'Test::More' => '0.90' } },
            runtime => { requires => { 'DBD::SQLite' => '0' } },
        };
    }

    {
        my $prereqs = $cpanfile->effective_prereqs(['sqlite']);
        is_deeply $prereqs->as_string_hash, {
            test => { requires => { 'Test::More' => '0.90' } },
            runtime => { requires => { 'DBD::SQLite' => '0' } },
        };
    }

    {
        eval { my $prereqs = $cpanfile->prereqs_with('foobar') };
        like $@, qr/Unknown feature 'foobar'/;
    }

    {
        # no features, it's ok
        eval { my $prereqs = $cpanfile->prereqs_with() };
        ok !$@, $@;
    }

    like $cpanfile->to_string, qr/feature/;
    like $cpanfile->to_string, qr/DBD::SQLite/;
}

done_testing;
