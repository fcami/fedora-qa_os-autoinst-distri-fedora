use base "installedtest";
use strict;
use testapi;
use utils;

# This test will test the basic functionality of Nautilus. 
# Nautilus is one of the core applications. Preferably this test should
# be one of several that will be chained in order to test
# the core applications in Fedora Workstation.
 
sub run {
    my $self = shift;
    check_desktop_clean;
    # switch on the activity screen
    send_key 'alt-f1';
    # wait out animations
    wait_still_screen 2;
    # run the application and check that the window appears
    assert_and_click 'nautilus_launcher';
    wait_still_screen 2;
    # enter one of thhe directories 
    assert_and_click 'directory_chosen';
    send_key 'ret';
    # create a new directory using the keyboard shortcut
    send_key 'ctrl-shift-n';
    wait_still_screen 2;
    # check that the new folder dialogue box appears,
    # type the folder name and press enter
    assert_screen 'new_folder_dialogue';
    type_very_safely "testing";
    send_key 'ret';
    wait_still_screen 2;
    # check that the directory has been created
    assert_screen 'directory_created';
    # rename the folder, check for the rename window,
    # type the new folder name and press the button,
    # check that it has been renamed
    send_key 'f2';
    assert_screen 'rename_dialogue';
    type_very_safely "renamed";
    assert_and_click 'rename_button';
    assert_screen 'directory_renamed';
    # test the search button
    assert_and_click 'search_button';
    assert_screen 'search_field';
    assert_and_click 'search_button';
    # check the toggle view
    assert_and_click 'toggle_view_button';
    assert_screen 'toggled_view';
    # choose the directory and delete it
    assert_and_click 'new_directory_chosen';
    send_key 'delete';
    assert_screen 'folder_empty';
    # undo the deletion and check that the directory
    # appears again at the same place
    assert_and_click 'open_menu';
    assert_and_click 'undo_trash';
    assert_screen 'undone_trash';
    # rightclick on the directory to open the menu
    # and star the directory. check that it appears
    # in the Starred folder.
    assert_and_click 'directory_line','right';
    assert_and_click 'star';
    assert_screen 'is_starred';
    assert_and_click 'starred_button';
    assert_screen 'is_starred_dir';
    # unstar the directory and check that it disappears
    # from the Starred directory again
    assert_and_click 'starred_directory_line','right';
    assert_and_click 'unstar';
    assert_screen 'gone_from_starred';
    # Check the left menu functions by
    # clicking on Home to navigate to the Home directory
    assert_and_click 'home_button';
    assert_screen 'homedir';
    # Close the application via the Exit icon 
    # and check that it finished.
    assert_and_click 'exit_button';
    assert_screen 'nautilus_quit'
}

sub test_flags {
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
