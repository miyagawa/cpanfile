package t::Utils;
use base qw(Exporter);

our @EXPORT = qw(write_cpanfile write_files);

sub write_cpanfile {
    write_files('cpanfile' => $_[0]);
}

sub write_files {
    my %files = @_;

    my $dir = "t/sample-" . rand(100000);
    mkdir $dir;
    chdir $dir;

    for my $file (keys %files) {
        open my $fh, ">", $file or die $!;
        print $fh $files{$file};
    }

    return Remover->new($dir, [ keys %files ]);
}

package
  Remover;
sub new {
    bless { dir => $_[1], files => $_[2] }, $_[0];
}

sub DESTROY {
    my $self = shift;
    for my $file (@{$self->{files}}) {
        unlink $file;
    }
    chdir "../..";
    rmdir $self->{dir};
}

