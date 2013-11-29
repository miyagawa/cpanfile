use strict;
use Module::CPANfile;
use Test::More;
use t::Utils;

{
    my $r = write_cpanfile(<<FILE);
mirror 'http://www.cpan.org';
mirror 'http://backpan.cpan.org';

requires 'DBI';
requires 'Plack', '0.9970';

on 'test' => sub {
    requires 'Test::More';
};
FILE

    my $file = Module::CPANfile->load;

    my $prereq = $file->prereq;
    is_deeply $prereq->as_string_hash, {
        test => {
            requires => { 'Test::More' => 0  },
        },
        runtime => {
            requires => { 'Plack' => '0.9970', 'DBI' => 0 },
        },
    };

    my $mirrors = $file->mirrors;
    is_deeply $mirrors, [ 'http://www.cpan.org', 'http://backpan.cpan.org' ];

    like $file->to_string, qr{mirror 'http://www.cpan.org';};
    like $file->to_string, qr{mirror 'http://backpan.cpan.org';};
}

done_testing;
