package Module::CPANfile::Features;
use strict;
use Carp ();
use Module::CPANfile::Feature;

sub new {
    my($class, $features) = @_;
    bless { features => $features }, $class;
}

sub identifiers {
    my $self = shift;
    keys %{$self->{features}};
}

sub all {
    my $self = shift;
    map $self->get($_), $self->identifiers;
}

sub get {
    my($self, $identifier) = @_;

    my $data = $self->{features}{$identifier}
      or Carp::croak("Unknown feature '$identifier'");

    Module::CPANfile::Feature->new($data->{identifier}, {
        description => $data->{description},
        prereqs => $data->{prereqs},
    });
}

1;

