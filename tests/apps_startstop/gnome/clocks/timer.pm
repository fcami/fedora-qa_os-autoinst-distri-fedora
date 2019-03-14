use base "installedtest";
use strict;
use testapi;
use utils;

# Use Timer.

sub run {
    my $self = shift;
    # Click on Timer
    assert_and_click 'clocks_button_stopwatch';
    wait_still_screen 2;
    # Start timer
    assert_and_click 'clocks_button_start';
    sleep 40;
    assert_and_click 'clocks_button_pause';
    # Check that the timer has run
    assert_screen 'clocks_check_minute';
    # Wait some time to see that the timer waits
    sleep 40;
    assert_screen 'clocks_check_minute';
    # Reset the timer
    assert_and_click 'clocks_button_reset';
    assert_screen 'clocks_check_treset';


}

sub test_flags {
    return {always_rollback => 1};
}

1;

# vim: set sw=4 et:
