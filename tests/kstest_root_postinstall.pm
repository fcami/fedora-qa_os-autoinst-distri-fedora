use base "installedtest";
use strict;
use testapi;

sub run {
    my $self=shift;
    if (not( check_screen "root_console", 0)) {
        $self->root_console(tty=>3);
    }
    # As a special case, we treat 'default fstype is incorrect (got xfs;
    # expected ext4)' as a pass when running the two 'default filesystem'
    # tests on Server images, because xfs is the default filesystem for
    # Server. This is complex to fix in the tests and I'm not sure
    # anaconda would accept the PR. We use a very precise match for this
    # case to make sure we don't pass if the /boot filesystem is wrong.
    # Using 'ISO' here is kind of a hack, we might want to pass in subv
    # from the scheduler for all jobs or something.
    my @elems = split('-', get_var('ISO'));
    my $subv = $elems[1];
    if (get_var('KSTEST_SERVER_FSTYPE') && $subv eq 'Server') {
        validate_script_output 'cat /root/RESULT', sub { $_ eq "default fstype is incorrect (got xfs; expected ext4)" };
    }
    else {
        # we can't use ^SUCCESS$ because sometimes there are messages
        # like 'SUCCESS but (some non-critical issue)'
        validate_script_output 'cat /root/RESULT', sub { $_ =~ m/^SUCCESS/ };
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
