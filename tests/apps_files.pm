use base "installedtest";
use strict;
use testapi;
use utils;

# This tests if Files starts 

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # click on icon button to get the list of icons
    assert_and_click 'apps_activities';
    wait_still_screen 2;
    # click on Files icon
    assert_and_click 'apps_menu_files';
    wait_still_screen 2;
    assert_screen 'apps_run_files';
    # close the application
    send_key 'alt-f4';
    wait_still_screen 2;
    assert_screen 'workspace';
    
}

1;

# vim: set sw=4 et:
