use base "installedtest";
use strict;
use testapi;
use utils;
use packagetest;

sub run {
    my $self = shift;
    my $desktop = get_var('DESKTOP');
    # use a tty console for repo config and package prep
    $self->root_console(tty=>3);
    # TEST TEST let's get some debuggin' action in
    assert_script_run "sed -i -e 's,packagekitd,packagekitd --verbose,g' /usr/lib/systemd/system/packagekit.service";
    assert_script_run "systemctl daemon-reload";
    assert_script_run "systemctl restart packagekit.service";
    assert_script_run 'dnf config-manager --set-disabled updates-testing';
    # TEST TEST hacked-up gnome-software
    if (get_var("VERSION") eq "28" && get_var("ARCH") eq "x86_64") {
        assert_script_run "dnf -y update https://kojipkgs.fedoraproject.org//work/tasks/8041/30188041/gnome-software-3.28.2-3.8.fc28.x86_64.rpm";
    }
    prepare_test_packages;
    # get back to the desktop
    desktop_vt;
    # run the updater
    if ($desktop eq 'kde') {
        # KDE team tells me the 'preferred' update method is the
        # systray applet
        assert_and_click 'desktop_expand_systray';
    }
    else {
        # this launches GNOME Software on GNOME, dunno for any other
        # desktop yet
        #sleep 3;
        #menu_launch_type('update');
        # TEST TEST ok let's not do that let's do this to run with
        # --verbose, stolen from desktop_terminal
        menu_launch_type('terminal');
        wait_still_screen 5;
        type_string "killall gnome-software\n", 20;
        sleep 5;
        type_string "gnome-software --verbose > /home/test/gs.log 2>&1\n", 20;
    }
    # GNOME Software has a welcome screen, get rid of it if it shows
    # up (but don't fail if it doesn't, we're not testing that)
    if ($desktop eq 'gnome' && check_screen 'gnome_software_welcome', 10) {
        send_key 'ret';
    }
    # go to the 'update' interface. For GNOME, we may be waiting
    # some time at a 'Software catalog is being loaded' screen.
    if ($desktop eq 'gnome') {
        for my $n (1..5) {
            last if (check_screen 'desktop_package_tool_update', 120);
            mouse_set 10, 10;
            mouse_hide;
        }
    }
    assert_and_click 'desktop_package_tool_update';
    # if this is KDE and it had already noticed the notification, we
    # will already have the apply button at this point
    unless (check_screen 'desktop_package_tool_update_apply', 5) {
        # refresh updates
        assert_and_click 'desktop_package_tool_update_refresh', '', 120;
    }
    # wait for refresh, then apply updates, moving the mouse every two
    # minutes to avoid the idle screen blank kicking in. We use a C-
    # style loop so we can reset it if needed due to RHBZ #1638563. We
    # will retry a max of two times if we hit refresh and wind up
    # being told the system is up to date.
    my $retries = 2;
    for (my $n = 1; $n < 6; $n++) {
        if (check_screen ['desktop_package_tool_update_apply', 'desktop_package_tool_uptodate'], 120) {
            # if we see 'apply', we're done here, quit out of the loop
            last if (match_has_tag 'desktop_package_tool_update_apply');
            # otherwise, we hit uptodate, which is the bug case
            if ($retries == 2) {
                # only record the soft fail on the *first* retry
                record_soft_failure "Refresh did not find available update - #1638563. Retrying";
            }
            if ($retries > 0) {
                assert_and_click 'desktop_package_tool_update_refresh';
                # reset the loop counter so we get another 10 minutes
                $n = 1;
            }
            else {
                die "Retried refresh too many times, giving up";
            }
            $retries -= 1;
        }
        # move the mouse to stop the screen blanking on idle
        mouse_set 10, 10;
        mouse_hide;
    }
    # KDE annoyingly pops the notification up right over the install
    # button, which doesn't help...wait for it to go away. Let's also
    # wait on GNOME, as we've had tests fail at this point for no
    # obvious reason, a wait may help.
    wait_still_screen 5;
    assert_and_click 'desktop_package_tool_update_apply';
    # on GNOME, wait for reboots.
    if ($desktop eq 'gnome') {
        # handle reboot confirm screen which pops up when user is
        # logged in (but don't fail if it doesn't as we're not testing
        # that)
        if (check_screen 'gnome_reboot_confirm', 15) {
            # on F27+, default is Cancel, earlier, default is Restart
            my $version = lc(get_var("VERSION"));
            send_key 'tab' if ($version eq 'rawhide' || $version > 26);
            send_key 'ret';
        }
        boot_to_login_screen;
    }
    else {
        # KDE will prompt for authentication if any package is not
        # signed. As of 2016-09-23, puiterwijk claims Rawhide packages
        # will be autosigned 'by Monday', so if this happens, we're
        # going to treat it as a soft fail, indicating the update
        # mechanism works, but a package that should have been signed
        # was not.
        assert_screen ['desktop_package_tool_update_done', 'desktop_package_tool_update_authenticate'], 180;
        if (match_has_tag('desktop_package_tool_update_authenticate')) {
            record_soft_failure;
            type_very_safely get_var('USER_PASSWORD', 'weakpassword');
            send_key 'ret';
            assert_screen 'desktop_package_tool_update_done', 180;
        }
    }
    # back to console to verify updates
    $self->root_console(tty=>3);
    verify_updated_packages;
    # TEST TEST we need logs from a success case...
    $self->post_fail_hook();
}

sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
