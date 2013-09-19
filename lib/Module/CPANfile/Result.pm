package Module::CPANfile::Result;
use strict;

sub from_prereqs {
    my($class, $spec) = @_;
    bless {
        phase => 'runtime',
        spec => $spec,
    }, $class;
}

sub new {
    bless {
        phase => 'runtime', # default phase
        features => {},
        feature => undef,
        spec  => {},
    }, shift;
}

sub on {
    my($self, $phase, $code) = @_;
    local $self->{phase} = $phase;
    $code->()
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
      = { identifier => $identifier, description => $description, spec => {} };
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
    ($self->{feature} ? $self->{feature}{spec} : $self->{spec})
      ->{$self->{phase}}{requires}{$module} = $self->requirement_for($module, @args);
}

sub recommends {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{spec} : $self->{spec})
      ->{$self->{phase}}{recommends}{$module} = $self->requirement_for($module, @args);
}

sub suggests {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{spec} : $self->{spec})
      ->{$self->{phase}}{suggests}{$module} = $self->requirement_for($module, @args);
}

sub conflicts {
    my($self, $module, @args) = @_;
    ($self->{feature} ? $self->{feature}{spec} : $self->{spec})
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
