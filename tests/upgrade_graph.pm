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
    # disable screen blanking (download can take a long time)
    script_run "setterm -blank 0";


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
