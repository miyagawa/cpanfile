package t::Utils;
use base qw(Exporter);
use File::pushd qw(tempd);

our @EXPORT = qw(write_cpanfile write_files);

sub write_cpanfile {
    write_files('cpanfile' => $_[0]);
}

sub write_files {
    my %files = @_;

    my $dir = tempd;

    for my $file (keys %files) {
        open my $fh, ">", $file or die "$file: $!";
        print $fh $files{$file};
    }

    return $dir;
}

1;

