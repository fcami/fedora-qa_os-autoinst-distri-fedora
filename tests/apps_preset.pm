use base "installedtest";
use strict;
use testapi;
use utils;

# want to tweak the waits down a bit and use type_safely instead of
# type_very_safely for your test runs, just to save your time.

sub run {
    my $self = shift;
    send_key 'alt-f2';
    # wait out animations
    wait_still_screen 2;
    # run the terminal
    type_very_safely 'gnome-terminal';
    send_key 'ret';
    wait_still_screen 2;
    # run command in it to set the background to black
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

sub test_flags {
    return { fatal => 1, milestone => 1 };
}

1;

# vim: set sw=4 et:
