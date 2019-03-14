use base "installedtest";
use strict;
use testapi;
use utils;

# Add and remove new world clock in the application.

sub run {
    my $self = shift;
    # Add a new clock
    # Click on New
    assert_and_click 'clocks_button_new';
    wait_still_screen 2;
    # Write a location to add and select it
    type_very_safely 'alexandria';
    assert_and_click 'clocks_search_city';
    assert_and_click 'clocks_add_city';
    # Test that it was added.
    assert_screen 'clocks_city_added';

    # Remove the new clock
    # Click on selection button
    assert_and_click 'clocks_select';
    # Select previously added clock
    assert_and_click 'clocks_city_added';
    # Delete it
    assert_and_click 'clocks_button_delete';
    # Check that it disappeared
    die "The clock has not been deleted!" if (check_screen 'clocks_city_added', 1);
    
}

sub test_flags {
    return {always_rollback => 1};
}

1;

# vim: set sw=4 et:
