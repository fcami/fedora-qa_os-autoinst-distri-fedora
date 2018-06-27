use base "installedtest";
use strict;
use testapi;
use utils;

sub run {
    my $self = shift;
    my $release = lc(get_var("VERSION"));
    my $relnum = $release;
    if ($release eq "rawhide") {
        $relnum = get_var("RAWREL", "rawhide");
    }
    
    # log as the test user
    script_run "su --login test";

    # switch back to the graphics
    send_key "ctrl-alt-f1";

    # login onto the system
    assert_screen "graphical_login";
    send_key "ret";
    assert_screen "graphical_login_input";
    my $password = get_var("USER_PASSWORD", "weakpassword");
    type_very_safely $password;
    send_key "ret";
    
    
    # handle bootloader, if requested; set longer timeout as sometimes
    # reboot here seems to take a long time
    if (get_var("GRUB_POSTINSTALL")) {
        do_bootloader(postinstall=>1, params=>get_var("GRUB_POSTINSTALL"), timeout=>120);
    }

    # decrypt, if encrypted
    if (get_var("ENCRYPT_PASSWORD")) {
        boot_decrypt(120);
        # in encrypted case we need to wait a bit so postinstall test
        # doesn't bogus match on the encryption prompt we just completed
        # before it disappears from view
        sleep 5;
    }
}


sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
