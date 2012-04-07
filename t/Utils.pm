package t::Utils;
use base qw(Exporter);

our @EXPORT = qw(write_cpanfile);

sub write_cpanfile {
    my $dir = "t/sample-" . rand(100000);
    mkdir $dir;
    chdir $dir;

    open my $fh, ">cpanfile" or die $!;
    print $fh @_;

    return Remover->new($dir);
}

package
  Remover;
sub new {
    bless { dir => $_[1], file => $_[2] }, $_[0];
}

sub DESTROY {
    unlink 'cpanfile';
    chdir "../..";
    rmdir $_[0]->{dir};
}

