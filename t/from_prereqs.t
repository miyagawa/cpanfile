use strict;
use Test::More;

use Module::CPANfile;
use lib ".";
use t::Utils;

{
    my $r = write_cpanfile(<<FILE);
requires 'perl', '5.008001';
requires 'DBI';
requires 'Plack', '1.0001';
test_requires 'Test::More', '0.90, != 0.91';
FILE

    my $prereqs = Module::CPANfile->load->prereqs;
    my $file = Module::CPANfile->from_prereqs($prereqs->as_string_hash);

    is_deeply $file->prereq_specs, $prereqs->as_string_hash;

    is $file->to_string, <<FILE;
requires 'DBI';
requires 'Plack', '1.0001';
requires 'perl', '5.008001';

on test => sub {
    requires 'Test::More', '>= 0.90, != 0.91';
};
FILE

    $file->save('cpanfile');

    my $content = do { local $/; open my $in, 'cpanfile'; <$in> };
    is $content, $file->to_string;
}

done_testing;
