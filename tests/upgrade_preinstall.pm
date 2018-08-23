use base "installedtest";
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    # upgrader should be installed on up-to-date system
    # assert_script_run 'dnf -y update --refresh', 1800;
    script_run "reboot", 0;

    # handle bootloader, if requested
    if (get_var("GRUB_POSTINSTALL")) {
        do_bootloader(postinstall=>1, params=>get_var("GRUB_POSTINSTALL"), timeout=>120);
    }

    # decrypt if necessary
    if (get_var("ENCRYPT_PASSWORD")) {
        boot_decrypt(120);
    }

    boot_to_login_screen;
    $self->root_console(tty=>3);

    my $update_command = 'dnf -y install dnf-plugin-system-upgrade';
    assert_script_run $update_command, 600;

    # I want to use this test in a suite where it is not followed by a console based module,
    # but rather a graphical screen. Therefore, if a booted system with login screen 
    # is required, switch to graphical terminal.
    if (get_var("ASSUME_BOOT",0) == 1) {
        desktop_vt;
    }
}


sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
