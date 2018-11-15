use base "installedtest";
use strict;
use testapi;
use utils;

# This test tests if Terminal starts and uses it to change desktop settings for all the following tests.
# Therefore, if you want to use all the tests from the APPS family, this should be the very first to do.

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
    assert_and_click 'apps_menu_terminal';
    wait_still_screen 2;
    # When the application opens, run command in it to set the background to black
    type_very_safely "gsettings set org.gnome.desktop.background picture-uri ''";
    send_key 'ret';
    wait_still_screen 2;
    type_very_safely "gsettings set org.gnome.desktop.background primary-color '#000000'";
    send_key 'ret';
    wait_still_screen 2;
    send_key 'alt-f4';
    # check that is has changed color
    assert_screen 'apps_settings_screen_black';
}

# If this test fails, the others will probably start failing too, 
# so there is no need to continue.
# Also, when subsequent tests fail, the suite will revert to this state for further testing.
sub test_flags {
    return { fatal => 1, milestone => 1 };
}

1;

# vim: set sw=4 et:
