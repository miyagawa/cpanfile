# NAME

Module::CPANfile - Parse cpanfile

# SYNOPSIS

    use Module::CPANfile;

    my $file = Module::CPANfile->load("cpanfile");
    my $prereqs = $file->prereqs; # CPAN::Meta::Prereqs object

    my @features = $file->features; # CPAN::Meta::Feature objects
    my $merged_prereqs = $file->prereqs_with(@identifiers); # CPAN::Meta::Prereqs

    $file->merge_meta('MYMETA.json');

# DESCRIPTION

Module::CPANfile is a tool to handle [cpanfile](https://metacpan.org/pod/cpanfile) format to load application
specific dependencies, not just for CPAN distributions.

# METHODS

- load

        $file = Module::CPANfile->load;
        $file = Module::CPANfile->load('cpanfile');

    Load and parse a cpanfile. By default it tries to load `cpanfile` in
    the current directory, unless you pass the path to its argument.

- from\_prereqs

        $file = Module::CPANfile->from_prereqs({
          runtime => { requires => { DBI => '1.000' } },
        });

    Creates a new Module::CPANfile object from prereqs hash you can get
    via [CPAN::Meta](https://metacpan.org/pod/CPAN::Meta)'s `prereqs`, or [CPAN::Meta::Prereqs](https://metacpan.org/pod/CPAN::Meta::Prereqs)'
    `as_string_hash`.

        # read MYMETA, then feed the prereqs to create Module::CPANfile
        my $meta = CPAN::Meta->load_file('MYMETA.json');
        my $file = Module::CPANfile->from_prereqs($meta->prereqs);

        # load cpanfile, then recreate it with round-trip
        my $file = Module::CPANfile->load('cpanfile');
        $file = Module::CPANfile->from_prereqs($file->prereq_specs);
                                          # or $file->prereqs->as_string_hash

- prereqs

    Returns [CPAN::Meta::Prereqs](https://metacpan.org/pod/CPAN::Meta::Prereqs) object out of the parsed cpanfile.

- prereq\_specs

    Returns a hash reference that should be passed to `CPAN::Meta::Prereqs->new`.

- features

    Returns a list of features available in the cpanfile as [CPAN::Meta::Feature](https://metacpan.org/pod/CPAN::Meta::Feature).

- prereqs\_with(@identifiers), effective\_prereqs(\\@identifiers)

    Returns [CPAN::Meta::Prereqs](https://metacpan.org/pod/CPAN::Meta::Prereqs) object, with merged prereqs for
    features identified with the `@identifiers`.

- to\_string($include\_empty)

        $file->to_string;
        $file->to_string(1);

    Returns a canonical string (code) representation for cpanfile. Useful
    if you want to convert [CPAN::Meta::Prereqs](https://metacpan.org/pod/CPAN::Meta::Prereqs) to a new cpanfile.

        # read MYMETA's prereqs and print cpanfile representation of it
        my $meta = CPAN::Meta->load_file('MYMETA.json');
        my $file = Module::CPANfile->from_prereqs($meta->prereqs);
        print $file->to_string;

    By default, it omits the phase where there're no modules
    registered. If you pass the argument of a true value, it will print
    them as well.

- save

        $file->save('cpanfile');

    Saves the currently loaded prereqs as a new `cpanfile` by calling
    `to_string`. Beware **this method will overwrite the existing
    cpanfile without any warning or backup**. Taking a backup or giving
    warnings to users is a caller's responsibility.

        # Read MYMETA.json and creates a new cpanfile
        my $meta = CPAN::Meta->load_file('MYMETA.json');
        my $file = Module::CPANfile->from_prereqs($meta->prereqs);
        $file->save('cpanfile');

- merge\_meta

        $file->merge_meta('META.yml');
        $file->merge_meta('MYMETA.json', '2.0');

    Merge the effective prereqs with Meta specification loaded from the
    given META file, using CPAN::Meta. You can specify the META spec
    version in the second argument, which defaults to 1.4 in case the
    given file is YAML, and 2 if it is JSON.

- options\_for\_module

        my $options = $file->options_for_module($module);

    Returns the extra options specified for a given module as a hash
    reference. Returns `undef` when the given module is not specified in
    the `cpanfile`.

    For example,

        # cpanfile
        requires 'Plack', '1.000',
          dist => "MIYAGAWA/Plack-1.000.tar.gz";

        # ...
        my $file = Module::CPANfile->load;
        my $options = $file->options_for_module('Plack');
        # => { dist => "MIYAGAWA/Plack-1.000.tar.gz" }

# AUTHOR

Tatsuhiko Miyagawa

# SEE ALSO

[cpanfile](https://metacpan.org/pod/cpanfile), [CPAN::Meta](https://metacpan.org/pod/CPAN::Meta), [CPAN::Meta::Spec](https://metacpan.org/pod/CPAN::Meta::Spec)
