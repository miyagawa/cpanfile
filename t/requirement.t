use strict;
use Module::CPANfile;
use Test::More;
use lib ".";
use t::Utils;

{
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
}

{
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
}

{
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
}

{
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
}

done_testing;
