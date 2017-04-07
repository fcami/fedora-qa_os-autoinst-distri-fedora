use base "installedtest";
use strict;
use testapi;

sub run {
    my $self=shift;
    if (not( check_screen "root_console", 0)) {
        $self->root_console(tty=>3);
    }
    assert_screen "root_console";
    # this test shows if the system is booted with efi
    assert_script_run '[ -d /sys/firmware/efi/ ]';
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
