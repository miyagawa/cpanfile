package Module::CPANfile::Prereqs;
use strict;
use parent qw(CPAN::Meta::Prereqs);

sub _normalize_prereqs {
    my $prereqs = shift;

    my $copy = {};

    for my $phase (keys %$prereqs) {
        for my $type (keys %{ $prereqs->{$phase} }) {
            while (my($module, $requirement) = each %{ $prereqs->{$phase}{$type} }) {
                $copy->{$phase}{$type}{$module} = ref $requirement ? $requirement->version : $requirement;
            }
        }
    }

    $copy;
}

sub new {
    my($class, $prereq_spec) = @_;

    my $prereqs = _normalize_prereqs($prereq_spec);
    my $self = $class->SUPER::new($prereqs);
    $self->{_prereq_spec} = $prereq_spec;
    $self;
}

1;

