# Termux Filesystem Layout

The following docs provide info on Android and Termux paths, and their differences. It additionally details the limitations for Termux to provide a [Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) compliant filesystem and related issues for Linux [`syscalls(2)`](https://man7.org/linux/man-pages/man2/syscalls.2.html).

### Contents

- [Android Paths](#android-paths)
- [Termux Paths](#termux-paths)
- [File Path Limits](#file-path-limits)

---

&nbsp;





## Android Paths

### Android Rootfs Directory

The Android filesystem rootfs and home (`$HOME`) directory exists at `/`. It contains a number of directories, some of them are [FHS-compliant](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard). Most of the directories are not accessible to third party apps, which can only access their own private app data directories or optionally the external/public storage directories if they have been granted storage permissions. Some directories like `/system` are read-only by default to provide a secure environment for apps to run in. Users and packages should never attempt to modify such directories, even with root, unless you know what you are doing, otherwise security checks depending on Android version will prevent the phone from booting.

|          Path          |                                                        Description                                                        |
|------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `/`                    | The filesystem rootfs. Usually it is a ramdisk, but on modern Android OS versions it is a mounted system partition. Can be restricted by SELinux and not be viewable by `ls`. |
| `/bin`                 | Symlink to `/system/bin`. Do not add this to `$PATH` to prevent conflicts of Termux utilities with ones provided by Android. |
| `/data`                | The data partition of the internal sd card of the device that stores app and system data.                                 |
| `/data/app`            | App APKs and native libraries for 3rd party apps. |
| `/data/data`           | Private app data directory for apps installed on primary user `0` for both system and 3rd party apps.                     |
| `/data/user/<user_id>` | Private app data directory for apps installed on primary and secondary users for both system and 3rd party apps. The `/data/user/0` is normally either a symlink or bind mount to `/data/data` depending on Android version. |
| `/dev`                 | [Device files](https://en.wikipedia.org/wiki/Device_file). Access can be restricted by SELinux, though all important world-writable devices are accessible. |
| `/etc`                 | Symlink to `/system/etc`.                                                                                                 |
| `/mnt`                 | Raw mount points of filesystems for internal and external sd cards. ([1](https://github.com/termux/termux-app/issues/71#issuecomment-1869222653)) |
| `/proc`                | Standard directory with runtime process and kernel information. Typically mounted with `hidepid=2` option for privacy.    |
| `/proc/net`            | Networking interface statistics. Access restricted since Android `10` for privacy reasons.                                |
| `/sbin`                | Directory where special-purpose executables (ADB daemon, dm-verity helper, modem nvram loader, etc). Access is restricted by SELinux and file modes. Do not add this directory to `$PATH`. |
| `/storage`             | External storage mount points accessible to apps with storage permissions. Like `/mnt`, but drive filesystems are provisioned by `sdcardfs` or `fuse` daemon. ([1](https://github.com/termux/termux-app/issues/71#issuecomment-1869222653)) |
| `/system`              | The Android OS system root.                                                                                         |
| `/system/app`          | App APKs and native libraries for system apps.                                                                            |
| `/system/bin`          | [System executables](#android-bin-directory) for system purposes and fully-functional ADB shell. Avoid adding this to `$PATH` to prevent conflicts of Termux utilities with ones provided by Android. Exceptions are allowed only for alternate executable paths, e.g. in case if package is not installed.                                                                            |
| `/system/lib`          | [System libraries](#android-lib-directory).                                                                               |
| `/system/priv-app`     | App APKs and native libraries for privileged system apps.                                                                 |
| `/system/xbin`         | Optional set of system command line tools. Content may vary between ROMs. Do not add this to `$PATH`.                     |

##### Android Bin Directory

The Android system provided executables primarily exist under `/system/bin` that are part of AOSP itself that should exist on all devices depending on Android version as detailed by Android [`shell_and_utilities`](https://android.googlesource.com/platform/system/core/+/master/shell_and_utilities/README.md) docs. The core utilities are primarily provided by `toybox` ([1](http://landley.net/toybox), [2](https://github.com/landley/toybox), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:external/toybox)) for Android `>= 6` and `toolbox` ([1](https://cs.android.com/android/platform/superproject/+/android-5.0.0_r1.0.1:system/core/toolbox)) for Android `< 6` and mostly have limited features compared to `GNU` [`coreutils`](https://www.gnu.org/software/coreutils/manual/coreutils.html) provided by Termux and other Linux distros, like [`debian`](https://www.debian.org). Moreover, older android versions do not have all the utilities or their features are missing or are severely broken. Additional apex, vendor or product partition specific ([1](https://source.android.com/docs/core/architecture/partitions), [2](https://source.android.com/docs/core/ota/apex), [3](https://source.android.com/docs/core/architecture/partitions/product-partitions)), or custom ROM specific executables may exist under additional paths like  `/apex`, `/vendor`, `/product` or under `/sbin` and `/system/xbin` directories.

##### Android Lib Directory

The Android system provided shared libraries exist under `/system/lib64` and/or `/system/lib` ([or instead under `/apex/*/lib`]([`linker_translate_path.cpp`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker_translate_path.cpp))) depending on if Android is `64-bit` or `32-bit`. Additional libraries may exist under `/odm/lib[64]`, `/vendor/lib[64]`, `/data/asan/system/lib[64]`, `/data/asan/odm/lib[64]` and `/data/asan/vendor/lib[64]`.

---

&nbsp;





## Termux Paths

Android OS normally does not provide write access to system directories under Android filesystem rootfs `/` to apps and many are read-only for security purposes, so apps like Termux cannot create or modify files in them, like under the `/bin`, `/lib`, `/usr`, `/etc`, etc directories. This makes it impossible for the Linux environment provided by Termux (without root) to follow the [Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard). Additionally, even if modifying such directories were possible, installing or replacing files under them would either break Android or Termux (or both) since they both require different files to exist under various directories and executables are linked against their own compatible shared libraries and mixing them is not possible ([1](./Termux-execution-environment.md#dynamic-library-linking-errors)). However, if Termux app has been granted root access on a rooted device, then `chroot` ([1](https://man7.org/linux/man-pages/man2/chroot.2.html), [2](https://man7.org/linux/man-pages/man1/chroot.1.html)) can be used to run a Linux distro that follows FHS, but most Android devices are not rooted and so using `chroot` by default is not a possibility.

|                Path                 |                               Description                               |
|:------------------------------------|:------------------------------------------------------------------------|
| `/data/data/com.termux`             | [Termux Private App Data Directory](#termux-private-app-data-directory) |
| `/data/data/com.termux/termux`      | [Termux Project Directory](#termux-project-directory)                   |
| `/data/data/com.termux/termux/core` | [Termux Core Directory](#termux-core-directory)                         |
| `/data/data/com.termux/termux/apps` | [Termux Apps Directory](#termux-apps-directory)                         |
| `/data/data/com.termux/files`       | [Termux Rootfs Directory](#termux-rootfs-directory)                     |
| `/data/data/com.termux/files/home`  | [Termux Home Directory](#termux-home-directory)                         |
| `/data/data/com.termux/files/usr`   | [Termux Prefix Directory](#termux-prefix-directory)                     |
| `/data/data/com.termux/cache`       | [Termux App Cache Directory](#termux-app-cache-directory)               |


### Termux Private App Data Directory

Since Android does not provide arbitrary access to system directories to apps, when an app is installed, it is assigned two unique things, a unique private app data directory and a unique `uid`.

The Termux private app data directory is the directory assigned by Android to the Termux app with `TERMUX_APP__PACKAGE_NAME` for all its app data, which contains the [Termux project directory](#termux-project-directory) (`TERMUX__PROJECT_DIR`), and optionally the [Termux rootfs directory](#termux-rootfs-directory) (`TERMUX__ROOTFS`). The default path is `/data/data/com.termux`.

The private app data directory path assigned to an app is expected to be one of the following.
- `/data/user/<user_id>/<package_name>` if app is installed on internal sd of the device. On Android version `< 11`, the `/data/user/0` is a symlink to `/data/data` directory ([1](https://cs.android.com/android/platform/superproject/+/android-10.0.0_r47:system/core/rootdir/init.rc;l=589)), and on Android version `>= 11`, the `/data/data` directory is bind mounted at `/data/user/0` ([1](https://cs.android.com/android/platform/superproject/+/android-11.0.0_r40:system/core/rootdir/init.rc;l=705-710), [2](https://cs.android.com/android/_/android/platform/system/core/+/3cca270e95ca8d8bc8b800e2b5d7da1825fd7100)), so an app may access `/data/user/<user_id>/<package_name>` from `/data/data/<package_name>` as well if its installed on primary user `0`. Some devices may bind mount `/data/data` in secondary users and profiles as well, but that is not done by AOSP.
- `/mnt/expand/<volume_uuid>/user/<user_id>/<package_name>` if app is installed on a removable/portable volume/sd card being used as [adoptable storage](https://source.android.com/docs/core/storage/adoptable), like external sd cards.

The following applies for the path format.
- The `package_name` refers to the unique package name for the app for which its APK file was compiled for. ([1](https://developer.android.com/build/configure-app-module#set-application-id), [2](https://en.wikipedia.org/wiki/Apk_(file_format))) The `package_name` on Android can be max `255` characters due to `ext4` filesystem limit as per [`NAME_MAX`](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:bionic/libc/kernel/uapi/linux/limits.h;l=27) that is [defined by POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/limits.h.html). ([1](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:frameworks/base/core/java/android/content/pm/PackageParser.java;l=1601), [2](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:frameworks/base/core/java/android/os/FileUtils.java;l=991), [3](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:frameworks/base/services/core/java/com/android/server/pm/PackageInstallerSession.java;l=2757))
- The `user_id` refers to the id for the [user](https://source.android.com/docs/devices/admin/multi-user) in which an app is installed and running. The default/primary user id is `0`. The ids for secondary users and profiles start at id `10`. A `user_id` can have a max `1000` value. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/bionic/grp_pwd.cpp;l=351), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/libcutils/multiuser.cpp;l=29)), but only `1-10` users are allowed to be created normally, based on the `fw.max_users` property or `config_multiuserMaximumUsers` config (`pm get-max-users`). ([1](https://source.android.com/docs/devices/admin/multi-user#applying_the_overlay), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/res/res/values/config.xml;l=2802), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/os/UserManager.java;l=5719))
- The `volume_uuid` for an `/mnt/expand` path is the volume partition [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) equal to `36` characters in the format `VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV`.
- The partitions for the app data directory paths are normally formatted as [`ext4`](https://en.wikipedia.org/wiki/Ext4) or [`f2fs`](https://en.wikipedia.org/wiki/F2FS) filesystem, which supports symlinks and other file attributes.

**For Termux installed on primary user `0`, the private app data directory paths assigned by Android are `/data/data/com.termux` and `/data/user/0/com.termux`, and Termux app can only be installed in the primary user and not secondary users/profiles as Termux packages are specifically compiled for the Termux `rootfs` directory `/data/data/com.termux/files` (`$TERMUX__ROOTFS`) that exists under it, at least until [Dynamic Variables](https://termux.dev/en/posts/general/2024/11/11/termux-selected-for-nlnet-ngi-mobifree-grant.html#dynamic-variables) is implemented.**

&nbsp;

The uid (`id -u`)  assigned to the app for its private app data directory and processes is calculated as per `user_id * AID_USER_OFFSET + AID_APP_START + app_id`, where `AID_USER_OFFSET=100000` (offset for uid ranges for each user), `AID_APP_START=10000` (first app user) and `AID_APP_END=19999` (last app user). The `app_id` is the unique id assigned to an app which gets incremented for each new app during its install session. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/pm/InstallPackageHelper.java;l=1001), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/pm/InstallPackageHelper.java;l=3977), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/pm/Settings.java;l=1293), [4](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/pm/AppIdSettingMap.java;l=136-153), [5](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/pm/AppIdSettingMap.java;l=109)) If the same app is installed in secondary users, it will be assigned the same `app_id`, but `uid` will have a different `user_id` to distinguish them and the `categories` in the SeLinux contexts assigned to the processes and files of the apps as part of Multi-Category Security (MCS) will be different too. ([1](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/security-context.md#categories), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/libcutils/include/private/android_filesystem_config.h;l=198-199,230), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/bionic/grp_pwd.cpp;l=274), [4](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/os/Process.java;l=272-283), [5](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/os/UserHandle.java;l=42-46)). The user names (`id -un`) for app processes are in the format `u<user_id>_a<app_id>` for normal app processes, like `u0_a160` and in the format `u<user_id>_i<app_id>` for isolated app processes, like `u0_i160`. For example, for normal app processes with the `app_id=160`:
    - `user_id=0: (0 * 100000 + 10000 + 160) -> 10160/u0_a160`  
    - `user_id=10: (10 * 100000 + 10000 + 160) -> 1010160/u10_a160`  
    - `user_id=256: (256 * 100000 + 10000 + 160) -> 25610160/u256_a160`  
    - `user_id=1000: (1000 * 100000 + 10000 + 160) -> 100010160/u1000_a160`  

&nbsp;

This **private app data directory assigned to the app is not accessible to any other app by default** and is safe to use to store private files. This is done with 3 different security mechanisms.
1. UID-based DAC security ensures that private app data directory has the same ownership as the app uid and the permissions (read, write and execute) are not granted to `other` group by Android by default, so each app can only access files owned by its own `uid`. ([1](https://en.wikipedia.org/wiki/Discretionary_access_control), [2](https://en.wikipedia.org/wiki/File-system_permissions#Permissions))
2. SeLinux Multi-Category Security (MCS) prevents an app to `Isolate the app data from access by another app` and `Isolate the app data from one physical user to another`. ([1](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/security-context.md#categories)) If SeLinux is disabled by user with root, then only DAC security is used and if user changes permissions of private app data directory for the `other` group, then files may become accessible, so **disabling SeLinux is not recommended**. 
3. Apps using [`targetSdkVersion`](https://developer.android.com/guide/topics/manifest/uses-sdk-element#target) `30` (Android `11`) run in an isolated environment in which `/data/data/<package_name>`, `/data/user/<user_id>/<package_name>` and `/mnt/expand/<volume_uuid>/user/<user_id>/<package_name>` directories of other apps do not exist in its mount namespace. Termux may still have directories of other apps in its mount namespace as it uses `targetSdkVersion` `= 28` by default, even though they are not accessible by default.

However, **files under Termux private app data directory can be made accessible to other apps** in the following ways.

1. If the other app uses [`sharedUserId`](https://developer.android.com/guide/topics/manifest/manifest-element#uid) equal to `com.termux` used by the main Termux app and its APK is signed with the same signing key as that of main Termux app APK. Such apps share the same `uid` and can access each other's unique private app data directories. This is used by some of the [official Termux app plugins](https://github.com/termux/termux-app#termux-app-and-plugins) to allow them to access Termux rootfs files. Note that the signing key of [Termux GitHub builds](https://github.com/termux/termux-app#github) is public as detailed in the [installation](https://github.com/termux/termux-app#installation) docs, so anyone can create an update for the Termux app that will install over the existing Termux app, or be able create a new app with the same `sharedUserId` as the Termux app to get access to Termux files, so never install apps from untrusted sources if using GitHub builds. The signing key of [F-Droid builds](https://github.com/termux/termux-app#f-droid) is private and does not have this security *issue*.
2. Access is explicitly granted to an app by the user to the Termux rootfs via Storage Access Framework (SAF) provided by Android. ([1](https://developer.android.com/guide/topics/providers/document-provider), [2](https://wiki.termux.com/wiki/Internal_and_external_storage)).
3. Access is explicitly granted to an app by the user to Termux APIs, like [`RUN_COMMAND Intent`](https://github.com/termux/termux-app/wiki/RUN_COMMAND-Intent). These APIs normally have dual protection if a wide access is to be granted and requires manually granting the other app the `RUN_COMMAND` permission in Android settings and enabling `allow-external-apps` Termux property inside the Termux app.

## &nbsp;

&nbsp;



### Termux Project Directory

Termux project directory (`$TERMUX__PROJECT_DIR`) added in Termux app `v0119.0` is an exclusive directory for all Termux files that includes [Termux core directory](#termux-core-directory) (`TERMUX__CORE_DIR`), [Termux apps directory](#termux-apps-directory) (`TERMUX__APPS_DIR`), and optionally the [Termux rootfs directory](#termux-rootfs-directory) (`TERMUX__ROOTFS`). The default path is `/data/data/com.termux/termux`.

Currently, the default Termux rootfs directory is not under it and is at the `/files` subdirectory but there are plans to move it to `termux/rootfs/II` in future where `II` refers to rootfs id starting at `0` for multi-rootfs support.

An exclusive directory is required so that all termux files exist under a single directory, especially for when termux is provided as a library, so that termux files do not interfere with other files of Termux app forks or apps that may use the termux library.

## &nbsp;

&nbsp;



### Termux Core Directory

Termux core directory (`$TERMUX__PROJECT_DIR`) added in Termux app `v0119.0` contains Termux core files for the Termux app, like user settings and configs for the app, which and are independent of any specific rootfs. The default path is `/data/data/com.termux/termux/core`.

## &nbsp;

&nbsp;



### Termux Apps Directory

Termux apps directory (`$TERMUX__APPS_DIR`) added in Termux app `v0119.0` contains app specific files for the Termux app, its plugin apps, and third party apps, like used for app APIs and [filesystem/pathname socket files](https://man7.org/linux/man-pages/man7/unix.7.html) of servers created by the apps. The default path is `/data/data/com.termux/termux/apps`.

## &nbsp;

&nbsp;



### Termux Rootfs Directory

Termux rootfs directory (`$TERMUX__ROOTFS`) contains the Linux environment rootfs provided by Termux. The default path is `/data/data/com.termux/termux`.

The Termux rootfs is different from the Android host filesystem rootfs at `/` on which Termux runs, which also (obviously) exists in the Termux app mount namespace, including any of the normal sub directories under `/` created by Android itself, but apps do not have write access to such directories (without `root` access) and read access is also limited to a few public directories like Android `/system`. The only directories other than the private app data directory that apps have write access to are the external storage directories under `/mnt/media_rw`, `/storage/emulated` and `/sdcard` depending on storage permissions granted to the app, but they primarily have emulated `fat` filesystems on which programs cannot be executed or work properly, check [File Execution And Special File Features Not Allowed In External Storage](./Termux-execution-environment.md#file-execution-and-special-file-features-not-allowed-in-external-storage) for more info.

It can exist outside the `TERMUX_APP__DATA_DIR` if compiling packages for the Android system or `adb` `shell` user.

The Termux rootfs contains the sub directories for [Termux Home](#termux-home-directory) and [Termux Prefix](#termux-prefix-directory) directories.

## &nbsp;

&nbsp;



#### Termux Home Directory

The Termux home directory (`$HOME`/`$TERMUX__HOME`) exists under [Termux Rootfs Directory](#termux-rootfs-directory). The default path is `/data/data/com.termux/files/home`. It serves the same purpose as the [`/home`](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s08.html) directory on Linux distros.

The Termux home (`$HOME`) directory exists at `/data/data/com.termux/files/home` (`$HOME`/`$TERMUX__HOME`) by default. 

However, `$HOME` value may be changed by some programs, like `su` wrappers ([`sudo`](https://github.com/agnostic-apollo/sudo), [`tsu`](https://github.com/cswl/tsu)) to `/data/data/com.termux/files/home/.suroot` so that `root` owned files are kept separate from Termux user owned files. Note that Termux is a [single user environment](https://wiki.termux.com/wiki/Differences_from_Linux#Termux_is_single-user), and all its files can only ever be owned by the random `uid` Android assigns to Termux app during installation, which cannot be changed to a custom value. Moreover, even if Termux app is granted root access to be able to run `root` owned processes that have the access to create/modify files owned by other users, like `root` user, any Termux app user owned processes will still only be able to access files with the same owner and SeLinux [file context type](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/context-types.md#file-context-types). If a user uses `root` access to create files or change ownership of files that are normally used by Termux app processes under `$TERMUX__ROOTFS`, then Termux environment may break as app processes wouldn't be able to access the required files, so it is **highly recommended to not use `root` unless you know what you are doing.** Termux package managers (`apt`/`pacman`) are also patched so that they cannot be run as `root`. ([1](https://github.com/termux/termux-packages/commit/dc14c1294090aa0961a394761a02f2d86aab7a90), [2](https://github.com/termux/termux-packages/commit/2d2556e4e711001ca0b7a0240f0038a510511b61#diff-09b6166bd2c112e18fa24bcf51d9cd3312d21c16c7f8647527f4f3264be4f331), [3](https://github.com/termux/termux-tools/commit/e38ee5135abc0929947bbaad2cd495a4a5922398))

Packages should never install files to the home directory. Exception is only for package maintainer scripts ([1](https://www.debian.org/doc/debian-policy/ch-binary.html#maintainer-scripts), [2](https://wiki.archlinux.org/title/PKGBUILD#install)), which can be used to prepare initial configuration in `$HOME` for packages which can't do it on their own.

&nbsp;


#### Termux Prefix Directory

The Termux prefix directory (`$TERMUX__PREFIX`/`$PREFIX`) exists under or equal to [Termux Rootfs Directory](#termux-rootfs-directory). The default path is `/data/data/com.termux/files/usr`. It serves the same purpose as the [`/usr`](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04.html) directory on Linux distros and contains the `bin`, `etc`, `include`, `lib`, `libexec`, `opt`, `share`, `tmp` and `var` sub directories. It is exported as `$TERMUX_PREFIX` instead of `$PREFIX` in addition to `$TERMUX__PREFIX` in Termux packages build system.

For safety of user data, it is not allowed to create packages installing files outside of this directory.

> Important: Do not confuse the `/usr` directory with Termux prefix directory `/data/data/com.termux/files/usr`. Termux never uses the FHS compliant `/usr` directory found on Linux distros for packaging purposes.

All hardcoded references to FHS directories in package source files are patched and replaced with Termux prefix directory during build time , like `/bin` or `/usr/bin` will get replaced with `/data/data/com.termux/files/usr/bin`.

|           Path            |                                                        Description                                                        |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `$TERMUX__PREFIX/bin`     | [Executables](#termux-bin-directory). Combines `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`.                                  |
| `$TERMUX__PREFIX/etc`     | Configuration files.                                                                                                      |
| `$TERMUX__PREFIX/include` | C/C++ headers.                                                                                                            |
| `$TERMUX__PREFIX/lib`     | [Libraries](#termux-lib-directory), runtime executable data or development-related.                                       |
| `$TERMUX__PREFIX/libexec` | Executables which should not be run by user directly.                                                                     |
| `$TERMUX__PREFIX/opt`     | Installation root for sideloaded packages.                                                                                |
| `$TERMUX__PREFIX/share`   | Non-executable runtime data and documentation.                                                                            |
| `$TERMUX__PREFIX/tmp`     | Temporary files. Erased on each application restart. Combines `/tmp` and `/var/tmp`. *Can be freely modified by user.*    |
| `$TERMUX__PREFIX/var`     | Variable data, such as caches and databases. *Can be modified by user, but with additional care.*                         |
| `$TERMUX__PREFIX/var/run` | Lock files, PID files, sockets and other temporary files created by daemons. Replaces `/run`.                             |

&nbsp;

##### Termux Bin Directory

The Termux bin directory exists at `$TERMUX__PREFIX/bin` and contains the Termux provided executables. The default path is `/data/data/com.termux/files/usr/bin`.

Some packages, like `busybox`, may have their executables under `/data/data/com.termux/files/usr/bin/applets` (`$TERMUX__PREFIX/bin/applets`). The core utilities are provided by `GNU` [`coreutils`](https://www.gnu.org/software/coreutils/manual/coreutils.html) to have a consistent experience with other Linux distros, like [`debian`](https://www.debian.org).

##### Termux Lib Directory

The Termux lib directory exists at `$TERMUX__PREFIX/lib` and contains the Termux provided static and shared libraries. The default path is `/data/data/com.termux/files/usr/lib`.


### Termux App Cache Directory

Termux apps cache directory (`$TERMUX__CACHE_DIR`) contains cache files that are safe to be deleted by Android or Termux if required. The default path is `/data/data/com.termux/cache`.

The `cache` subdirectory is hardcoded in Android and cannot be changed. 

Android considers storage to be in a low storage state if free storage is at `5%` of total storage or `500MB`, which ever is lower. Cache directories get deleted when free storage is at `150%` of the low storage value. So if low storage is `500MB`, cache directories would get deleted at `500 x 1.5 = 750MB`. The values may vary on different Android versions and the default values can be changed with the `sys_storage_threshold_percentage` and `sys_storage_threshold_max_bytes` `global` `settings`.

- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/com/android/server/storage/DeviceStorageMonitorService.java;l=183-198
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/os/storage/StorageManager.java;l=1444-1505
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/provider/Settings.java;l=13972-13995
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/services/core/java/android/content/pm/PackageManagerInternal.java;l=909-916
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r60:frameworks/base/services/core/java/com/android/server/pm/FreeStorageHelper.java;l=112
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/native/cmds/installd/InstalldNativeService.cpp;l=1915-2120

Currently cache directory is primarily used for packages cache files of package managers (`apt`/`pacman`). Note that if downloading a large package or upgrading all packages (`pkg upgrade`), then all package files (`*.deb`/`*.pkg.tar.xz`) that need to be installed are all downloaded first, and if free storage space falls below threshold, then all downloaded files will get deleted before installation finishes and it will fail with `No such file or directory` errors, so make sure to have enough free space or update all packages manually in smaller groups.

---

&nbsp;





## File Path Limits

To choose the max file path length limits requires considering the limitations of Linux/Android, and their [`syscalls(2)`](https://man7.org/linux/man-pages/man2/syscalls.2.html). Linux assumes rootfs is at `/`, but for Termux, the rootfs directory needs to be under the app data directory path that android assigns the app, and hence it causes problems for linux system calls where buffer lengths are limited. Using [`PATH_MAX`](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:bionic/libc/kernel/uapi/linux/limits.h;l=28) (`4096`) that is [defined by POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/limits.h.html) is not possible for every Linux API.

The Termux apps and rootfs directory path limits depends on:

- The [Termux Private App Data Directory](#termux-private-app-data-directory) assigned to Termux app depending on the sd card and user it is installed.
- The `package_name` on Android can have max `255` characters due to `ext4` filesystem limit as per `NAME_MAX`.
- The `volume_uuid` for an `/mnt/expand` path will have `36` characters in the format `VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV`.
- The `user_id` can max `1000` value, so it can use max `4` characters. However, user id should only use `2` characters normally as only `1-10` users are allowed to be created normally.
- An app will normally put rootfs (`TERMUX__ROOTFS`) under a subdirectory of the app data directory. For Termux, this is currently the `files` (`5`) sub directory at `/data/data/com.termux/files`, but there are plans to move it to `termux/rootfs/II` (`16`) in future where `II` refers to rootfs id starting at `0` for multi-rootfs support. Termux forks may use a different path, so length may be lesser or higher.
- The uid (`id -u`) for app processes used for `TERMUX__APPS_DIR_BY_UID` are calculated as per `user_id * AID_USER_OFFSET + AID_APP_START + app_id`, where `AID_USER_OFFSET=100000` (offset for uid ranges for each user), `AID_APP_START=10000` (first app user) and `AID_APP_END=19999` (last app user) as documented in the [Termux Private App Data Directory](#termux-private-app-data-directory) section. The `uid` max length is limited to `TERMUX__APPS_APP_UID___MAX_LEN` (`9`) characters.

&nbsp;

The path length of Termux apps and rootfs directory may cause the following problems:

- A filesystem socket ([pathanme UNIX domain socket](https://man7.org/linux/man-pages/man7/unix.7.html)) requires that the `sockaddr_un.sun_path` is limited to `108` characters including the null `\0` terminator as per [`UNIX_PATH_MAX`](https://cs.android.com/android/platform/superproject/+/android-13.0.0_r18:bionic/libc/kernel/uapi/linux/un.h;l=22)/`TERMUX__UNIX_PATH_MAX`. A filesystem socket is created by Termux app for [`termux-am-socket`](https://github.com/termux/termux-am-socket) for `termux-am` command under the Termux apps directory `/data/data/@TERMUX_APP__PACKAGE_NAME@/termux/apps` (not Termux rootfs directory). It's also planned to be used for Termux plugin apps for Termux APIs. Packages may create filesystem sockets in the `$TMPDIR` under the Termux rootfs directory.

- For the [`execve()`](https://man7.org/linux/man-pages/man2/execve.2.html) system call, the kernel imposes a maximum length limit on script [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)#Character_interpretation) including the `#!` characters at the start of a script. For Linux `< 5.1`, the limit is `128` characters and for Linux `>= 5.1`, the limit is `256` characters as per [`BINPRM_BUF_SIZE`](https://cs.android.com/android/kernel/superproject/+/0dc2b7de045e6dcfff9e0dfca9c0c8c8b10e1cf3:common/include/uapi/linux/binfmts.h;l=18) including the null `\0` terminator. ([1](https://cs.android.com/android/kernel/superproject/+/0dc2b7de045e6dcfff9e0dfca9c0c8c8b10e1cf3:common/fs/binfmt_script.c;l=34), [2](https://cs.android.com/android/kernel/superproject/+/0dc2b7de045e6dcfff9e0dfca9c0c8c8b10e1cf3:common/include/linux/binfmts.h;l=64)) **If `termux-exec` is set in [`LD_PRELOAD`](#ld_preload) and [`TERMUX_EXEC__INTERCEPT_EXECVE`](#termux_exec__intercept_execve) is enabled, then shebang limit is increased to `340` characters defined by `FILE_HEADER__BUFFER_LEN` (`TERMUX__ROOTFS_DIR___MAX_LEN + BINPRM_BUF_SIZE - 1`) defined in [`exec.h`](https://github.com/termux/termux-exec/blob/master/src/exec/exec.h) as shebang is read and script is passed to interpreter as an argument by `termux-exec` manually.** So if `LD_PRELOAD` will be set for all Termux shells, then this limit does not need to be worried about. Increasing limit to `340` also fixes issues for older Android kernel versions where limit is `128`. The limit is increased to `340`, because `BINPRM_BUF_SIZE` would be set based on the assumption that rootfs is at `/`, so we add Termux rootfs directory max length to it.

&nbsp;

Based on the above limitations and examples below, the following limits are chosen. **The limits are defined by [`properties.sh`](https://github.com/termux/termux-packages/blob/master/scripts/properties.sh) in `termux-packages`, [`TermuxCoreConstants`](https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/termux/core/TermuxCoreConstants.java) in `termux-app` and [`termux_files.h`](https://github.com/termux/termux-exec/blob/master/src/termux/termux_files.h) in `termux-exec`.**

```shell
TERMUX__INTERNAL_NAME___MAX_LEN=7
TERMUX_APP__DATA_DIR___MAX_LEN=69
TERMUX__APPS_DIR___MAX_LEN=84
TERMUX__APPS_APP_IDENTIFIER___MAX_LEN=10
TERMUX__APPS_APP_UID___MAX_LEN=9
TERMUX__APPS_API_SOCKET__SERVER_PARENT_DIR___MAX_LEN=98
TERMUX__ROOTFS_DIR___MAX_LEN=86
TERMUX__PREFIX_DIR___MAX_LEN=90
TERMUX__PREFIX__TMP_DIR___MAX_LEN=94
TERMUX__UNIX_PATH_MAX=108
```

For compiling Termux packages for `/data/data` or `/data/data/UU` paths, **ideally package name should be `<= 21` characters** and max `33` characters. If package name has not yet been chosen, then it would be **best to keep it to `<= 10` characters**.
For compiling Termux packages for `/mnt/expand` paths or if it may be supported in future, keep package name at max `11` characters, but even that will only give `13` characters for a filesystem socket sub path under `$TMPDIR` and would require patching patches if a longer sub paths are used.

The max length `TERMUX__INTERNAL_NAME___MAX_LEN` for `TERMUX__INTERNAL_NAME` is chosen as `7` based on the max recommended package name length minus the common domain name TLD suffix length of `4` (like `.dev`, `.com`, etc).

**If filesystem socket functionality is required for Termux apps, then Termux apps directory path length should be `<= 83` and if required for Termux packages, then Termux rootfs directory path length should be `<= 85`.**

The max length (including the null `\0` terminator) `TERMUX_APP__DATA_DIR___MAX_LEN = 69` for `TERMUX_APP__DATA_DIR` is chosen based on the examples used for `TERMUX__APPS_DIR___MAX_LEN` and `TERMUX__ROOTFS_DIR___MAX_LEN`, with max `11` characters for the package name for a `/mnt/expand` path.

The max length (including the null `\0` terminator) `TERMUX__APPS_DIR___MAX_LEN = 84` for `TERMUX__APPS_DIR_BY_IDENTIFIER` and `TERMUX__APPS_DIR_BY_UID` is chosen based on the `12`, `14`, `16` and `19` examples below, which allow multiple unique filesystem sockets under apps directory for each unique app as long as apps directory length `<= 83`.

The max length (including the null `\0` terminator) `TERMUX__ROOTFS_DIR___MAX_LEN = 86` for `TERMUX__ROOTFS`, `TERMUX__PREFIX_DIR___MAX_LEN = 90` for `TERMUX__PREFIX` and `TERMUX__PREFIX__TMP_DIR___MAX_LEN = 94` for `TERMUX__PREFIX__TMP_DIR` is chosen based on the `37` and `41` examples below, which allow multiple unique filesystem sockets under `$TMPDIR`/`TERMUX__PREFIX__TMP_DIR` for each unique program as long as rootfs directory length `<= 85`, but would require patching patches that use longer paths under `$TMPDIR`.


&nbsp;

In the following examples:
- `V` refers to volume id.
- `U` refers to user id.
- `P` refers to Termux app package name.
- `I` refers to Termux rootfs id.
- `N` refers to Termux app or plugin app identifier name limited to `TERMUX__APPS_APP_IDENTIFIER___MAX_LEN` (`10`) characters. For example `termux-xxxx`.
- `A` refers to Termux app or plugin app uid (user_id + app_id) (`id -u`) limited to `TERMUX__APPS_APP_UID___MAX_LEN` (`9`) characters. For example `10160` or `100010160`.
- `D` refers to a unique directory identifier template, like generated with [`mkdtemp`](https://man7.org/linux/man-pages/man3/mkdtemp.3.html) that requires minimum 6 `X` characters as template.
- `X` refers to a unique filename identifier template, like generated with [`mkstemp`](https://man7.org/linux/man-pages/man3/mkstemp.3.html) that requires minimum 6 `X` characters as template.
- `S` refers to a sub path.
- `*/termux` refers to `TERMUX__PROJECT_DIR` whose directory basename is set to `TERMUX__INTERNAL_NAME` and is limited to `TERMUX__INTERNAL_NAME___MAX_LEN` (`7`) characters (and currently has length `6`).
- `*/termux/apps/i` refers to `TERMUX__APPS_DIR_BY_IDENTIFIER` that are created for each app based on a unique app identifier.
- `*/termux/apps/u` refers to `TERMUX__APPS_DIR_BY_UID` that creates directories for each app based on its unique app uid (user_id + app_id) assigned to it by Android at install time.
- `t` in `DDDDDD/t` refers to type of socket, it may be `i` for a input socket and `o` for an output socket that belong to the same API call.

```shell
##### Apps filesystem sockets

1.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=82`,`package_name=35`)
2.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/s/DDDDDD/t` (`path=82`,`package_name=35`)
3.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/s/DDDDDD/t` (`path=80`,`package_name=35`)
5.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=107`,`package_name=60`)
6.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/s/DDDDDD/t` (`path=107`,`package_name=60`)
4.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/s/DDDDDD/t` (`path=107`,`package_name=62`)
7.  `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAA/DDDDDD/XXXXXX` (`path=107`,`package_name=60`)

8.  `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=85`,`package_name=35`)
9.  `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/s/DDDDDD/t` (`path=85`,`package_name=35`)
10. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/s/DDDDDD/t` (`path=85`,`package_name=37`)
12. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=107`,`package_name=57`)
13. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/s/DDDDDD/t` (`path=107`,`package_name=57`)
11. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/s/DDDDDD/t` (`path=107`,`package_name=59`)
14. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/DDDDDD/XXXXXX` (`path=107`,`package_name=55`)

15. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=128`,`package_name=35`) (**invalid**)
16. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/termux-am` (`path=107`,`package_name=14`)
17. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPP/termux/apps/i/NNNNNNNNNN/s/DDDDDD/t` (`path=107`,`package_name=14`)
18. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/s/DDDDDD/t` (`path=107`,`package_name=16`)
19. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPP/termux/apps/u/AAAAAAAAA/DDDDDD/XXXXXX` (`path=107`,`package_name=12`)



##### $TMPDIR filesystem sockets (current rootfs)

20. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=74`,`package_name=35`)
21. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=68`)
22. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=35`, `tmp_sub_path=46`)
23. `/data/data/PPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=21`, `tmp_sub_path=60`)

24. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=77`,`package_name=35`)
25. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=65`)
26. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=35`, `tmp_sub_path=43`)
27. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=21`, `tmp_sub_path=57`)

28. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=120`,`package_name=35`) (**invalid**)
29. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=22`)
30. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/tmp/S` (`path=108`,`package_name=35`, `tmp_sub_path=1`) (**invalid**)
31. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPP/files/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=11`, `tmp_sub_path=25`)

##### $TMPDIR filesystem sockets (future rootfs)

32. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=85`,`package_name=35`)
33. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=57`)
34. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=35`, `tmp_sub_path=35`)
35. `/data/data/PPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=21`, `tmp_sub_path=49`)

36. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=88`,`package_name=35`)
37. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=54`)
38. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=35`, `tmp_sub_path=32`)
39. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=107`,`package_name=21`, `tmp_sub_path=46`)

40. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=131`,`package_name=35`) (**invalid**)
41. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPP/termux/rootfs/II/usr/tmp/DDDDDD/XXXXXX` (`path=107`,`package_name=11`)
42. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/tmp/S` (`path=119`,`package_name=35`, `tmp_sub_path=1`) (**invalid**)
43. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPP/termux/rootfs/II/usr/tmp/SSSSSSSSSSSSS` (`path=107`,`package_name=11`, `tmp_sub_path=13`)



##### bin paths (current rootfs)

44. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=66`)
45. `/data/data/PPPPPPPPPPPPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=21`, `bin_sub_path=80`)

46. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=43`)
47. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=21`, `bin_sub_path=77`)

48. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=20`)
49. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPP/files/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=11`, `bin_sub_path=44`)

##### bin paths (future rootfs)

50. `/data/data/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=55`)
51. `/data/data/PPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=21`, `bin_sub_path=69`)

52. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=52`)
53. `/data/user/UU/PPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=21`, `bin_sub_path=66`)

54. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSS` (`path=127`,`package_name=35`, `bin_sub_path=9`)
55. `/mnt/expand/VVVVVVVV-VVVV-VVVV-VVVV-VVVVVVVVVVVV/user/UU/PPPPPPPPPPP/termux/rootfs/II/usr/bin/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS` (`path=127`,`package_name=11`, `bin_sub_path=33`)
```
