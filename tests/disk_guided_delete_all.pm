use base "basetest";
use strict;
use testapi;

sub run {
    # Anaconda hub
    assert_screen "anaconda_main_hub", 300; #

    # Default install destination (hdd should be empty for new KVM machine)
    assert_and_click "anaconda_main_hub_install_destination"; 

    assert_and_click "anaconda_spoke_done";

    assert_and_click "anaconda_install_destination_reclaim_space_btn";

    assert_and_click "anaconda_install_destination_delete_all_btn";

    assert_and_click "anaconda_install_destination_reclaim_space_btn";

    # Anaconda hub
    assert_screen "anaconda_main_hub", 300; #

}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
