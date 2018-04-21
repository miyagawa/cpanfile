use strict;
use Module::CPANfile;
use Test::More;
use lib ".";
use t::Utils;

{
    my $r = write_files(cpanfile => <<CPANFILE, 'META.json' => <<META);
requires 'Plack', '0.9970';

on 'test' => sub {
    requires 'Test::More', '0.90';
};

on 'develop' => sub {
    requires 'Catalyst::Runtime', '> 5.8000, < 5.9';
};
CPANFILE
{
   "abstract" : "A format for describing CPAN dependencies of Perl applications",
   "author" : [
      "Tatsuhiko Miyagawa"
   ],
   "dynamic_config" : 0,
   "generated_by" : "ExtUtils::MakeMaker version 6.64, CPAN::Meta::Converter version 2.120921",
   "meta-spec" : {
      "url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
      "version" : "2"
   },
   "name" : "Module-CPANfile",
   "prereqs" : {
      "build" : {
         "requires" : {
            "ExtUtils::MakeMaker" : "0"
         }
      },
      "configure" : {
         "requires" : {
            "ExtUtils::MakeMaker" : "6.31"
         }
      },
      "runtime" : {
         "requires" : {
            "perl" : "5.008001",
            "Plack" : "0.9000"
         }
      }
   },
   "version" : "0.9007"
}
META

    my $file = Module::CPANfile->load;
    $file->merge_meta('META.json');

    my $meta = CPAN::Meta->load_file('META.json');
    is_deeply $meta->prereqs, {
        build => { requires => { 'ExtUtils::MakeMaker' => 0 } },
        configure => { requires => { 'ExtUtils::MakeMaker' => '6.31' } },
        runtime => { requires => { 'perl' => '5.008001', 'Plack' => '0.9970' } },
        develop => { requires => { 'Catalyst::Runtime' => '> 5.8000, < 5.9' } },
        test => { requires => { 'Test::More' => '0.90' } },
    };
}

done_testing;
