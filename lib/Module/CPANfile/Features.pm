package Module::CPANfile::Features;
use strict;
use Carp ();
use CPAN::Meta::Feature;

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

    CPAN::Meta::Feature->new($data->{identifier}, {
        description => $data->{description},
        prereqs => $data->{prereqs},
    });
}

1;

