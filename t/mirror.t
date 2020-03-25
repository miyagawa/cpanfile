use strict;
use Module::CPANfile;
use Test::More;
use lib ".";
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

subtest 'multiple mirrors - multiple definition styles' => sub {
    my $r = write_cpanfile(<<FILE);

# no mirror
requires 'Try::Tiny';

mirror 'http://pause.local' => sub {
    requires 'Secret::Module' => '0.1';
    requires 'Secret::Sauce';
    suggests 'Secrets::Manager';
};

mirror 'https://backpan.perl.org';

requires 'Hash::MultiValue' => '0.08';

requires 'Cookie::Monster' => '0.01',
    mirror => 'http://cpan.monstrous.com',
    url => 'http://cpan.monstrous.com/cpan/authors/id/C/CO/COO/Cookie-Monster-0.01.tar.gz';

on test => sub {
    requires 'Test::More' => '0.83',
        mirror => 'https://cpantesters.org';
};

FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq->as_string_hash, {
        runtime => {
            requires => {
                'Cookie::Monster'  => '0.01',
                'Hash::MultiValue' => '0.08',
                'Secret::Module'   => '0.1',
                'Secret::Sauce'    => 0,
                'Try::Tiny'        => 0,
            },
            suggests => {'Secrets::Manager' => 0}
        },
        test => {
            requires => {'Test::More' => '0.83'}
        }
    };

    my $mirrors = $file->mirrors;
    is_deeply $mirrors, ['https://backpan.perl.org'], 'correct mirror';

    is_deeply $file->options_for_module('Hash::MultiValue'), {
        mirror => 'https://backpan.perl.org'}, 'correct options';
    is_deeply $file->options_for_module('Cookie::Monster'), {
        'mirror' => 'http://cpan.monstrous.com',
        'url'    => 'http://cpan.monstrous.com/cpan/authors/id/C/CO/COO/Cookie-Monster-0.01.tar.gz'
    }, 'options';

    # test comprehension and round trip.
    like $file->to_string, qr{^requires 'Try::Tiny';}s, 'no mirror - first thing';
    like $file->to_string, qr{mirror 'http://pause\.local' => sub \{}, 'block start';
    like $file->to_string, qr{mirror 'http://cpan.monstrous.com' => sub \{
\s+requires 'Cookie::Monster', '0.01',
\s+url => 'http://cpan.monstrous.com/cpan/authors/id/C/CO/COO/Cookie-Monster-0.01.tar.gz';
\s*\}}m, 'mirror block with url - n.b. mirror will likely be ignored by cpanm';

    like $file->to_string,
        qr{mirror 'https://backpan.perl.org';\nrequires 'Hash::MultiValue', '0.08';}m,
        'file level mirror';

    like $file->to_string, qr{on test => sub \{
\s+requires 'Test::More', '0.83',
\s+mirror => 'https://cpantesters.org';
\s*\};}m, 'mirror options included';

    # diag $file->to_string;
};

subtest 'mirror scope for on block' => sub {
    my $r = write_cpanfile(<<FILE);

on develop => sub {
    mirror 'https://pause.local';
    requires 'Test::More::Secret';
};
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq->as_string_hash, {
        develop => {
            requires => {'Test::More::Secret' => '0'}
        }
    };

    my $mirrors = $file->mirrors;

    # mirror remains file scope despite apparent ANON sub scope.
    is_deeply $mirrors, ['https://pause.local'], 'no blocks mark scope level';

    like $file->to_string, qr{^mirror 'https://pause\.local';}s, 'DSL limitation';
    like $file->to_string, qr{mirror => 'https://pause\.local';}, 'unfortunate duplication';
    # diag $file->to_string;
};


subtest 'mirror and dist options' => sub {
    my $r = write_cpanfile(<<FILE);

requires 'XYZ',
    mirror => 'http://darkpan.company.com';

requires 'Hash::MultiValue' => '0.08',
    dist => 'MIYAGAWA/Hash-MultiValue-0.08.tar.gz',
    mirror => 'https://backpan.perl.org';

on develop => sub {
    mirror 'https://pause.local';
    requires 'Test::More::Secret',
    dist => 'MY/Test-More-Secret-10000a.tar.gz';
};
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq->as_string_hash, {
        runtime => {
            requires => {'Hash::MultiValue' => '0.08', XYZ => 0}
        },
        develop => {
            requires => {'Test::More::Secret' => '0'}
        }
    };

    my $mirrors = $file->mirrors;

    # mirror remains file scope despite apparent ANON sub scope.
    is_deeply $mirrors, ['https://pause.local'], 'no blocks mark scope level';

    my $file_string = $file->to_string;
    ok $file_string, 'check recallable';
    is $file->to_string, <<'EOF', 'blocks preferred, options "promoted"';
mirror 'http://darkpan.company.com' => sub {
    requires 'XYZ';
};
mirror 'https://backpan.perl.org' => sub {
    requires 'Hash::MultiValue', '0.08',
      dist => 'MIYAGAWA/Hash-MultiValue-0.08.tar.gz',
      mirror => 'https://backpan.perl.org';
};
mirror 'https://pause.local';
on develop => sub {
    requires 'Test::More::Secret',
      dist => 'MY/Test-More-Secret-10000a.tar.gz',
      mirror => 'https://pause.local';
};
EOF
};


subtest 'which mirror wins' => sub {
    my $r = write_cpanfile(<<FILE);
mirror 'http://darkpan.company.com';

requires 'ABC';
requires 'XYZ',
    mirror => 'https://pause.local';
requires 'LMNO' => '2.1';
FILE

    my $file = Module::CPANfile->load;
    is_deeply $file->prereq->as_string_hash, {
        runtime => {
            requires => {ABC => 0, LMNO => '2.1', XYZ => 0}
        },
    };

    is_deeply $file->mirrors, ['http://darkpan.company.com'], 'one mirror';
    is_deeply $file->options_for_module('ABC'), {
        mirror => 'http://darkpan.company.com',
    }, 'preceeding mirror';
    is_deeply $file->options_for_module('XYZ'), {
        mirror => 'https://pause.local',
    }, 'specific';
    is_deeply $file->options_for_module('LMNO'), {
        mirror => 'http://darkpan.company.com',
    }, 'original';

    # call multiple times (delete mirror vs options_for_module copy)
    like $file->to_string, qr/requires 'ABC';/;
    like $file->to_string, qr/requires 'LMNO', '2.1';/;
    like $file->to_string, qr{mirror 'http://darkpan.company.com';};
    like $file->to_string, qr{mirror 'https://pause\.local' => sub};
};


done_testing;
