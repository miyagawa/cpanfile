package CPANfile::Environment;
use strict;

my @bindings = qw(
    on requires recommends suggests conflicts
    osname perl
    configure_requires build_requires test_requires author_requires
);

my $file_id = 1;

sub import {
    my($class, $result_ref) = @_;
    my $pkg = caller;

    $$result_ref = CPANfile::Environment::Result->new;
    for my $binding (@bindings) {
        no strict 'refs';
        *{"$pkg\::$binding"} = sub { $$result_ref->$binding(@_) };
    }
}

sub parse {
    my $file = shift;

    my $code = do {
        open my $fh, "<", $file or die "$file: $!";
        join '', <$fh>;
    };

    my $res = eval sprintf <<EVAL, $file_id++;
package CPANfile::Environment::Sandbox%d;
my \$_result;
no warnings;
use CPANfile::Environment \\\$_result;

$code;

\$_result;
EVAL

    if (my $err = $@ || $!) { die "Parsing $file failed: $err" };

    return $res;
}

package CPANfile::Environment::Result;

sub new {
    bless {
        phase => 'runtime', # default phase
        spec  => {},
    }, shift;
}

sub on {
    my($self, $phase, $code) = @_;
    local $self->{phase} = $phase;
    $code->()
}

sub os { die "TODO" }
sub perl { die "TODO" }

sub requires {
    my($self, $module, $requirement) = @_;
    $self->{spec}{$self->{phase}}{requires}{$module} = $requirement || 0;
}

sub recommends {
    my($self, $module, $requirement) = @_;
    $self->{spec}->{$self->{phase}}{recommends}{$module} = $requirement || 0;
}

sub suggests {
    my($self, $module, $requirement) = @_;
    $self->{spec}->{$self->{phase}}{suggests}{$module} = $requirement || 0;
}

sub conflicts {
    my($self, $module, $requirement) = @_;
    $self->{spec}->{$self->{phase}}{conflicts}{$module} = $requirement || 0;
}

# Module::Install compatible shortcuts

sub configure_requires {
    my($self, @args) = @_;
    $self->on(configure => sub { $self->requires(@args) });
}

sub build_requires {
    my($self, @args) = @_;
    $self->on(build => sub { $self->requires(@args) });
}

sub test_requires {
    my($self, @args) = @_;
    $self->on(test => sub { $self->requires(@args) });
}

sub author_requires {
    my($self, @args) = @_;
    $self->on(develop => sub { $self->requires(@args) });
}

1;
