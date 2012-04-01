package t::Utils;
use base qw(Exporter);

our @EXPORT = qw(write_cpanfile);

sub write_cpanfile {
    open my $fh, ">cpanfile" or die $!;
    print $fh @_;

    return Remover->new("cpanfile");
}

package
  Remover;
sub new {
    bless { file => $_[1] }, $_[0];
}

sub DESTROY {
    unlink $_[0]->{file};
}

