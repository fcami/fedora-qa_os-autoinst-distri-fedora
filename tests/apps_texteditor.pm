use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks that Text Editor starts.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # if the icon is not on the screen, go to the next one
    unless (check_screen('apps_menu_texteditor', 1)) {
        assert_and_click 'apps_go_second';
        wait_still_screen 2;
    }
    # click on application icon
    assert_and_click 'apps_menu_texteditor';
    wait_still_screen 2;
    assert_screen 'apps_run_texteditor';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
