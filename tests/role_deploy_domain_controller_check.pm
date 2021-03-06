use base "installedtest";
use strict;
use testapi;
use lockapi;
use mmapi;

sub run {
    my $self = shift;
    # make sure ipa.service actually came up successfully
    my $count = 40;
    while (1) {
        $count -= 1;
        die "Waited too long for ipa.service to show up!" if ($count == 0);
        sleep 3;
        # if it's active, we're done here
        last unless script_run 'systemctl is-active ipa.service';
        # if it's not...fail if it's failed
        assert_script_run '! systemctl is-failed ipa.service';
        # if we get here, it's activating, so loop around
    }
    # if this is an update, notify clients that we're now up again
    mutex_create('server_upgraded') if get_var("UPGRADE");
    # from here we branch: for F28 and earlier we use rolekit as
    # always, for F29+ we decommission directly ourselves as rolekit
    # is deprecated
    my $version = get_var("VERSION");
    if ($version < 29 && $version ne 'Rawhide') {
        # check the role status, should be 'running'
        validate_script_output 'rolectl status domaincontroller/domain.local', sub { $_ =~ m/^running/ };
        # check the admin password is listed in 'settings'
        validate_script_output 'rolectl settings domaincontroller/domain.local', sub {$_ =~m/dm_password = \w{5,}/ };
        # sanitize the settings
        assert_script_run 'rolectl sanitize domaincontroller/domain.local';
        # check the password now shows as 'None'
        validate_script_output 'rolectl settings domaincontroller/domain.local', sub {$_ =~ m/dm_password = None/ };
        # once child jobs are done, stop the role
        wait_for_children;
        # run post-fail hook to upload logs - even when this test passes
        # there are often cases where we need to see the logs (e.g. client
        # test failed due to server issue)
        $self->post_fail_hook();
        assert_script_run 'rolectl stop domaincontroller/domain.local';
        # check role is stopped
        validate_script_output 'rolectl status domaincontroller/domain.local', sub { $_ =~ m/^ready-to-start/ };
        # decommission the role
        assert_script_run 'rolectl decommission domaincontroller/domain.local', 300;
        # check role is decommissioned
        validate_script_output 'rolectl list instances', sub { $_ eq "" };
    }
    else {
        # once child jobs are done, stop the server
        wait_for_children;
        # run post-fail hook to upload logs - even when this test passes
        # there are often cases where we need to see the logs (e.g. client
        # test failed due to server issue)
        $self->post_fail_hook();
        assert_script_run 'systemctl stop ipa.service';
        # check server is stopped
        assert_script_run '! systemctl is-active ipa.service';
        # decommission the server
        assert_script_run 'ipa-server-install -U --uninstall', 300;
        # try and un-garble the screen that the above sometimes garbles
        # ...we may be on tty1 or tty3 now, so flip between them
        send_key "ctrl-alt-f1";
        send_key "ctrl-alt-f3";
        # FIXME check server is decommissioned...how?
    }
}


sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
