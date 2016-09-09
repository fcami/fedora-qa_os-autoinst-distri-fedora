use base "anacondatest";
use strict;
use testapi;

sub post_fail_hook {
    my $self = shift;
    return;
}

sub run {
    my $self = shift;
    # call do_bootloader with postinstall=0, the params
    #$self->do_bootloader(postinstall=>0, params=>'inst.updates=https://www.happyassassin.net/updates/bgo771127.img');
    $self->do_bootloader(postinstall=>0);

    # go to anaconda
    assert_screen "anaconda_select_install_lang", 300;
    # disable animations
    send_key "ctrl-shift-i";
    assert_and_click "ok_button";
    assert_and_click "inspector_visual";
    send_key_until_needlematch 'inspector_animations', 'down';
    send_key 'right';
    send_key 'spc';
    assert_and_click "inspector_close";
    assert_and_click "anaconda_select_install_lang_continue";
    assert_and_click "anaconda_rawhide_accept_fate";
    assert_and_click "anaconda_main_hub_select_packages";
    send_key "tab";
    send_key "tab";
    wait_still_screen 3;
    for my $n (1..100) {
        send_key "down";
        send_key "spc";
        wait_still_screen 1;
        assert_screen "anaconda_minimal_selected", 5;
        send_key "up";
        send_key "spc";
        wait_still_screen 1;
    }
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
