use base "installedtest";
use strict;
use testapi;
use utils;

# Use stopwatch.

sub run {
    my $self = shift;
    # Click on Stopwatch
    assert_and_click 'clocks_button_stopwatch';
    wait_still_screen 2;
    # Start stopwatch
    assert_and_click 'clocks_button_start';
    sleep 20;
    assert_and_click 'clocks_button_stop';
    # Check that the stopwatch has run
    assert_screen 'clocks_check_twenty';
    # Continue stopwatch
    assert_and_click 'clocks_button_continue';
    sleep 10;
    assert_and_click 'clocks_button_stop';
    # Check that it has run
    assert_screen 'clocks_check_thirty';
    # Reset the stopwatch
    assert_and_click 'clocks_button_reset';
    assert_screen 'clocks_check_reset';

}

sub test_flags {
    return {always_rollback => 1};
}

1;

# vim: set sw=4 et:
