use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks that Disks starts.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # go to the second screen
    unless (check_screen('apps_menu_utilities', 1)) {
        assert_and_click 'apps_go_second';
        wait_still_screen 2;
    }
    # click on Utilities where it is hidden
    assert_and_click 'apps_menu_utilities';
    wait_still_screen 2;
    # click on application icon
    assert_and_click 'apps_menu_disks';
    wait_still_screen 2;
    assert_screen 'apps_run_disks';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
