use base "installedtest";
use strict;
use testapi;

sub run {
    my $self = shift;
    $self->root_console(tty=>3);
    script_run('top -i -n20 -b > /var/tmp/top.log', 120) ? record_soft_failure "top failed" : upload_logs '/var/tmp/top.log';
    script_run('rpm -qa --queryformat "%{NAME}\n" | sort -u > /var/tmp/rpms.log') ? record_soft_failure "rpm -qa failed" : upload_logs '/var/tmp/rpms.log';
    script_run('free > /var/tmp/free.log') ? record_soft_failure "free failed" : upload_logs '/var/tmp/free.log';
    script_run('df > /var/tmp/df.log') ? record_soft_failure "df failed" : upload_logs '/var/tmp/df.log';
    script_run('systemctl -t service --no-pager --no-legend | grep -o ".*\.service" > /var/tmp/services.log') ? record_soft_failure "systemctl service failed" : upload_logs '/var/tmp/services.log';
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    return {};
}

1;

# vim: set sw=4 et:
