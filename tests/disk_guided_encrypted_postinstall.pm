use base "installedtest";
use strict;
use testapi;

sub run {
    # decrypt disks during boot

    # If KICKSTART is set, then the wait_time needs to
    #  consider the install time
    my $wait_time = get_var("KICKSTART") ? 1800 : 300;
    assert_screen "boot_enter_passphrase", $wait_time;
    type_string get_var("ENCRYPT_PASSWORD");
    send_key "ret";
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
