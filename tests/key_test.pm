use base "installedtest";
use strict;
use testapi;

sub run {
    my $string = 'i~tjJ-$?-';
    my $match = 'i~tjJ-\$\?-';
    my $self=shift;
    $self->do_bootloader(postinstall=>0);
    assert_screen 'graphical_desktop_clean', 90;
    $self->menu_launch_type('terminal');
    wait_still_screen 5;
    # need to be root
    type_string "su\n", 4;
    wait_still_screen 3;
    type_string "printf '${string}' > /dev/ttyS0\n", 5;
    wait_serial "${match}" || die "died at 5";
    type_string "printf '${string}' > /dev/ttyS0\n", 35;
    wait_serial "${match}" || die "died at 35";
    type_string "printf '${string}' > /dev/ttyS0\n", 65;
    wait_serial "${match}" || die "died at 65";
    type_string "printf '${string}' > /dev/ttyS0\n", 95;
    wait_serial "${match}" || die "died at 95";
    type_string "printf '${string}' > /dev/ttyS0\n", 125;
    wait_serial "${match}" || die "died at 125";
    type_string "printf '${string}' > /dev/ttyS0\n", 155;
    wait_serial "${match}" || die "died at 155";
    type_string "printf '${string}' > /dev/ttyS0\n";
    wait_serial "${match}" || die "died at max";
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
