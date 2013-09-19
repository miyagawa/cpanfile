package Module::CPANfile::Requirement;
use strict;

sub as_hashref {
    my $self = shift;
    return +{ %$self };
}

sub new {
    my ($class, %args) = @_;

    # requires 'Plack';
    # requires 'Plack', '0.9970';
    # requires 'Plack', git => 'git://github.com/plack/Plack.git', rev => '0.9970';
    # requires 'Plack', '0.9970', git => 'git://github.com/plack/Plack.git', rev => '0.9970';

    $args{version} ||= 0;

    bless +{
        name    => $args{name},
        version => $args{version},
        (exists $args{git} ? (git => $args{git}) : ()),
        (exists $args{rev} ? (rev => $args{rev}) : ()),
    }, $class;
}

sub name    { shift->{name} }
sub version { shift->{version} }

sub git { shift->{git} }
sub rev { shift->{rev} }

1;
