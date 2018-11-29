use base "installedtest";
use strict;
use testapi;
use utils;

# This test tests if Terminal starts (via using Activities and its prompt) and performs several tasks to  prove basic functionality of the application. 

sub run {
    my $self = shift;
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # start the application
    type_very_safely 'terminal';
    send_key 'ret';
    wait_still_screen 2;
    # When the application opens, run a command to see that it accepts commands
    type_very_safely 'ls /';
    send_key 'ret';
    wait_still_screen 2;
    assert_screen 'terminal_command_success';
    # close the application
    send_key 'alt-f4';
}

# If this test fails, the others will probably start failing too, 
# so there is no need to continue.
# Also, when subsequent tests fail, the suite will revert to this state for further testing.

#sub test_flags {
#    return { fatal => 1, milestone => 1 };
#}

1;

# vim: set sw=4 et:
