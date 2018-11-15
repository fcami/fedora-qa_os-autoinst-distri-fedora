use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks that Software starts.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # if the icon is not on the screen, go to the next one
    unless (check_screen('apps_menu_software', 1)) {
        assert_and_click 'apps_go_second';
        wait_still_screen 2;
    }
    # click on application icon
    assert_and_click 'apps_menu_software';
    wait_still_screen 2;
    # check if a welcome screen appears, if so, click on it
    if (check_screen('apps_run_software_welcome', 1)) {
        assert_and_click 'apps_run_software_welcome';
        wait_still_screen 2;
    }
    assert_screen 'apps_run_software';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
