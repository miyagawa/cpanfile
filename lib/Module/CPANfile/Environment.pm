package Module::CPANfile::Environment;
use strict;
use Module::CPANfile::Result;
use Carp ();

my @bindings = qw(
    on requires recommends suggests conflicts
    feature
    osname
    configure_requires build_requires test_requires author_requires
);

my $file_id = 1;

sub new {
    my($class, $file) = @_;
    bless {
        file => $file,
    }, $class;
}

sub bind {
    my $class = shift;
    my $pkg = caller;

    my $result = Module::CPANfile::Result->new;
    for my $binding (@bindings) {
        no strict 'refs';
        *{"$pkg\::$binding"} = sub { $result->$binding(@_) };
    }

    return $result;
}

sub parse {
    my($self, $code) = @_;

    my($res, $err);

    {
        local $@;
        $res = eval sprintf <<EVAL, $file_id++;
package Module::CPANfile::Sandbox%d;
no warnings;
my \$_result;
BEGIN { \$_result = Module::CPANfile::Environment->bind }

# line 1 "$self->{file}"
$code;

\$_result;
EVAL
        $err = $@;
    }

    if ($err) { die "Parsing $self->{file} failed: $err" };

    return $res;
}

1;

