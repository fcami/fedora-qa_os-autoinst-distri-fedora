use base "installedtest";
use strict;
use testapi;
use utils;

# This test checks that Evolution starts.

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # click on application icon
    assert_and_click 'apps_menu_evolution';
    wait_still_screen 2;
    # get rid of the welcome screen
    assert_and_click 'apps_run_evolution_welcome';
    wait_still_screen 2;
    
    assert_screen 'apps_run_evolution';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
