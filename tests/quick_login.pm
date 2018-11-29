use base "installedtest";
use strict;
use testapi;
use utils;

# want to tweak the waits down a bit and use type_safely instead of
# type_very_safely for your test runs, just to save your time.

sub run {
    my $self = shift;
    # wait until the system boots   
    boot_to_login_screen(timeout=>120);
    # click on the user button
    assert_and_click 'system_user';
    wait_still_screen 2;
    # type password
    type_very_safely 'weakpassword';
    send_key 'ret';
    wait_still_screen 2;
    assert_screen 'workspace';
}

sub test_flags {
    return { fatal => 1, milestone => 1};
}

1;

# vim: set sw=4 et:
