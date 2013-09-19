package Module::CPANfile::Feature;
use strict;
use parent qw(CPAN::Meta::Feature);

sub new {
    my($class, $identifier, $spec) = @_;

    bless {
        identifier  => $identifier,
        description => $spec->{description},
        prereqs     => Module::CPANfile::Prereqs->new($spec->{prereqs}),
    }, $class;
}

1;
