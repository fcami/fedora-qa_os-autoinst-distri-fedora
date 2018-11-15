use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks that Clocks starts.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # click on application icon
    assert_and_click 'apps_menu_clocks';
    wait_still_screen 2;
    # give access rights if asked
    if (check_screen('apps_run_access', 1)) {
        assert_and_click 'apps_run_access';
    }
    assert_screen 'apps_run_clocks';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
