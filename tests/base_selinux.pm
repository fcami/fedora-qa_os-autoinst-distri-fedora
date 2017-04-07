use base "installedtest";
use strict;
use testapi;

sub run {
    my $self=shift;
    # switch to TTY3 for both, graphical and console tests
    $self->root_console(tty=>3);
    validate_script_output 'getenforce', sub { $_ =~ m/Enforcing/ };
}


sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
