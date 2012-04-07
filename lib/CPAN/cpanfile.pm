package CPAN::cpanfile;
use strict;
use warnings;
use Cwd;
use CPAN::cpanfile::Environment;

our $VERSION = '0.9003';

sub new {
    my($class, $file) = @_;
    bless {}, $class;
}

sub load {
    my($proto, $file) = @_;
    my $self = ref $proto ? $proto : $proto->new;
    $self->{file} = $file || "cpanfile";
    $self->parse;
    $self;
}

sub parse {
    my $self = shift;

    my $file = Cwd::abs_path($self->{file});
    $self->{result} = CPAN::cpanfile::Environment::parse($file) or die $@;
}

sub prereq {
    my $self = shift;
    require CPAN::Meta::Prereqs;
    CPAN::Meta::Prereqs->new($self->prereq_specs);
}

sub prereq_specs {
    my $self = shift;
    $self->{result}{spec};
}

1;

__END__

=head1 NAME

CPAN::cpanfile - Parse cpanfile

=head1 SYNOPSIS

  use CPAN::cpanfile;

  my $file = CPAN::cpanfile->load("cpanfile");
  my $meta = $file->prereqs; # CPAN::Meta::Prereqs object

=head1 DESCRIPTION

CPAN::cpanfile is a tool to handle L<cpanfile> format to load application
specific dependencies, not just for CPAN distributions.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<cpanfile>, L<CPAN::Meta>, L<CPAN::Meta::Spec>

=cut


