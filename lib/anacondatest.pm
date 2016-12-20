package anacondatest;
use base 'fedorabase';

# base class for all Anaconda (installation) tests

# should be used in tests where Anaconda is running - when it makes sense
# to upload Anaconda logs when something fails

use testapi;
use main_common;

sub post_fail_hook {
    my $self = shift;

    # if error dialog is shown, click "report" - it then creates directory structure for ABRT
    my $has_traceback = 0;
    if (check_screen "anaconda_error", 10) {
        assert_and_click "anaconda_error_report";
        $has_traceback = 1;
    } elsif (check_screen "anaconda_text_error", 10) {  # also for text install
        type_string "1\n";
        $has_traceback = 1;
    }

    save_screenshot;
    $self->root_console();
    upload_logs "/tmp/X.log", failok=>1;
    upload_logs "/tmp/anaconda.log", failok=>1;
    upload_logs "/tmp/packaging.log", failok=>1;
    upload_logs "/tmp/storage.log", failok=>1;
    upload_logs "/tmp/syslog", failok=>1;
    upload_logs "/tmp/program.log", failok=>1;
    upload_logs "/tmp/dnf.log", failok=>1;
    upload_logs "/tmp/dnf.librepo.log", failok=>1;
    upload_logs "/tmp/dnf.rpm.log", failok=>1;

    if ($has_traceback) {
        # Upload Anaconda traceback logs
        script_run "tar czf /tmp/anaconda_tb.tar.gz /tmp/anaconda-tb-*";
        upload_logs "/tmp/anaconda_tb.tar.gz";
    }

    # Upload all ABRT logs (if there are any)
    unless (script_run 'test -n "$(ls -A /var/tmp)" && tar czf /var/tmp/var_tmp.tar.gz /var/tmp') {
        upload_logs "/var/tmp/var_tmp.tar.gz";
    }

    # Upload /var/log
    unless (script_run "tar czf /tmp/var_log.tar.gz /var/log") {
        upload_logs "/tmp/var_log.tar.gz";
    }

    # Upload anaconda core dump, if there is one
    unless (script_run "ls /tmp/anaconda.core.* && tar czf /tmp/anaconda.core.tar.gz /tmp/anaconda.core.*") {
        upload_logs "/tmp/anaconda.core.tar.gz";
    }
}

sub root_console {
    my $self = shift;
    my %args = (
        @_);

    if (get_var("LIVE")) {
        send_key "ctrl-alt-f2";
    }
    else {
        # Working around RHBZ 1222413, no console on tty2
        send_key "ctrl-alt-f1";
        send_key "ctrl-b";
        send_key "2";
    }
    console_login(user=>"root");
}

sub select_disks {
    my $self = shift;
    my %args = (
        disks => 1,
        iscsi => {},
        @_
    );
    my %iscsi = %{$args{iscsi}};
    # Anaconda hub
    assert_screen "anaconda_main_hub", 300; #
    # Damn animation delay can cause bad clicks here too - wait for it
    sleep 1;
    assert_and_click "anaconda_main_hub_install_destination";

    if (get_var('NUMDISKS') > 1) {
        # Multi-disk case. Select however many disks the test needs. If
        # $disks is 0, this will do nothing, and 0 disks will be selected.
        for my $n (1 .. $args{disks}) {
            assert_and_click "anaconda_install_destination_select_disk_$n";
        }
    }
    else {
        # Single disk case.
        if ($args{disks} == 0) {
            # Clicking will *de*-select.
            assert_and_click "anaconda_install_destination_select_disk_1";
        }
        elsif ($args{disks} > 1) {
            die "Only one disk is connected! Cannot select $args{disks} disks.";
        }
        # For exactly 1 disk, we don't need to do anything.
    }

    # Handle network disks.
    if (%iscsi) {
        assert_and_click "anaconda_install_destination_add_network_disk";
        foreach my $target (keys %iscsi) {
            my $ip = $iscsi{$target}->[0];
            my $user = $iscsi{$target}->[1];
            my $password = $iscsi{$target}->[2];
            assert_and_click "anaconda_install_destination_add_iscsi_target";
            wait_still_screen 2;
            type_safely $ip;
            wait_screen_change { send_key "tab"; };
            type_safely $target;
            # start discovery - three tabs, enter
            type_safely "\t\t\t\n";
            if ($user && $password) {
                assert_and_click "anaconda_install_destination_target_auth_type";
                assert_and_click "anaconda_install_destination_target_auth_type_chap";
                send_key "tab";
                type_safely $user;
                send_key "tab";
                type_safely $password;
            }
            assert_and_click "anaconda_install_destination_target_login";
            assert_and_click "anaconda_install_destination_select_target";
        }
        assert_and_click "anaconda_spoke_done";
    }

    # If this is a custom partitioning test, select custom partitioning.
    if (get_var('PARTITIONING') =~ /^custom_/) {
        assert_and_click "anaconda_manual_partitioning";
    }
}

sub custom_scheme_select {
    my ($self, $scheme) = @_;
    assert_and_click "anaconda_part_scheme";
    # Move the mouse away from the menu
    mouse_set(10, 10);
    assert_and_click "anaconda_part_scheme_$scheme";
}

sub custom_change_type {
    my ($self, $type, $part) = @_;
    $part ||= "root";
    assert_and_click "anaconda_part_select_$part";
    assert_and_click "anaconda_part_device_type";
    # Move the mouse away from the menu
    mouse_set(10, 10);
    assert_and_click "anaconda_part_device_type_$type";
    assert_and_click "anaconda_part_update_settings";
}

sub custom_change_fs {
    my ($self, $fs, $part) = @_;
    $part ||= "root";
    assert_and_click "anaconda_part_select_$part";
    # if fs is already set correctly, do nothing
    return if (check_screen "anaconda_part_fs_${fs}_selected", 5);
    assert_and_click "anaconda_part_fs";
    # Move the mouse away from the menu
    mouse_set(10, 10);
    assert_and_click "anaconda_part_fs_$fs";
    assert_and_click "anaconda_part_update_settings";
}

sub custom_change_device {
    my ($self, $part, $devices) = @_;
    assert_and_click "anaconda_part_select_$part";
    assert_and_click "anaconda_part_device_modify";
    foreach my $device (split(/ /, $devices)) {
        assert_and_click "anaconda_part_device_${device}";
    }
    assert_and_click "anaconda_part_device_select";
    assert_and_click "anaconda_part_update_settings";
}

sub custom_delete_part {
    my ($self, $part) = @_;
    return if not $part;
    assert_and_click "anaconda_part_select_$part";
    assert_and_click "anaconda_part_delete";
}

sub get_full_repo {
    my ($self, $repourl) = @_;
    # trivial thing we kept repeating: fill out an HTTP or HTTPS
    # repo URL with flavor and arch, leave NFS ones alone (as for
    # NFS tests we just use a mounted ISO and the URL is complete)
    if ($repourl !~ m/^nfs/) {
        $repourl .= "/Everything/".get_var("ARCH")."/os";
    }
    return $repourl;
}

sub get_mirrorlist_url {
    return "mirrors.fedoraproject.org/mirrorlist?repo=fedora-" . lc(get_var("VERSION")) . "&arch=" . get_var('ARCH')
}

1;

# vim: set sw=4 et:
