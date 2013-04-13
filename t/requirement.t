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
requires 'Plack', '0.9970',
    git => 'git://github.com/plack/Plack.git', revision => '0.9970';
FILE

    my $file = Module::CPANfile->load;
    my $prereq = $file->prereq;

    my $requirement = Module::CPANfile::Requirement->new(
        name     => 'Plack',
        version  => '0.9970',
        git      => 'git://github.com/plack/Plack.git',
        revision => '0.9970',
    );

    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => $requirement },
        },
    };

    # backword compatibility
    is_deeply $file->prereq_specs, {
        runtime => {
            requires => { 'Plack' => $requirement->{version} },
        },
    };

}

done_testing;
