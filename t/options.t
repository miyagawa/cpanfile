use strict;
use Test::More;

use Module::CPANfile;
use lib ".";
use t::Utils;

{
    my $r = write_cpanfile(<<FILE);
requires 'Path::Class', 0.26,
  dist => "KWILLIAMS/Path-Class-0.26.tar.gz";

# omit version specifier
requires 'Hash::MultiValue',
  dist => "MIYAGAWA/Hash-MultiValue-0.15.tar.gz";

# use dist + mirror
requires 'Cookie::Baker',
  dist => "KAZEBURO/Cookie-Baker-0.08.tar.gz",
  mirror => "http://cpan.cpantesters.org/";

# use the full URL
requires 'Try::Tiny', 0.28,
  url => "http://backpan.perl.org/authors/id/E/ET/ETHER/Try-Tiny-0.28.tar.gz";
FILE

    my $file1 = Module::CPANfile->load;
    my $blob = $file1->to_string;

    my $file2 = Module::CPANfile->load(\$blob);

    for my $mod ( qw(Path::Class Hash::MultiValue Cookie::Baker Try::Tiny) ) {
        is_deeply $file1->options_for_module($mod), $file2->options_for_module($mod);
    }
}

done_testing;
