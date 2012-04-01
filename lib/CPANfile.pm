package CPANfile;
use strict;
use warnings;
use Cwd;
use CPANfile::Environment ();

sub new {
    my($class, $file) = @_;
    my $self = bless { file => $file || "cpanfile" }, $class;
    $self->parse;
    $self;
}

sub parse {
    my $self = shift;

    my $file = Cwd::abs_path($self->{file});
    $self->{result} = CPANfile::Environment::parse($file) or die $@;
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

CPANfile - Parse cpanfile

=head1 SYNOPSIS

  use CPANfile;

  my $file = CPANfile->new("cpanfile");
  my $meta = $file->prereqs; # CPAN::Meta::Prereqs object

=head1 DESCRIPTION

CPANfile is a tool to handle L<cpanfile> format to load application
specific dependencies, not just for CPAN distributions.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<cpanfile>, L<CPAN::Meta>, L<CPAN::Meta::Spec>

=cut


