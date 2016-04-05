use base "fedorabase";
use strict;
use testapi;

sub _map_string {
    my $self = shift;
    my $string = shift;
    if (get_var("LOGIN_KEYMAP")) {
        $string = $self->keymap_string($string, get_var("LOGIN_KEYMAP"));
    }
    return $string;
}

sub run {
    my $self = shift;

    # If KICKSTART is set and ENCRYPT_PASSWORD is not, then the
    # wait_time needs to consider the install time
    my $wait_time = (get_var("KICKSTART") && !(get_var("ENCRYPT_PASSWORD"))) ? 1800 : 300;

    # FORCE_CONSOLE_LOGIN tells us to wait for a graphical login
    # then switch to a console
    if (get_var("FORCE_CONSOLE_LOGIN")) {
        assert_screen "graphical_login", $wait_time;
        $wait_time = 20;
        send_key "ctrl-alt-f3";
    }

    # Wait for the text login
    assert_screen "text_console_login", $wait_time;

    # do user login unless USER_LOGIN is set to string 'false'
    my $user = get_var("USER_LOGIN", "test");
    unless ($user eq "false") {
        my $userpass = get_var("USER_PASSWORD", "weakpassword");
        $self->console_login(user=>$self->_map_string($user), password=>$self->_map_string($userpass));
    }
    if (get_var("ROOT_PASSWORD")) {
        $self->console_login(user=>$self->_map_string("root"), password=>$self->_map_string(get_var("ROOT_PASSWORD")));
    }
    # if requested, load US keymap.
    if (get_var("LOADKEYS")) {
        type_string $self->_map_string("loadkeys us\n");
    }
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1, milestone => 1 };
}

1;

# vim: set sw=4 et:
