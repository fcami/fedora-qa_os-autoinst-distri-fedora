List of variables usable in tests
=================================

This list contains variables that are possible to set/redefine in WebUI and get their values in tests.
This document merges relevant variables from
[official documentation](https://github.com/os-autoinst/os-autoinst/blob/master/doc/backend_vars.asciidoc)
(backend variables), variables that control flow through `main.pm` (test variables) and variables that
are specified when ISO is posted into OpenQA (run variables).

Backend variables
-----------------
These variables control settings of underlying virtual machine where tests runs on. Some of them (`ARCH`, `QEMURAM`, ...) should be set per machine, others (`HDD_$i`, `HDDMODEL`, ...) should be set per test and some of them (`KEEPHDDS`, `MAKETESTSNAPSHOTS`, `SKIPTO`) should be set only during development and debugging.

| Variable | Values allowed | Default value | Explanation |
| -------- | :------------: | :-----------: | ----------- |
| `ARCH` | `x86_64`, `i686`, `aarch64`, ... | depends on tested medium | architecture of VM |
| `BIOS` | filename | `ovmf-x86_64-ms.bin` for `x86_64` UEFI, not set otherwise | set different BIOS |
| `BOOTFROM` | characters (see man qemu, `-boot order=` option) | not set | boot from different medium than CD |
| `CDMODEL` | see `qemu-kvm -device help` | not set/Qemu default | type of device for CD |
| `HDDMODEL` | see `qemu-kvm -device help` (e. g. PATA = `id-hd`, SATA = `ide-hd,bus-ahci0.0`, SCSI = `virtio-scsi-pci`) | `virtio-blk` | type of device for HDD |
| `HDDSIZEGB` | integer | `10` | size (in GBs) for disks that are created automatically |
| `HDD_$i` (`HDD_1, HDD_2`, ...) | filename | not set | attach additional HDD to VM |
| `ISO` | filename | not set | attach CD drive with ISO inserted |
| `ISO_$i` (`ISO_1`, `ISO_2`, ...) | filename | not set | additional CD drives to by attached |
| `KEEPHDDS` | boolean | `false`/not set | don't delete HDD after test finishes |
| `LAPTOP` | boolean or filename | `false`/not set | if `true`, Dell E6330 DMI is used; if set to filename, that file is used for DMI |
| `MAKETESTSNAPSHOTS` | boolean | `false`/not set | save snapshot for each test |
| `NOVIDEO` | boolean | `false`/not set | don't create video output if set |
| `NUMDISKS` | integer | 1 | number of disks to be created and attached to VM |
| `PXEBOOT` | boolean | `false`/not set | boot VM from PXE (network) |
| `QEMU` | filename, path to Qemu binary | not set | filename of Qemu binary |
| `QEMUCPU` | see `qemu-kvm -cpu help` | not set | CPU to emulate |
| `QEMUCPUS` | integer | 1 | number of processor cores to use for Qemu |
| `QEMURAM` | integer | 1024 | size of RAM to use (in MiB) |
| `QEMUTHREADS` | integer | 0 | number of CPU threads to use for Qemu |
| `QEMUVGA` | see `qemu-kvm -device help` | `cirrus` (should be set to `std` on Fedora, cirrus driver [was retired](https://lists.fedoraproject.org/pipermail/devel/2014-May/199459.html)) | display device to use for VM |
| `QEMU_COMPRESS_QCOW2` | boolean | `false`/not set | compress qcow2 images |
| `SKIPTO` | name of snapshot | not set | restore VM from given snapshot - better used with `MAKETESTSNAPSHOTS` |
| `UEFI` | boolean | `false`/not set | whether to use UEFI (UEFI BIOS files should be installed) |
| `UEFI_BIOS` | filename | `false`/not set, `ovmf-x86_64-ms.bin` when `UEFI` is set | filename of UEFI BIOS |
| `USBBOOT` | boolean | `false`/not set | if set, mount ISO as USB and boot from it |

For additional (kvm2usb, IPMI...) as well as for other Qemu variables, see
[official documentation](https://github.com/os-autoinst/os-autoinst/blob/master/doc/backend_vars.asciidoc).

Test variables
--------------
These variables control flow through `main.pm` - by setting them, you can alter what parts will be loaded.

There are certain tests that conflict each other. Note that conflict is always mutual, but for simplification
purposes, only one side of this conflict is shown (that means, if it's shown that `A` conflicts `B`,
it also means that `B` conflicts `A` even if not shown in the table).

| Variable | Values allowed | Default value/behavior | Conflicts | Explanation |
| -------- | :------------: | ---------------------- | :-------: | ----------- |
| `LIVE` | boolean | not set | technically `PACKAGE_SET`, `KICKSTART`, `MIRRORLIST_GRAPHICAL`, `REPOSITORY_GRAPHICAL`, `REPOSITORY_VARIATION` | specify that the test is running on Live system - additional steps are required (starting Anaconda...) |
| `PACKAGE_SET` | string (`minimal`, `default`, ...) | `minimal`; `default` when `LIVE` is set | nothing | sets packageset to install - you have to add appropriate needles, see `tests/_software_selection.pm` |
| `ENTRYPOINT` | filename | not set | N/A | set `ENTRYPOINT` to load specific test directly (bypass modular structure, mainly usable for testing) |
| `UPGRADE` | string (`minimal`, `desktop`, `encrypted`, ...) | not set | all except of `LIVE` and `USER_PASSWORD` | when set, do an upgrade test of specified type |
| `KICKSTART` | boolean | `false`/not set | all | when specified, do an kickstart installation (you should use `GRUB` variable to specify where kickstart file resides) |
| `MIRRORLIST_GRAPHICAL` | boolean | `false`/not set | `REPOSITORY_GRAPHICAL` | sets installation source to mirrorlist |
| `REPOSITORY_GRAPHICAL` | url to repository (without arch and `/os`, for example `http://dl.fedoraproject.org/pub/fedora/linux/development`) | not set | `MIRRORLIST_GRAPHICAL` | sets installation source to repository url in Anaconda |
| `REPOSITORY_VARIATION` | url to repository (without arch and `/os`, for example `http://dl.fedoraproject.org/pub/fedora/linux/development`) | not set | nothing | sets installation source to repository url in GRUB |
| `PARTITIONING` | string (`custom_software_raid`, `guided_delete_all`, ...) | `guided_empty` | nothing | load specified test for partitioning part (when `PARTITIONING=guided_delete_all`, `tests/disk_guided_delete_all.pm` is loaded) and optionally post-install partitioning check (if `tests/disk_guided_delete_all_postinstall.pm` exists, it will be loaded after login to the installed system). Also, if value starts with `custom_`, the `select_disks()` method will check the custom partitioning box |
| `ENCRYPT_PASSWORD` | string | not set | nothing | if set, encrypt disk with given password |
| `DESKTOP` | boolean | `false`/not set | nothing | set to indicate that Fedora is running with GUI (so for example OpenQA should expect graphical login screen) |
| `ROOT_PASSWORD` | string | `weakpassword` | nothing | root password is set to this value |
| `GRUB` | string | not set | nothing | when set, append this string to kernel line in GRUB |
| `USER_LOGIN` | string | not set | should be used with `USER_PASSWORD` | when set, user login is set to this value |
| `USER_PASSWORD` | string | not set | should be used with `USER_LOGIN` | when set, user password is set to this value |
| `BOOT_UPDATES_IMG_URL` | boolean | `false`/not set | set to indicate that path to updates.img was appended to kernel line |

Run variables
-------------
These variables should be set when tests are scheduled (when running `isos post`).

| Variable | Explanation |
| -------- | ----------- |
| `ISO` | contains filename of ISO that is used for booting |
| `DISTRI` | contains distribution name (should be same as in WebUI, probably `fedora`) |
| `VERSION` | contains version of distribution |
| `FLAVOR` | indicates what type of distribution is used (`universal`, `generic_boot`, `workstation_live`, `server_boot`) |
| `ARCH` | is set to architecture that will be used (`x86_64`, `i686`) |
| `BUILD` | contains string `vv_tt_bb`, where `vv` is fedora version number, `tt` is release name (`Beta`, `Final`, ...) and `bb` is build (`RC3`, ...) |