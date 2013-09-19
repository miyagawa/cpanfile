package Module::CPANfile::Environment;
use strict;
use warnings;
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
        file     => $file,
        phase    => 'runtime', # default phase
        features => {},
        feature  => undef,
        prereqs  => {},
    }, $class;
}

sub bind {
    my $self = shift;
    my $pkg = caller;

    for my $binding (@bindings) {
        no strict 'refs';
        *{"$pkg\::$binding"} = sub { $self->$binding(@_) };
    }
}

sub parse {
    my($self, $code) = @_;

    my $err;
    {
        local $@;
        $file_id++;
        $self->_evaluate(<<EVAL);
package Module::CPANfile::Sandbox$file_id;
no warnings;
BEGIN { \$_environment->bind }

# line 1 "$self->{file}"
$code;
EVAL
        $err = $@;
    }

    if ($err) { die "Parsing $self->{file} failed: $err" };

    return 1;
}

sub _evaluate {
    my $_environment = $_[0];
    eval $_[1];
}

sub features { $_[0]->{features} }
sub prereqs  { $_[0]->{prereqs} }

# DSL goes from here

sub on {
    my($self, $phase, $code) = @_;
    local $self->{phase} = $phase;
    $code->();
}

sub feature {
    my($self, $identifier, $description, $code) = @_;

    # shortcut: feature identifier => sub { ... }
    if (@_ == 3 && ref($description) eq 'CODE') {
        $code = $description;
        $description = $identifier;
    }

    unless (ref $description eq '' && ref $code eq 'CODE') {
        Carp::croak("Usage: feature 'identifier', 'Description' => sub { ... }");
    }

    local $self->{feature} = $self->{features}{$identifier}
      = { identifier => $identifier, description => $description, prereqs => {} };
    $code->();
}

sub osname { die "TODO" }

sub requirement_for {
    my ($self, $module, @args) = @_;

    my $requirement = 0;
    $requirement = shift @args if @args % 2;

    return Module::CPANfile::Requirement->new(
        name    => $module,
        version => $requirement,
        @args,
    );
}

sub requires {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{prereqs} : $self->{prereqs})
      ->{$self->{phase}}{requires}{$module} = $self->requirement_for($module, @args);
}

sub recommends {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{prereqs} : $self->{prereqs})
      ->{$self->{phase}}{recommends}{$module} = $self->requirement_for($module, @args);
}

sub suggests {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{prereqs} : $self->{prereqs})
      ->{$self->{phase}}{suggests}{$module} = $self->requirement_for($module, @args);
}

sub conflicts {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{prereqs} : $self->{prereqs})
      ->{$self->{phase}}{conflicts}{$module} = $self->requirement_for($module, @args);
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

