use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks whether Firefox starts when clicking the icon
# in the activity menu. It does not test any other functionality.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # start the application
    assert_and_click 'apps_menu_firefox';
    wait_still_screen 2;
    # check that the applicatin is running
    assert_screen 'apps_run_firefox';
    # close the application
    send_key 'alt-f4';
    # deal with warning screen
    assert_and_click 'apps_run_firefox_stop';
    wait_still_screen 2;
    # check that the application has stopped
    assert_screen 'apps_settings_screen_black';
}

1;

# vim: set sw=4 et:
