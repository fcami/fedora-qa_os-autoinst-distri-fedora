use base "installedtest";
use strict;
use testapi;
use utils;

# Add and remove alarm in the Clocks application.

sub run {
    my $self = shift;
    # Click on Alarm
    assert_and_click 'clocks_button_alarm';
    assert_and_click 'clocks_button_new';
    wait_still_screen 2;
    # Set alarm to some time and name it
    type_very_safely '07';
    send_key 'tab';
    type_very_safely '28';
    send_key 'tab';
    type_very_safely 'MyAlarm';
    assert_and_click 'clocks_set_alarm';
    wait_still_screen 2;
    # Test that it was added.
    assert_screen 'clocks_alarm_added';

    # Select alarm
    assert_and_click 'clocks_select';
    assert_and_click 'clocks_alarm_added';
    # Remove alarm
    assert_and_click 'clocks_button_delete';
    wait_still_screen 2;
    # Test that it was removed.
    die "Alarm was not removed!" if (check_screen 'clocks_alarm_added', 1)
    
}

sub test_flags {
    return {always_rollback => 1};
}

1;

# vim: set sw=4 et:
