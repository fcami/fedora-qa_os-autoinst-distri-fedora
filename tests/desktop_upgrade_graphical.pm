use base "installedtest";
use strict;
use testapi;
use utils;
use packagetest;

sub run {
    my $self = shift;
    my $desktop = get_var('DESKTOP');
    

    # this launches GNOME Software on GNOME, dunno for any other
    # desktop yet
    menu_launch_type('update');
    
    # GNOME Software has a welcome screen, get rid of it if it shows
    # up (but don't fail if it doesn't, we're not testing that)
    if ($desktop eq 'gnome' && check_screen 'gnome_software_welcome', 10) {
        send_key 'ret';
    }
    ## go to the 'update' interface. For GNOME, we may be waiting
    ## some time at a 'Software catalog is being loaded' screen.
    #if ($desktop eq 'gnome') {
    #    for my $n (1..5) {
    #        last if (check_screen 'desktop_package_tool_update', 120);
    #        mouse_set 10, 10;
    #        mouse_hide;
    #    }
    #}
    
    # If a banner appears that offers enablement of third party, discard it.
    if (check_screen('desktop_package_tool_thirdparty_enable', 60)) {
        assert_and_click 'desktop_package_tool_thirdparty_enable_cancel','left', 30;
    }
    wait_still_screen 2;

    
    # now click on the update button
    assert_and_click 'desktop_package_tool_update','left', 120;
    wait_still_screen 2;
    # a banner should inform about new version, download it
    assert_and_click 'desktop_package_tool_download','left', 1800;
    wait_still_screen 5;
    # after the download, Install the updates
    assert_and_click 'desktop_package_tool_install','left', 1800;
       
    # wait for refresh, then apply updates, using a C-style loop so we
    # can reset it if needed due to RHBZ #1314991
    #for (my $n = 1; $n < 6; $n++) {
        # Check if we see the 'cancelled by user action' error we get
        # when #1314991 happens, if so, refresh and restart the loop
            #sleep 100;
     #       $n = 1;
     #   }
     #   last if (assert_and_click 'desktop_package_tool_install', 120);
     #   mouse_set 10, 10;
     #   mouse_hide;
    # }
    
    # on GNOME, wait for reboots.
    if ($desktop eq 'gnome') {
        # handle reboot confirm screen which pops up
        
       type_very_safely(get_var('USER_PASSWORD','weakpassword'));
       assert_and_click('desktop_package_tool_authenticate','',60);

       assert_and_click('desktop_package_tool_restart','',30); 

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
}

sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
