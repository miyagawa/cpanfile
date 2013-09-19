use strict;
use Module::CPANfile;
use Test::More;
use t::Utils;

subtest 'full set' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', '0.9970',
    git => 'git://github.com/plack/Plack.git', ref => '0.9970';
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => '0.9970' },
        },
    };

    my $req = $file->prereqs->requirements_for(runtime => 'requires');
    is $req->requirements_for_module('Plack'), '0.9970';

    is_deeply $file->options_for_module('Plack'), {
        git => 'git://github.com/plack/Plack.git',
        ref => '0.9970',
    };
};

subtest 'drop version' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', # drop version
    git => 'git://github.com/plack/Plack.git', ref => '0.9970';
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => 0 },
        },
    };

    is_deeply $file->options_for_module('Plack'), {
        git     => 'git://github.com/plack/Plack.git',
        ref     => '0.9970',
    };
};

subtest 'no ref' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', '0.9970', git => 'git://github.com/plack/Plack.git';
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => '0.9970' },
        },
    };

    is_deeply $file->options_for_module('Plack'), {
        git     => 'git://github.com/plack/Plack.git',
    };
};

subtest 'name and git' => sub {
    my $r = write_cpanfile(<<FILE);
requires 'Plack', git => 'git://github.com/plack/Plack.git';
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => 0 },
        },
    };

    is_deeply $file->options_for_module('Plack'), {
        git     => 'git://github.com/plack/Plack.git',
    };
};

done_testing;
