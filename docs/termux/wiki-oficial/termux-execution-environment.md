# Termux Execution Environment

The following docs details how execution and dynamic linking happens in Termux, including issues/errors related to them and what path related environment variables are exported by Android and Termux by default. 

### Contents

- [Execution](#execution)
- [Termux App Child Process Forking](#termux-app-child-process-forking)
- [Execution Errors](#execution-errors)
- [Dynamic Library Linking](#dynamic-library-linking)
- [Dynamic Library Linking Errors](#dynamic-library-linking-errors)
- [Listing and Searching Libraries and Symbols](#listing-and-searching-libraries-and-symbols)
- [Path Environment Variables](#path-environment-variables)
- [Path Environment Variables Exported By Android](#path-environment-variables-exported-by-android)
- [Path Environment Variables Exported By Termux](#path-environment-variables-exported-by-termux)

---

&nbsp;





## Execution

**Termux executes programs natively on [Android host OS](https://source.android.com/docs/core/architecture)** by default, without any emulation or containerization (docker/VM/chroot/proot), and uses the [Android host kernel](https://source.android.com/docs/core/architecture/kernel) underneath, which is based on [Linux kernel](https://www.kernel.org/linux.html), and does not use a custom kernel. Programs are compiled with Android [`NDK`](https://developer.android.com/ndk/guides) and dynamically linked against Android system `bionic` ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/README.md), [2](https://en.wikipedia.org/wiki/Bionic_(software))) libraries under `/system/lib[64]`, which also provides [`libc`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc) as [C standard library](https://en.wikipedia.org/wiki/C_standard_library). Programs are not linked against `glibc` ([1](https://www.gnu.org/software/libc), [2](https://en.wikipedia.org/wiki/Glibc)) like done on other linux distros, like [`debian`](https://www.debian.org), and hence there are differences between the two, i.e `bionic` is not as featured and ported programs may require patches. Check [here](https://wiki.termux.com/wiki/Differences_from_Linux#Termux_uses_Bionic_libc) for some differences.

However, support for emulation is also optionally available for the user with `proot` ([1](https://github.com/proot-me/PRoot/), [2](https://github.com/termux/proot), [3](https://wiki.termux.com/wiki/PRoot), [4](https://github.com/termux/termux-packages/tree/master/packages/proot)) and `qemu` ([1](https://www.qemu.org/), [2](https://github.com/termux/termux-packages/tree/master/packages/qemu-system-x86-64-headless)) without `root`, and also for `chroot` ([1](https://man7.org/linux/man-pages/man2/chroot.2.html), [2](https://man7.org/linux/man-pages/man1/chroot.1.html), [3](https://github.com/termux/termux-packages/tree/master/packages/coreutils)) with `root`.


For info on how Termux app forks child processes from its main `app` process to run foreground terminals (`TermuxSessions`) or a background tasks (`TermuxTasks`), check [Termux App Child Process Forking](#termux-app-child-process-forking) section below.

For info on execution errors, check [Execution Errors](#execution-errors) section below.

For info on `$PATH`, `$LD_LIBRARY_PATH`, `$LD_PRELOAD` environment variables exported by Android and Termux for execution and dynamic linking, check [Path Environment Variables](#path-environment-variables), [Path Environment Variables Exported By Android](#path-environment-variables-exported-by-android), [Path Environment Variables Exported By Termux](#path-environment-variables-exported-by-termux).

For info on Android and Termux filesystems, and Termux private app data directory, check [Termux Filesystem Layout](#./Termux-file-system-layout) docs.

**Termux packages** in the app bootstrap ([1](https://github.com/termux/termux-app/blob/899ef71e/app/build.gradle#L213-L232), [2](https://github.com/termux/termux-packages/wiki/For-maintainers#bootstraps)), [primary packages repository](https://packages.termux.dev/) and its [mirrors](https://github.com/termux/termux-packages/wiki/Mirrors) **are specifically compiled for the `rootfs` directory `/data/data/com.termux/files`, based on the Termux app package name `com.termux` and the expected [private app data directory](https://developer.android.com/reference/android/content/pm/ApplicationInfo#dataDir) `/data/data/com.termux`** android would assign to the app on installation if its installed on the primary user `0` of the device. These packages would not work for any other app package name or a different app data or `rootfs` directory, and packages must be compiled specifically for any such changes, like in case forking the app with a different package name or installing Termux app on a [secondary user](https://source.android.com/docs/devices/admin/multi-user), [work profile](https://developer.android.com/work/managed-profiles) or [adoptable storage](https://source.android.com/docs/core/storage/adoptable). In addition to the `rootfs` directory, the `core` and `apps` directories are also used by the Termux apps and certain packages for certain things. During build time, the `termux-packages` [`build-package.sh`](https://github.com/termux/termux-packages/blob/7b253ac2/build-package.sh#L366) scripts loads the app package name and directory paths that are set in [`properties.sh`](https://github.com/termux/termux-packages/blob/master/scripts/properties.sh), which are primarily defined by the `$TERMUX_APP__PACKAGE_NAME`, `$TERMUX_APP__DATA_DIR`, `$TERMUX__PROJECT_DIR`, `$TERMUX__CORE_DIR`, `$TERMUX__APPS_DIR`, `$TERMUX__ROOTFS`, `$TERMUX__HOME`, and `$TERMUX__PREFIX` variables. Check [Build environment](https://github.com/termux/termux-packages/wiki/Build-environment) and [Building packages](https://github.com/termux/termux-packages/wiki/Building-packages) docs for more info on how packages are built.

For info on which packages are available on Termux app installation by default and how they are built, check [bootstrap](https://github.com/termux/termux-packages/wiki/For-maintainers#bootstraps) docs.

---

&nbsp;





## Termux App Child Process Forking

When Android starts an Termux app, it only creates a single main `app` process for it with the process name that equals its package name `com.termux`. ([1](https://developer.android.com/guide/components/processes-and-threads), [2](https://developer.android.com/guide/components/activities/process-lifecycle)) Moreover, no additional [service](https://developer.android.com/reference/android/app/Service) [`process`](https://developer.android.com/guide/topics/manifest/service-element#proc) or [`isolatedProcess`](https://developer.android.com/guide/topics/manifest/service-element#isolated) are used by Termux.

When Termux app needs to start foreground terminals (`TermuxSessions`) or background tasks (`TermuxTasks`), to run a [shell](https://en.wikipedia.org/wiki/Shell_(computing)), binary or script command, it [forks](https://man7.org/linux/man-pages/man2/fork.2.html) a child process from its main `app` process and then calls one of the [`exec()`](https://man7.org/linux/man-pages/man3/exec.3p.html) family of functions in the child process to replace it with the desired command. These child processes are called phantom processes internally by Android, i.e any process that has been forked from the main `app` process and is now either a child of the `app` process or of [`init`](https://en.wikipedia.org/wiki/Init) process, **check [Phantom, Cached And Empty Processes](https://github.com/agnostic-apollo/Android-Docs/blob/master/en/docs/apps/processes/phantom-cached-and-empty-processes.md) docs for more info on phantom processes.**

The `exec()` family of functions are [declared in `unistd.h`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/include/unistd.h;l=92-100) and [implemented by `exec.cpp`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/bionic/exec.cpp) in android `bionic` `libc` library. The `exec()` functions are wrappers around the [`execve()`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/SYSCALLS.TXT;l=68) system call listed in [`syscalls(2)`](https://man7.org/linux/man-pages/man2/syscalls.2.html) provided by the [android/linux kernel](https://cs.android.com/android/kernel/superproject/+/ebe69964:common/include/linux/syscalls.h;l=790), which can also be directly called with the [`syscall(2)`](https://man7.org/linux/man-pages/man2/syscall.2.html) library function [declared in `unistd.h`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/include/unistd.h;l=308). Note that there is also a `execve()` wrapper in `unistd.h` around the `execve()` system call.

The [`termux-exec`](https://github.com/termux/termux-exec) library is also loaded with `$LD_PRELOAD` when commands are executed, which overrides the entire `exec()` family of functions, but will not override direct calls to the `execve()` system call via `syscall(2)`, which is usually not directly called by programs. It overrides the functions to solve the issues related to [App Data File Execute Restrictions](#app-data-file-execute-restrictions) and [Linux vs Termux `bin` paths](#linux-vs-termux-bin-paths) when exec-ing files in Termux. Check [`termux-exec` `exec()`](https://github.com/termux/termux-exec/blob/master/site/pages/en/projects/docs/technical/index.md#app-data-file-execute-restrictions) docs for more info.

**See also:**

- [exec (system call) wiki](https://en.wikipedia.org/wiki/Exec_(system_call))
- [`unistd.h` POSIX spec](https://pubs.opengroup.org/onlinepubs/7908799/xsh/unistd.h.html)
- [`execve` POSIX spec](https://pubs.opengroup.org/onlinepubs/7908799/xsh/execve.html)
- [`execve(2)` linux man](https://man7.org/linux/man-pages/man2/execve.2.html)
- [`exec(3)` linux man](https://man7.org/linux/man-pages/man3/exec.3.html)
- [`exec(3p)` linux man](https://man7.org/linux/man-pages/man3/exec.3p.html)
- [`fork` POSIX spec](https://pubs.opengroup.org/onlinepubs/7908799/xsh/fork.html)
- [`fork(2)` linux man](https://man7.org/linux/man-pages/man2/fork.2.html)

&nbsp;



Termux uses `Runtime.exec()` for `TermuxTasks` and `execvp()` for `TermuxSessions` to fork processes from its main `app` process. The new child processes that are started may then call the `exec()` family of functions to fork even more nested child processes.

### `Runtime.exec()` Java Function

The [`Runtime.exec()`](https://developer.android.com/reference/java/lang/Runtime#exec(java.lang.String[],%20java.lang.String[])) is the `Java` API that forks a child processes and calls `execvpe()`. The parent of the child process remains the main `app` process itself.

Termux uses this for running background [`TermuxTasks`](https://github.com/termux/termux-app/blob/v0.118.0/termux-shared/src/main/java/com/termux/shared/shell/TermuxTask.java), which are managed by the foreground [`TermuxService`](https://github.com/termux/termux-app/blob/v0.118.0/app/src/main/java/com/termux/app/TermuxService.java#L86). These background tasks can be sent via the [`RUN_COMMAND Intent`](https://github.com/termux/termux-app/wiki/RUN_COMMAND-Intent) and by Termux plugins like [`termux-boot`](https://github.com/termux/termux-boot), [`termux-tasker`](https://github.com/termux/termux-tasker) and [`termux-widget`](https://github.com/termux/termux-widget). They show as `<n> tasks` in the `Termux` notification.

**Call stack:** [`Runtime.exec()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/java/java/lang/Runtime.java;l=694) -> [`ProcessBuilder.start()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/java/java/lang/ProcessBuilder.java;l=1029) -> [`ProcessImpl.start()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/java/java/lang/ProcessImpl.java;l=137) -> [`UNIXProcess()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/java/java/lang/UNIXProcess.java;l=133) -> [`UNIXProcess_md.forkAndExec()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/native/UNIXProcess_md.c;l=926) -> [`UNIXProcess_md.startChild()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/native/UNIXProcess_md.c;l=847) ([note on forking](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/native/UNIXProcess_md.c;l=68) for [`clone()`](https://manpages.debian.org/testing/manpages-dev/clone.2.en.html), [`vfork()`](https://manpages.debian.org/testing/manpages-dev/vfork.2.en.html) and [`fork()`](https://manpages.debian.org/testing/manpages-dev/fork.2.en.html) usage) -> [`UNIXProcess_md.childProcess()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/native/UNIXProcess_md.c;l=782) -> [`UNIXProcess_md.JDK_execvpe()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:libcore/ojluni/src/main/native/UNIXProcess_md.c;l=603) -> [`exec.execvpe()`](https://cs.android.com/android/platform/superproject/+/android-12.0.0_r32:bionic/libc/bionic/exec.cpp;l=119)


### `exec()` C Function

The `execvp()` is part of the native `exec()` family of functions that replaces the current process image with a new process image. This can be called by the child process that has been spawned from the `app` process after it calls `fork()`. These functions can be called in native `c/c++` code via [`JNI`](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/intro.html) by an app.

Termux uses this for running foreground [`TermuxSessions`](https://github.com/termux/termux-app/blob/v0.118.0/termux-shared/src/main/java/com/termux/shared/shell/TermuxSession.java#L131), which are managed by the foreground [`TermuxService`](https://github.com/termux/termux-app/blob/v0.118.0/app/src/main/java/com/termux/app/TermuxService.java#L78). The `TermuxSession` creates a `TerminalSession` that calls [`create_subprocess`](https://github.com/termux/termux-app/blob/v0.118.0/terminal-emulator/src/main/java/com/termux/terminal/TerminalSession.java#L127) via `JNI` defined in [`termux.c`](https://github.com/termux/termux-app/blob/v0.118.0/terminal-emulator/src/main/jni/termux.c#L25), which then calls [`fork()`](https://github.com/termux/termux-app/blob/v0.118.0/terminal-emulator/src/main/jni/termux.c#L63) and the child process calls [`execvp()`](https://github.com/termux/termux-app/blob/v0.118.0/terminal-emulator/src/main/jni/termux.c#L106). By default, if no custom command is passed to run in the `TerminalSession`, the `/data/data/com.termux/files/usr/bin/login` script is called, which runs [`exec "$SHELL"`](https://github.com/termux/termux-packages/blob/master/packages/termux-tools/login#L35) to replace itself with the `login` shell defined, which defaults to `/data/data/com.termux/files/usr/bin/bash`.



### `daemon` C Function

The [`daemon()`](https://man7.org/linux/man-pages/man3/daemon.3.html) function is for programs wishing to detach themselves from the controlling terminal and run in the background as [system daemons](https://man7.org/linux/man-pages/man7/daemon.7.html). The child process forked from the parent process basically detaches itself from the parent so that it is no longer its parent process (`ppid`) and is inherited by the [`init`](https://en.wikipedia.org/wiki/Init) (`pid` `1`) process.

Termux app does not start daemons itself but it can be done by programs that may be started by users themselves, like with `sshd` and `crond` commands. If `sshd` command is run, the `ps` output will show `sshd` to have `init` (`pid` `1`) as the `ppid`, instead of `pid` of its original parent `bash`. These daemons have a higher chance of getting killed since there are no longer attached to the `app` process. Optionally, processes may not be [daemonized](https://github.com/termux/termux-app/issues/2015#issuecomment-860492160) (like by running `sshd -D`) and kept in the foreground so that they are still tied to the `app` process as that would make it less likely for them to get killed, assuming [phantom process killer has been disabled](https://github.com/agnostic-apollo/Android-Docs/blob/master/en/docs/apps/processes/phantom-cached-and-empty-processes.md#commands-to-disable-phantom-process-killing-and-tldr). Some vendors also have additional daemon process killers.

---

&nbsp;





## Execution Errors

The following issues may occur when executing files in termux.

- [File Execution And Special File Features Not Allowed In External Storage](#file-execution-and-special-file-features-not-allowed-in-external-storage)
- [Some Files Cannot Be Executed Under `/system/bin`](#some-files-cannot-be-executed-under-system-bin)
- [`$PATH` contains incompatible directory paths](#path-contains-incompatible-directory-paths)
- [App Data File Execute Restrictions](#app-data-file-execute-restrictions)
- [Linux vs Termux `bin` paths](#linux-vs-termux-bin-paths)

&nbsp;



### File Execution And Special File Features Not Allowed In External Storage

The shared/public/primary external storage for internal sd card or for external sd card in device slot formatted as [adoptable storage](https://source.android.com/docs/core/storage/adoptable) is mounted at `/storage/emulated/<user_id>` (or its shortcut `/sdcard`), and reliable secondary external storage for external sd card in device slot formatted as [portable storage](https://source.android.com/docs/core/storage) are mounted at `/storage/XXXX-XXXX`. These mounts **emulate the [`fat32` filesystem](https://en.wikipedia.org/wiki/File_Allocation_Table#FAT32)** and use the `sdcardfs` ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/sdcard/sdcard.cpp;l=122)) or `fuse` ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/Utils.cpp;l=1636), [2](https://cs.android.com/android/_/android/platform/system/vold/+/a438b2436886a9d1dbb865c891cc5ec9ececba09)) filesystems depending on Android version/build, ([1](https://source.android.com/docs/core/storage/fuse-passthrough), [2](https://source.android.com/docs/core/storage/sdcardfs-deprecate)) and **use the `noexec` `mount` flag**. These mounts and are accessible to apps with direct file-access if storage permission ([1](https://developer.android.com/training/data-storage/manage-all-files), [2](https://github.com/termux/termux-app/issues/71#issuecomment-1869222653)) is granted or via [SAF APIs](https://developer.android.com/guide/topics/providers/document-provider). The `Android/data` and `Android/obb` directories are mounted with a `tmpfs` filesystem and also have the `noexec` `mount` flag. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/VolumeManager.cpp;l=737-749))

The reliable secondary external storage for external sd card in device slot is initially mounted at `/mnt/media_rw/XXXX-XXXX` with their original filesystem before being mounted at `/storage/XXXX-XXXX` with an emulated filesystem. The unreliable secondary external storages, like for USB OTG drives are only mounted at `/mnt/media_rw/XXXX-XXXX` with their original filesystem, but not mounted at `/storage/XXXX-XXXX` with an emulated filesystem. These initial mounts primarily only support the [`exfat`](https://en.wikipedia.org/wiki/ExFAT) ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/model/PublicVolume.cpp;l=150), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/fs/Exfat.cpp;l=60)) and related filesystems, or in some cases the [`ext4`](https://en.wikipedia.org/wiki/Ext4) ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/model/PrivateVolume.cpp;l=143), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/vold/fs/Ext4.cpp;l=134)) filesystem, and also use the `noexec` `mount` flag. The `/mnt/media_rw/XXXX-XXXX` mounts for reliable storages are not accessible to apps without root access. The `/mnt/media_rw/XXXX-XXXX` mounts for unreliable storages are accessible to apps with root access, or with the [`MANAGE_EXTERNAL_STORAGE`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/res/AndroidManifest.xml;l=1241) permission on Android `>= 12`. ([1](https://github.com/termux/termux-app/issues/71#issuecomment-1869222653))

Following are some of the features not supported by external storage filesystems like at `/sdcard`/`/storage/emulated/0` that emulate a `fat` filesystem, which are [supported by other filesystems](https://en.wikipedia.org/wiki/Comparison_of_file_systems) that are commonly used on Linux distros and for Android private app data directory, like [`ext4`](https://en.wikipedia.org/wiki/Ext4) or [`f2fs`](https://en.wikipedia.org/wiki/F2FS) filesystems.

- **Files cannot be executed directly with their path** due to the [`noexec` `mount` flag](https://manpages.debian.org/testing/mount/mount.8.en.html), like with `/sdcard/file` or `./file`. However, if the file is script file instead of a binary file, then it can be passed to its respective shell for it to be executed, like with `bash /sdcard/script`. However, it is **highly recommended to not execute files on public storages** that can be accessed by other apps as it is a **huge security risk**, since other malicious apps could modify such files and when user executes them in Termux, malicious code could run in Termux user context, or even `root` user context if Termux app has been granted root permissions.
- **No hard or soft symlink files can be created.**
- **Files do support modifications of file permissions or ownership attributes**.
- **Filenames are [case insensitive](https://en.wikipedia.org/wiki/File_system#File_names)**, i.e `foo` and `FOO` and `FoO`, etc would be considered the same file.

Due, to these issues, **using external storage directories will cause problems for certain programs**, like creating `git` repositories or building software that require special features, check [`termux/termux-app#3385`](https://github.com/termux/termux-app/issues/3385) and [`termux/termux-app#3777`](https://github.com/termux/termux-app/issues/3777).

However, the **[Termux private app data directory](./Termux-file-system-layout#termux-private-app-data-directory) is not mounted with the `noexec` `mount` flag, and is usually the [`ext4`](https://en.wikipedia.org/wiki/Ext4) or [`f2fs`](https://en.wikipedia.org/wiki/F2FS) filesystem**, which supports symlinks and other file attributes. This directory is also **not accessible to any other app by default and is safe to use**, unless access is explicitly granted by user to it by installing a [`sharedUserId`](https://developer.android.com/guide/topics/manifest/manifest-element#uid) plugin app or via Storage Access Framework (SAF) or Termux APIs.

It is **highly recommended to only keep Termux files under its `$HOME` (`~/`) or `$TERMUX__PREFIX` directories**, but not `~/storage` directories as directories under it would be symlinks to external storage directories created by [`termux-setup-storage`](https://wiki.termux.com/wiki/Termux-setup-storage).

## &nbsp;

&nbsp;



### Some Files Cannot Be Executed Under `/system/bin`

The Android system provided executables that primarily exist under `/system/bin` cannot all be executed by all apps and users as Android has different protections in place.

- The files are assigned different [ownership and permissions](https://en.wikipedia.org/wiki/File-system_permissions#Traditional_Unix_permissions) ([DAC](https://en.wikipedia.org/wiki/Discretionary_access_control)) by Android. This prevents some executables from being executed by app processes or even the `shell` user. Most files have the `root:shell` ownership and `rwxr-xr-x` permissions, allowing `read` and `execute` by `other` users. However, some files like [`secilc`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:external/selinux/secilc/README) and [`uncrypt`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bootable/recovery/uncrypt) have `root:root` ownership and do not allow `other` users to `execute` them, including the `shell` user. Some files like, [`run-as`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/run-as/) have `root:shell` ownership, but `rwxr-x---` permissions, preventing any `other` user than `root` or `shell` to `execute` them. Attempting to execute such files with the wrong user would result in the `Permission denied` error.

- The files are assigned different [SeLinux](https://source.android.com/docs/security/features/selinux) [file context types](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/context-types.md#file-context-types) ([MAC](https://en.wikipedia.org/wiki/Mandatory_access_control)) by Android. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/private/file_contexts;l=222-388)) There are around `92` different context types on Android `14`. Different SeLinux policies exist for different [process context types](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/context-types.md#process-context-types) which define whether a process can execute a file with a specific file context. ([1](https://source.android.com/docs/security/features/selinux/customize#policy-placement), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/public), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/private)) This prevents some executables from being executed by app processes or even the `shell` user. For example, `auditctl` requires executing it as the `root` user. Attempting to execute such files with the wrong user will result in the `inaccessible or not found` error and a [SeLinux `avc` denied](https://source.android.com/docs/security/features/selinux/validate) message will be logged in [`logcat`](https://developer.android.com/tools/logcat), like ` avc:  denied  { getattr } for  path="/system/bin/auditctl" dev="dm-6" ino=161 scontext=u:r:shell:s0 tcontext=u:object_r:auditctl_exec:s0 tclass=file`. Getting file attributes, like with `ls` will also fail for such files if not running as allowed user like `root`. There are also SeLinux policies other than for process/file context types that trigger other errors, [like for the `cmd` command](https://github.com/termux/termux-packages/discussions/8292#discussioncomment-5102555).

- There are additional internal checks during execution for calling `uid` and calling packages as well. Some commands can only be executed by privileged users like `root` or `shell`, like [`am` command can only be executed by them on Android `>= 14`](https://cs.android.com/android/_/android/platform/frameworks/base/+/3ef3f18ba3094c4cc4f954ba23d1da421f9ca8b0). Some commands, like ones that are run through `svc` may require a package name, and cannot be executed as `root`, since it does not have a package name, and requires running them as the `shell` user, which does have the `com.android.shell` package name.

- The are additional internal checks during execution for whether the process has been granted a [permission](https://developer.android.com/guide/topics/permissions/overview) to be able to run the specified command. The permissions are declared in the Android framework `AndroidManifest.xml` under [`Runtime permissions`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/res/AndroidManifest.xml;l=832) or [`Install permissions`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/res/AndroidManifest.xml;l=1875) sections.

The `shell` (`2000`) user for the `com.android.shell` app package, and for commands that are run with `adb shell` (here `shell` refers to [CLI](https://en.wikipedia.org/wiki/Unix_shell), not the user) is a privileged user on Android that is allowed to run a lot of things and make lot of changes, however, it is generally not as privileged as the root user, other than when a package name is required. It has additional SeLinux policies that allow it to execute certain commands that cannot be executed by [untrusted app processes](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/os/selinux/context-types.md#untrusted_app), like ones that give it access to call specific android internal services. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/packages/Shell/AndroidManifest.xml;l=20), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/private/shell.te), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/sepolicy/public/shell.te)) It also has additional [permissions granted to it by default by Android](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/packages/Shell/AndroidManifest.xml;l=25-844) that are checked when certain commands are run, like for `cmd`, `am`, `pm` and `svc` commands.

Following is a truncated list of executables under `/system/bin` that are available on Android `14`, only some of the commonly used commands are listed for brevity.

```shell
# /system/bin/ls -1lZ /system/bin | /system/bin/sed -E 's/^([^ ]+)[ ]+[^ ]+[ ]+([^ ]+[ ]+[^ ]+[ ]+[^ ]+)[^ ]+[ ]+[^ ]+[ ]+[^ ]+[ ]+[^ ]+[ ]+(.*)$/\1 \2 \3/' | sort -k4

-rwxr-xr-x root shell u:object_r:auditctl_exec:s auditctl

-rwxr-xr-x root shell u:object_r:blkid_exec:s blkid

-rwxr-xr-x root shell u:object_r:e2fs_exec:s make_f2fs

-rwxr-xr-x root shell u:object_r:fsck_exec:s e2fsck

-rwxr-xr-x root shell u:object_r:logcat_exec:s logcat

-r-xr-x--- logd logd  u:object_r:logd_exec:s logd

-rwxr-xr-x root shell u:object_r:mtp_exec:s mtpd

-rwxr-xr-x root shell u:object_r:netd_exec:s netd

-rwxr-x--- root shell u:object_r:runas_exec:s run-as

-rwxr-xr-x root shell u:object_r:sdcardd_exec:s sdcard

-rwxr-xr-x root shell u:object_r:shell_exec:s sh

-rwxr-x--- root shell u:object_r:simpleperf_app_runner_exec:s simpleperf_app_runner

-rwxr-xr-x root shell u:object_r:storaged_exec:s storaged

-rwxr-xr-x root shell u:object_r:system_file:s am
lrwxrwxrwx root shell u:object_r:system_file:s app_process -> app_process64
-rwxr-xr-x root shell u:object_r:system_file:s appops
-rwxr-xr-x root shell u:object_r:system_file:s awk
-rwxr-xr-x root shell u:object_r:system_file:s bc
-rwxr-xr-x root shell u:object_r:system_file:s bmgr
lrwxrwxrwx root shell u:object_r:system_file:s cat -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chattr -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chcon -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chgrp -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chmod -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chown -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chroot -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s chrt -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s cmd
-rwxr-xr-x root shell u:object_r:system_file:s content
lrwxrwxrwx root shell u:object_r:system_file:s cp -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s cut -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s date -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s dd -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s debuggerd
-rwxr-xr-x root shell u:object_r:system_file:s device_config
lrwxrwxrwx root shell u:object_r:system_file:s dmesg -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s dpm
-rwxr-xr-x root shell u:object_r:system_file:s dumpsys
lrwxrwxrwx root shell u:object_r:system_file:s echo -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s env -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s file -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s find -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s flock -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s getconf -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s getenforce -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s getevent -> toolbox
lrwxrwxrwx root shell u:object_r:system_file:s getprop -> toolbox
lrwxrwxrwx root shell u:object_r:system_file:s grep -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s groups -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s gsi_tool
lrwxrwxrwx root shell u:object_r:system_file:s id -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s ime
-rwxr-xr-x root shell u:object_r:system_file:s input
lrwxrwxrwx root shell u:object_r:system_file:s linker_asan -> /apex/com.android.runtime/bin/linker
lrwxrwxrwx root shell u:object_r:system_file:s linker_asan64 -> /apex/com.android.runtime/bin/linker64
lrwxrwxrwx root shell u:object_r:system_file:s linker_hwasan64 -> /apex/com.android.runtime/bin/linker64
lrwxrwxrwx root shell u:object_r:system_file:s ln -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s ls -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s lsattr -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s lsof -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s lspci -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s lsusb -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s monkey
lrwxrwxrwx root shell u:object_r:system_file:s mount -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s mountpoint -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s mv -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s nice -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s nohup -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s nsenter -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s pidof -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s ping
-rwxr-xr-x root shell u:object_r:system_file:s ping6
-rwxr-xr-x root shell u:object_r:system_file:s pm
lrwxrwxrwx root shell u:object_r:system_file:s printf -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s ps -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s pwd -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s readelf -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s readlink -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s realpath -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s reboot
lrwxrwxrwx root shell u:object_r:system_file:s restorecon -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s rm -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s screencap
-rwxr-xr-x root shell u:object_r:system_file:s screenrecord
-rwx------ root root  u:object_r:system_file:s secilc
lrwxrwxrwx root shell u:object_r:system_file:s sed -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s sendevent -> toybox
-rwxr-xr-x root shell u:object_r:system_file:s service
lrwxrwxrwx root shell u:object_r:system_file:s setenforce -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s setprop -> toolbox
-rwxr-xr-x root shell u:object_r:system_file:s settings
lrwxrwxrwx root shell u:object_r:system_file:s start -> toolbox
lrwxrwxrwx root shell u:object_r:system_file:s stat -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s stop -> toolbox
-rwxr-xr-x root shell u:object_r:system_file:s svc
lrwxrwxrwx root shell u:object_r:system_file:s top -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s umount -> toybox
lrwxrwxrwx root shell u:object_r:system_file:s uname -> toybox

lrwxrwxrwx root shell u:object_r:system_linker_exec:s linker -> /apex/com.android.runtime/bin/linker
lrwxrwxrwx root shell u:object_r:system_linker_exec:s linker64 -> /apex/com.android.runtime/bin/linker64

-rwxr-xr-x root shell u:object_r:tcpdump_exec:s tcpdump

-rwxr-xr-x root shell u:object_r:toolbox_exec:s toolbox
-rwxr-xr-x root shell u:object_r:toolbox_exec:s toybox

-rwxr-x--- root root  u:object_r:uncrypt_exec:s uncrypt

-rwxr-xr-x root shell u:object_r:zygote_exec:s app_process32
-rwxr-xr-x root shell u:object_r:zygote_exec:s app_process64
```

## &nbsp;

&nbsp;



### `$PATH` contains incompatible directory paths

By default, Termux exports only termux bin path(s) `/data/data/com.termux/files/usr/bin` in the `$PATH` variable for Android `>= 7` and `/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets` for Android `< 7`, but not the `/system/bin` path for Android system bin path, since normally, users should only use termux provided binaries.

If system provided binaries need to be executed, then `/system/bin` can be either be set or appended at end of `$PATH`, like `/data/data/com.termux/files/usr/bin:/system/bin`.

However, if Termux app is using **[`targetSdkVersion`](https://developer.android.com/guide/topics/manifest/uses-sdk-element#target) `>= 29` with the [`termux-exec` `system_linker_exec`](https://github.com/termux/termux-exec/blob/master/site/pages/en/projects/docs/technical/index.md#app-data-file-execute-restrictions) workaround** and a system command under `/system/bin` is executed and **`$PATH` is set to or contains `$TERMUX__PREFIX/bin` before `/system/bin`**, then commands may fail. Termux provides wrappers under `$TERMUX__PREFIX/bin` for some system commands, like for `/system/bin/cmd`. ([1](https://github.com/termux/termux-tools/blob/v1.40.1/scripts/Makefile.am#L47-L59), [2](https://github.com/termux/termux-tools/blob/v1.40.1/scripts/Makefile.am#L83-L93)) If the utilities like `/system/bin/am`, `/system/bin/pm` and `/system/bin/settings` that run `cmd` command themselves are executed **without `$LD_PRELOAD` being set**, then `$TERMUX__PREFIX/bin/cmd` wrapper will attempted to be executed instead of the real `/system/bin/cmd`, which will fail with the `Permission denied` error and a [SeLinux `avc` denied](https://source.android.com/docs/security/features/selinux/validate) message will be logged in [`logcat`](https://developer.android.com/tools/logcat), like `avc:  denied  { execute_no_trans } for  path="/data/data/com.termux/files/usr/bin/cmd" dev="dm-55" ino=46573 scontext=u:r:untrusted_app:s0:c29,c257,c512,c768 tcontext=u:object_r:app_data_file:s0:c29,c257,c512,c768 tclass=file permissive=0 app=com.termux` due to [`App Data File Execute Restrictions`](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/apps/processes/app-data-file-execute-restrictions.md) for `$TERMUX__PREFIX/bin/cmd` being engaged. For example, if `out="$(LD_PRELOAD= /system/bin/pm path com.termux 2>&1 </dev/null)"; echo "$out"` is executed. However, if `$LD_PRELOAD` was set to `termux-exec`, then it would hook the `exec()` call to bypass the restriction, but that's generally not advisable to be set when running system commands. See also [`termux/termux-tools@be50057f`](https://github.com/termux/termux-tools/commit/be50057f).

**To prevent such issues**, make sure termux bin paths do not exist in `$PATH` when running system binaries, like by:  
- Setting it manually in current process environment before running the command with `PATH=/system/bin`.  
- Setting it temporarily for a single command with `LD_LIBRARY_PATH= LD_PRELOAD= PATH=/system/bin command [args...]`.  
- Use [`tudo`](https://github.com/agnostic-apollo/tudo/blob/master/site/pages/en/projects/docs/usage/index.md#path-and-ld_library_path-priorities) and [`sudo`](https://github.com/agnostic-apollo/sudo/blob/master/site/pages/en/projects/docs/usage/index.md#path-and-ld_library_path-priorities) commands with the `-A` or `-AA` flags.

## &nbsp;

&nbsp;



### App Data File Execute Restrictions

If Termux app is running on Android `>= 10` and [uses](https://github.com/termux/termux-app/blob/v0.118.0/gradle.properties#L19) [`targetSdkVersion`](https://developer.android.com/guide/topics/manifest/uses-sdk-element#target) `>= 29`, then as part of Android `W^X` restrictions with the [`0dd738d8`](https://cs.android.com/android/_/android/platform/system/sepolicy/+/0dd738d810532eb41ad8d90520156212ce756648) commit via [SeLinux](https://source.android.com/docs/security/features/selinux) policies, it will not be able to `exec()` its app data files, like under the `/data/data/<package_name>` (for user `0`) directory.

Check [`App Data File Execute Restrictions` android docs](https://github.com/agnostic-apollo/Android-Docs/blob/master/site/pages/en/projects/docs/apps/processes/app-data-file-execute-restrictions.md) for more information on the `W^X` restrictions, including that apply to other app domains.

Check [`termux-exec` `App Data File Execute Restrictions`](https://github.com/termux/termux-exec/blob/master/site/pages/en/projects/docs/technical/index.md#app-data-file-execute-restrictions) docs for more info on a working workaround using `system_linker_exec`.

## &nbsp;

&nbsp;



### Linux vs Termux `bin` paths

If binaries under `/bin` or `/usr/bin` directories or scripts with `/bin/*` or `/usr/bin/*` [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) interpreter paths are executed without [`termux-exec`](https://github.com/termux/termux-exec) being set in `$LD_PRELOAD`, they will either fail to execute with `No such file or directory` errors or will execute the android system binaries under `/system/bin/*` (as `/bin` is a symlink to `/system/bin`) if the same filename exists, instead of executing binaries under the Termux `bin` path `/data/data/com.termux/files/usr/bin`. Check [`termux-exec` `Linux vs Termux `bin` paths`](https://github.com/termux/termux-exec/blob/master/site/pages/en/projects/docs/technical/index.md#linux-vs-termux-bin-paths) and [`termux-tasker` `Termux Environment`](https://github.com/termux/termux-tasker#termux-environment) docs for more info.

---

&nbsp;





## Dynamic Library Linking

The [dynamic linker](https://en.wikipedia.org/wiki/Dynamic_linker) is the part of the operating system that loads and links the shared libraries needed by an executable when it is executed. The kernel is normally responsible for loading both the executable and the dynamic linker. When a [`execve()` system call](https://en.wikipedia.org/wiki/Exec_(system_call)) is made for an [`ELF`](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Program_header) executable, the kernel loads the executable file, then reads the path to the dynamic linker from the `PT_INTERP` entry in [`ELF` program header table](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Program_header) and then attempts to load and execute this other executable binary for the dynamic linker, which then loads the initial executable image and all the dynamically-linked libraries on which it depends and starts the executable. For binaries built for Android, `PT_INTERP` specifies the path to `/system/bin/linker64` for 64-bit binaries and `/system/bin/linker` for 32-bit binaries. The `ELF` file headers can be checked with the [`readelf`](https://www.man7.org/linux/man-pages/man1/readelf.1.html) command, like `readelf --program-headers --dynamic /path/to/executable`.

For Android, libraries are opened and loaded by the system linker (`/system/bin/linker[64]`) as per the following order. Check [`ld.so`](https://manpages.debian.org/testing/manpages/ld.so.8.en.html) and [`dlopen`](https://manpages.debian.org/testing/manpages-dev/dlopen.3.en.html) man page and Android system linker source ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=2209), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1837), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1610), [4](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1477), [5](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1351-1362), [6](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1039), [7](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1160)) for more info.

- If library name contains a path separator `/` like for a relative or absolute path, then it is attempted to be directly opened.  
- Else if library name does not contain a path separator `/`, then following directory paths are searched in-order non-recursively for file with the same [`basename`](https://manpages.debian.org/testing/manpages-dev/basename.3.en.html) as the library name:  
    - The directory paths in the `$LD_LIBRARY_PATH` environment variable.  
    - The directory paths in the `DT_RUNPATH` dynamic section attribute of the binary, if present, but only for library dependency is listed as `DT_NEEDED`.  
    - The [default system library paths](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=102-125) like `/system/lib64`, `/system/lib`.  

Note that for android, if full library path contains [`!/`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker_utils.cpp;l=138), then system linker assumes that the library file may exist inside a `zip`/`apk` file and will attempt to open the library inside the `zip` file before opening full library path itself. ([1](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=999-1001), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=914)). For example `/path/to/foo.apk!/lib/arm64/bar.so` would open the `lib/arm64/bar.so` library inside the `/path/to/foo.apk` `apk` file.

The `DT_RPATH` dynamic section attribute of the binary and the `ld` cache file (`/etc/ld.so.cache`) like other systems is not used.

For info on dynamic linking errors, check [Dynamic Library Linking Errors](#dynamic-library-linking-errors) section below.

For info on `$PATH`, `$LD_LIBRARY_PATH`, `$LD_PRELOAD` environment variables exported by Android and Termux for execution and dynamic linking, check [Path Environment Variables](#path-environment-variables), [Path Environment Variables Exported By Android](#path-environment-variables-exported-by-android), [Path Environment Variables Exported By Termux](#path-environment-variables-exported-by-termux).

---

&nbsp;





## Dynamic Library Linking Errors

If opening, loading and linking the library fails, then the system linker will generate error the [`CANNOT LINK EXECUTABLE`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker_main.cpp;l=257) error, with sub errors like [`library <library> not found`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=1351-1362) and [`cannot locate symbol <symbol> referenced by <executable/dependency_library>`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker_relocate.cpp;l=121), etc. Following are the possible reasons in Termux for linker errors.

- [Package dependencies are outdated](#package-dependencies-are-outdated)
- [`$LD_LIBRARY_PATH` contains incompatible directory paths](#ld_library_path-contains-incompatible-directory-paths)
- [System Libraries are missing](#system-libraries-are-missing)

&nbsp;



### Package dependencies are outdated

Termux packages use a [rolling release](https://en.wikipedia.org/wiki/Rolling_release) update model. All packages must be upgraded together and partial upgrades are not supported in Termux, which are supported on some other Linux distributions.

If a package is upgraded and its dependency packages are not, then linker errors may trigger. This is because the updated package may be requiring different libraries or different symbols in libraries than the one provided by the old dependency library currently installed. So all executables and their dependency libraries may require being upto date to be compatible.

**To prevent or fix such issues, upgrade all packages.**

```shell
pkg upgrade
```

The [`pkg` command is a wrapper script](https://github.com/termux/termux-tools/blob/90ff1a7a/scripts/pkg.in#L341) in Termux around the [`apt`](https://wiki.debian.org/Apt) or [`pacman`](https://wiki.archlinux.org/title/pacman) package managers, depending on the package manager being used by the user in the Termux rootfs.

The `pkg` command depends on `curl`, so if `curl` gets broken, then instead run `apt update && apt full-upgrade` if using `apt` and `pacman -Syu` if using `pacman`.

If `apt` or `pacman` itself gets broken, then their package and dependency `deb`/`tar` files will have to be manually downloaded from the [termux `main` packages repository](https://packages.termux.dev/apt/termux-main/pool/main) and then installed. Otherwise, `$TERMUX__PREFIX` can be deleted or the Termux app reinstalled, but that will result in all Termux package data being lost and will require reinstalling packages again, though `$HOME` can be preserved if just deleting `$TERMUX__PREFIX`.

## &nbsp;

&nbsp;



### `$LD_LIBRARY_PATH` contains incompatible directory paths

As detailed in above sections:
- Android `>= 7`, the `$LD_LIBRARY_PATH` variable must not contain `$TERMUX__PREFIX/lib` or `/system/lib[64]` paths.
- Android `< 7`, the `$LD_LIBRARY_PATH` variable must only contain `$TERMUX__PREFIX/lib` when executing a termux executable under `$TERMUX__ROOTFS`, and must not contain `$TERMUX__PREFIX/lib` or `/system/lib[64]` paths when executing an android provided executable, like under `/system` partition.

This is because if `$LD_LIBRARY_PATH` is set, then the wrong library may be selected by the linker when searching instead of as per `DT_RUNPATH` or default system libraries. **To fix this**:  
- Do not set `$LD_LIBRARY_PATH` in the environment, like with shell rc files (`~/.bashrc`, `~/.profile`, etc).  
- Unset it in the current process environment before running the command with `unset LD_LIBRARY_PATH`.  
- Just unset it temporarily for a single command with `LD_LIBRARY_PATH= command [args...]`.  

**Unsetting both `$LD_LIBRARY_PATH` and `$LD_PRELOAD` is especially necessary for android system commands under `/system/bin`**, like with `LD_LIBRARY_PATH= LD_PRELOAD= command [args...]`, the termux provided wrappers under `$TERMUX__PREFIX/bin` for some system commands already do this. ([1](https://github.com/termux/termux-tools/blob/v1.40.1/scripts/Makefile.am#L47-L59), [2](https://github.com/termux/termux-tools/blob/v1.40.1/scripts/Makefile.am#L83-L93)) The [`tudo`](https://github.com/agnostic-apollo/tudo/blob/master/site/pages/en/projects/docs/usage/index.md#path-and-ld_library_path-priorities) and [`sudo`](https://github.com/agnostic-apollo/sudo/blob/master/site/pages/en/projects/docs/usage/index.md#path-and-ld_library_path-priorities) commands can also be used with the `-A` or `-AA` flags.

The `ffmpeg` executable is one example for this. Check [Listing and Searching Libraries and Symbols](#listing-and-searching-libraries-and-symbols) docs for info on the helper functions used below.

The termux `ffmpeg` depends on system provided `libgui.so`, which recursively depends on system provided `libEGL.so` itself. If `$LD_LIBRARY_PATH` contains `$TERMUX__PREFIX/lib`, then the wrong termux provided `libEGL.so` library from the `libglvnd` package at `$TERMUX__PREFIX/lib/libEGL.so` would get selected instead of the system provided one at `/system/lib64/libgui.so`, which will not contain the required `eglDestroySyncKHR` symbol, causing a linker error.

```shell
$ LD_LIBRARY_PATH="$TERMUX__PREFIX/lib" ffmpeg
CANNOT LINK EXECUTABLE "ffmpeg": cannot locate symbol "eglDestroySyncKHR" referenced by "/system/lib64/libgui.so"...
$ LD_LIBRARY_PATH="$TERMUX__PREFIX/lib:/system/lib64:/system/lib" ffmpeg
CANNOT LINK EXECUTABLE "ffmpeg": cannot locate symbol "eglDestroySyncKHR" referenced by "/system/lib64/libgui.so"...

$ search_dynamic_symbol " eglDestroySyncKHR" 3
/system/lib64/libEGL.so
000000000001b5cc T eglDestroySyncKHR
--
/system/lib/libEGL.so
000130e8 T eglDestroySyncKHR

$ list_library_dependencies "/system/lib64/libgui.so" 1 | grep libEGL
        libEGL.so => /system/lib64/libEGL.so

$ dpkg -S "$TERMUX__PREFIX/lib/libEGL.so"
libglvnd: /data/data/com.termux/files/usr/lib/libEGL.so

$ list_dynamic_symbols "$TERMUX__PREFIX/lib/libEGL.so" | grep " eglDestroySyncKHR"
```

The termux `ffmpeg` depends on termux provided `libavformat.so` from the `ffmpeg` package, which recursively depends on termux provided `libssh.so` itself from the `libssh` package. If `$LD_LIBRARY_PATH` contains `/system/lib64:/system/lib`, then the wrong system provided `libssh.so` library at `/system/lib64/libssh.so` would get selected instead of the termux provided one at `$TERMUX__PREFIX/lib/libssh.so`, which will not contain the required `sftp_read` symbol, causing a linker error.

```shell
$ LD_LIBRARY_PATH="/system/lib64:/system/lib" ffmpeg
CANNOT LINK EXECUTABLE "ffmpeg": cannot locate symbol "sftp_read" referenced by "/data/data/com.termux/files/usr/lib/libavformat.so.60.3.100"...

$ search_dynamic_symbol "sftp_read@" 3
/data/data/com.termux/files/usr/lib/libssh.so
000000000005b81c T sftp_read@@LIBSSH_4_5_0

$ list_library_dependencies "$TERMUX__PREFIX/lib/libavformat.so" 1 | grep libssh
        libssh.so => /data/data/com.termux/files/usr/lib/libssh.so

$ dpkg -S "$TERMUX__PREFIX/lib/libavformat.so"
ffmpeg: /data/data/com.termux/files/usr/lib/libavformat.so

$ dpkg -S "$TERMUX__PREFIX/lib/libssh.so"
libssh: /data/data/com.termux/files/usr/lib/libssh.so

$ search_dynamic_library libssh.so 3
/data/data/com.termux/files/usr/lib/libssh.so
/system/lib64/libssh.so
```

## &nbsp;

&nbsp;



### System Libraries are missing

Termux packages may depend on android system libraries that are considered stable APIs by `NDK`. These vary depending on Android version, and can be checked by reading `/system/etc/public.libraries.txt` on a specific device. Check `NDK` ([Stable APIs docs](https://developer.android.com/ndk/guides/stable_apis), [`meta/system_libs.json`](https://cs.android.com/android/_/android/toolchain/prebuilts/ndk/r26/+/6dae871c87da3f0f798c1d848ad6b7ba83343d43:meta/system_libs.json), [`build/core/system_libs.mk`](https://cs.android.com/android/_/android/toolchain/prebuilts/ndk/r26/+/6dae871c87da3f0f798c1d848ad6b7ba83343d43:build/core/system_libs.mk), [`build/cmake/system_libs.cmake`](https://cs.android.com/android/_/android/toolchain/prebuilts/ndk/r26/+/6dae871c87da3f0f798c1d848ad6b7ba83343d43:build/cmake/system_libs.cmake)), system core ([`/etc/public.libraries.android.txt`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/rootdir/etc/public.libraries.android.txt)), system linker ([`linker_translate_path.cpp`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/libs/native_bridge_support/linker/linker_translate_path.cpp;l=57-129)), and `ART` ([`buildbot-build.sh`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:art/tools/buildbot-build.sh;l=357-399)) for more info.

The libraries are assumed to exist on all Android devices depending on Android version, but may not exist on emulated Termux environments, like [`termux-docker`](https://github.com/termux/termux-docker). This causes linker errors for certain packages if a required library is not available.

For example, `ffmpeg` executable depends on `libandroid.so`, which isn't available in `termux-docker` and requires installing the `libandroid-stub` package to be able to execute the `ffmpeg` command. The `libandroid-stub` package installs a stub version of the library at `$TERMUX__PREFIX/lib/libandroid.so`, which also does not depend on any other system libraries. Check `libandroid-stub` package [`build.sh`](https://github.com/termux/termux-packages/blob/master/packages/libandroid-stub/build.sh), [`f3043a2e`](https://github.com/termux/termux-packages/commit/f3043a2e), [`807c36d1`](https://github.com/termux/termux-packages/commit/807c36d1), [`termux/termux-packages#16680`](https://github.com/termux/termux-packages/pull/16680) and [`termux/termux-packages#16902`](https://github.com/termux/termux-packages/pull/16902) for more info.

```shell
# /etc/public.libraries.android.txt
# See https://android.googlesource.com/platform/ndk/+/master/docs/PlatformApis.md
libandroid.so
libaaudio.so
libamidi.so
libbinder_ndk.so
libc.so
libcamera2ndk.so
libclang_rt.hwasan-aarch64-android.so 64 nopreload
libdl.so
libEGL.so
libGLESv1_CM.so
libGLESv2.so
libGLESv3.so
libicu.so
libicui18n.so
libicuuc.so
libjnigraphics.so
liblog.so
libmediandk.so
libm.so
libnativehelper.so
libnativewindow.so
libneuralnetworks.so nopreload
libOpenMAXAL.so
libOpenSLES.so
libRS.so
libstdc++.so
libsync.so
libvulkan.so
libwebviewchromium_plat_support.so
libz.so
```

---

&nbsp;





## Listing and Searching Libraries and Symbols

The following methods can be used after exporting them in a `bash` shell to list and search libraries or their symbols. Copy and paste them in the terminal or [`source`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-source) them, like by adding them to `~/.bashrc` and starting a new interactive `bash` shell.

For the `search_*` methods, the `mode` parameter should be between `1-3` inclusive.
- If `1` is passed, only `$TERMUX__PREFIX` paths are searched.
- If `2` is passed, only `/system/lib[64]` paths are searched.
- If `3` is passed, both `$TERMUX__PREFIX` and `/system/lib[64]` paths are searched.

```shell
# search_dynamic_library library_name_regex mode [additional_grep_options]
search_dynamic_library() {
local library="$1"; local mode="$2"; shift 2;
[ -z "$library" ] && { echo "library not passed." 1>&2; return 1; };
case "$mode" in ''|*[!1-3]*) echo "mode '$mode' passed is invalid. It must be between 1-3." 1>&2; return 1;;esac
local -a paths=();
{ [ "$mode" = "1" ] || [ "$mode" = "3" ]; } && paths+=("${TERMUX__PREFIX:-$PREFIX}");
{ [ "$mode" = "2" ] || [ "$mode" = "3" ]; } && { [ -d "/system/lib64"  ] && paths+=("/system/lib64"); paths+=("/system/lib"); };
find "${paths[@]}" -name "*.so" -print 2>/dev/null | grep -E "$@" -- "$library"
}

# search_static_library library_name_regex mode [additional_grep_options]
search_static_library() {
local library="$1"; local mode="$2"; shift 2;
[ -z "$library" ] && { echo "library not passed." 1>&2; return 1; };
case "$mode" in ''|*[!1-3]*) echo "mode '$mode' passed is invalid. It must be between 1-3." 1>&2; return 1;;esac
local -a paths=();
{ [ "$mode" = "1" ] || [ "$mode" = "3" ]; } && paths+=("${TERMUX__PREFIX:-$PREFIX}");
{ [ "$mode" = "2" ] || [ "$mode" = "3" ]; } && { [ -d "/system/lib64"  ] && paths+=("/system/lib64"); paths+=("/system/lib"); };
find "${paths[@]}" -name "*.a" -print 2>/dev/null | grep -E "$@" -- "$library"
}


# search_dynamic_symbol symbol_name_regex mode [additional_nm_options]
search_dynamic_symbol() {
local symbol="$1"; local mode="$2"; shift 2;
[ -z "$symbol" ] && { echo "symbol not passed." 1>&2; return 1; };
case "$mode" in ''|*[!1-3]*) echo "mode '$mode' passed is invalid. It must be between 1-3." 1>&2; return 1;;esac
local -a paths=();
{ [ "$mode" = "1" ] || [ "$mode" = "3" ]; } && paths+=("${TERMUX__PREFIX:-$PREFIX}");
{ [ "$mode" = "2" ] || [ "$mode" = "3" ]; } && { [ -d "/system/lib64"  ] && paths+=("/system/lib64"); paths+=("/system/lib"); };
{ while IFS= read -r -d '' lib; do echo "$lib"; nm --dynamic --extern-only --defined-only --demangle "$@" -- "$lib" 2>/dev/null | grep -E -- "$symbol" | grep -v " U "; done < <(find "${paths[@]}" -name "*.so" -print0 2>/dev/null); } | grep -E -B 1 -- "$symbol"
}

# search_static_symbol symbol_name_regex mode [additional_nm_options]
search_static_symbol() {
local symbol="$1"; local mode="$2"; shift 2;
[ -z "$symbol" ] && { echo "symbol not passed." 1>&2; return 1; };
case "$mode" in ''|*[!1-3]*) echo "mode '$mode' passed is invalid. It must be between 1-3." 1>&2; return 1;;esac
local -a paths=();
{ [ "$mode" = "1" ] || [ "$mode" = "3" ]; } && paths+=("${TERMUX__PREFIX:-$PREFIX}");
{ [ "$mode" = "2" ] || [ "$mode" = "3" ]; } && { [ -d "/system/lib64"  ] && paths+=("/system/lib64"); paths+=("/system/lib"); };
{ while IFS= read -r -d '' lib; do echo "$lib"; nm --demangle --defined-only "$@" -- "$lib" 2>/dev/null | grep -E -- "$symbol" | grep -v " U "; done < <(find "${paths[@]}" -name "*.a" -print0 2>/dev/null); } | grep -E -B 1 -- "$symbol"
}


# list_dynamic_symbols library_path [additional_nm_options]
list_dynamic_symbols() {
local library="$1"; shift 1;
[ -z "$library" ] && { echo "library not passed." 1>&2; return 1; };
nm --dynamic --extern-only --defined-only --demangle "$@" -- "$library"
}

# list_static_symbols library_path [additional_nm_options]
list_static_symbols() {
local library="$1"; shift 1;
[ -z "$library" ] && { echo "library not passed." 1>&2; return 1; };
nm --demangle --defined-only "$@" -- "$library"
}


# list_library_dependencies library_path recursive
list_library_dependencies() {
local library="$1"; local recursive="$2"; shift 2;
[ -z "$library" ] && { echo "library not passed." 1>&2; return 1; };
case "$recursive" in ''|*[!0-1]*) echo "recursive '$recursive' passed is invalid. It must be 0 or 1." 1>&2; return 1;;esac
if [ "$recursive" = "0" ]; then readelf --dynamic -- "$library" | grep -F "(NEEDED)"  | sed -E 's/^.*Shared library: \[(.*)\]$/\1/'; else ldd -- "$library"; fi
}
```

## &nbsp;

&nbsp;



**Examples**

```shell
# Search `foo.so` dynamic library in both `$TERMUX__PREFIX` and `/system/lib[64]` paths
search_dynamic_library foo.so 3

# Search `foo.a` static library in only `$TERMUX__PREFIX`
search_static_library foo.a 1

# Search `bar` dynamic library symbol in both `$TERMUX__PREFIX` and `/system/lib[64]` paths
search_dynamic_symbol "bar" 3

# Search `bar` static library symbol in only `/system/lib[64]` paths
search_static_symbol "bar" 2

# List `libtermux-api.so` dynamic library symbols
list_dynamic_symbols "$TERMUX__PREFIX/lib/libtermux-api.so"

# List `libtermux-api.a` static library symbols
list_static_symbols "$TERMUX__PREFIX/lib/libtermux-api.a"

# List `bash` direct dynamic library dependencies
list_library_dependencies "$TERMUX__PREFIX/bin/bash" 0

# List `bash` recursive dynamic library dependencies
list_library_dependencies "$TERMUX__PREFIX/bin/bash" 1
```

---

&nbsp;





## Path Environment Variables

The `$HOME` variable is for the user's home directory. ([1](https://manpages.debian.org/testing/manpages/environ.7.en.html#HOME))

The `$PATH`, `$LD_LIBRARY_PATH` and `$LD_PRELOAD` variables are part of the environment of processes/shells on Unix-like systems. ([1](https://manpages.debian.org/testing/manpages/environ.7.en.html), [2](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html))

The `$PATH` variable is for the list of directory paths separated with colons `:` that certain functions and utilities use in searching for an executable file known only by a file [`basename`](https://manpages.debian.org/testing/manpages-dev/basename.3.en.html). The list of directory paths is searched from beginning to end, by checking the path formed by concatenating a directory path, a path separator `/`, and the executable file `basename`, and the first file found, if any, with execute permission is executed. ([1](https://manpages.debian.org/testing/manpages/environ.7.en.html#PATH))

The `$LD_LIBRARY_PATH` variable is for the list of directory paths separated with colons `:` that should be searched for dynamic/shared library files that are dependencies of executables or libraries to be linked against. The list of directory paths is searched from beginning to end, by checking the path formed by concatenating a directory path, a path separator `/`, and the library file `basename`, and the first file found, if any, with read permission is opened. ([1](https://manpages.debian.org/testing/manpages/ld.so.8.en.html#LD_LIBRARY_PATH))

The `$LD_PRELOAD` variable is for the list of ELF shared object paths separated with colons `:` to be loaded before all others. This feature can be used to selectively override functions in other shared objects. ([1](https://manpages.debian.org/testing/manpages/ld.so.8.en.html#LD_PRELOAD))

---

&nbsp;





## Path Environment Variables Exported By Android

Check [Termux filesystem layout](./Termux-file-system-layout) docs (including [Android Paths](./Termux-file-system-layout#android-paths) section) for more info on the Android filesystem directories.

The Android filesystem rootfs and home (`$HOME`) directory exists at `/`.

The Android system provided executables primarily exist under `/system/bin` that are part of AOSP itself that should exist on all devices depending on Android version as detailed by Android [`shell_and_utilities`](https://android.googlesource.com/platform/system/core/+/master/shell_and_utilities/README.md) docs. The core utilities are primarily provided by `toybox` ([1](http://landley.net/toybox), [2](https://github.com/landley/toybox), [3](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:external/toybox)) for Android `>= 6` and `toolbox` ([1](https://cs.android.com/android/platform/superproject/+/android-5.0.0_r1.0.1:system/core/toolbox)) for Android `< 6` and mostly have limited features compared to `GNU` [`coreutils`](https://www.gnu.org/software/coreutils/manual/coreutils.html) provided by Termux and other linux distros, like [`debian`](https://www.debian.org). Moreover, older android versions do not have all the utilities or their features are missing or are severely broken. Additional apex, vendor or product partition specific ([1](https://source.android.com/docs/core/architecture/partitions), [2](https://source.android.com/docs/core/ota/apex), [3](https://source.android.com/docs/core/architecture/partitions/product-partitions)), or custom ROM specific executables may exist under additional paths like  `/apex`, `/vendor`, `/product` or under `/sbin` and `/system/xbin` directories.

The Android system provided shared libraries exist under `/system/lib64` and/or `/system/lib` ([or instead under `/apex/*/lib`]([`linker_translate_path.cpp`](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker_translate_path.cpp))) depending on if Android is `64-bit` or `32-bit`. Additional libraries may exist under `/odm/lib[64]`, `/vendor/lib[64]`, `/data/asan/system/lib[64]`, `/data/asan/odm/lib[64]` and `/data/asan/vendor/lib[64]`. The executables compiled for Android system do not use `DT_RUNPATH` or `$LD_LIBRARY_PATH`, and rely on [`linker` to search in default library paths](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=3391) listed earlier. Check [`ld.so`](https://manpages.debian.org/testing/manpages/ld.so.8.en.html) and [`dlopen`](https://manpages.debian.org/testing/manpages-dev/dlopen.3.en.html) man page and [Android system linker (`/system/bin/linker[64]`) source](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/linker/linker.cpp;l=102-125) for more info.

The Android system does not provide any `$LD_PRELOAD` library.

Check following source links for info for which other environmental variables are exported by Android via `init` startup.

- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:frameworks/base/core/java/android/os/Environment.java
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:system/core/rootdir/init.environ.rc.in
- https://cs.android.com/android/_/android/platform/system/core/+/refs/tags/android-14.0.0_r1:rootdir/init.rc;l=1022
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:packages/modules/SdkExtensions/derive_classpath/derive_classpath.cpp;l=147
- https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/include/paths.h

&nbsp;

The Android system exports path variables with the following default values for shells started for [`adb`](https://developer.android.com/tools/adb) and for app environments depending on the Android version. For info on `$PATH`, `$LD_LIBRARY_PATH`, `$LD_PRELOAD` environment variables, check [Path Environment Variables](#path-environment-variables).

- `$HOME`: `/`. ([1](./Termux-file-system-layout#android-rootfs-directory))  
- `$PATH`: ([1](./Termux-file-system-layout#android-bin-directory))  
    - Android `>= 11`: `/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin` ([1](https://cs.android.com/android/platform/superproject/+/android-11.0.0_r1:bionic/libc/include/paths.h;l=50), [2](https://cs.android.com/android/platform/superproject/+/android-14.0.0_r1:bionic/libc/include/paths.h;l=50))  
    - Android `>= 10`: `/sbin:/system/sbin:/product/bin:/apex/com.android.runtime/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin` ([1](https://cs.android.com/android/platform/superproject/+/android-10.0.0_r1:bionic/libc/include/paths.h;l=50))  
    - Android` >= 9`: `/sbin:/system/sbin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin` ([1](https://cs.android.com/android/platform/superproject/+/android-9.0.0_r1:bionic/libc/include/paths.h;l=41))  
    - Android` >= 8`: `/sbin:/system/sbin:/system/bin:/system/xbin:/vendor/bin:/vendor/xbin` ([1](https://cs.android.com/android/platform/superproject/+/android-8.0.0_r1:bionic/libc/include/paths.h;l=39))  
    - Android` < 8`: `/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin` ([1](https://cs.android.com/android/platform/superproject/+/android-7.0.0_r1:bionic/libc/include/paths.h;l=37), [2](https://cs.android.com/android/_/android/platform/system/core/+/refs/tags/android-5.0.0_r1:rootdir/init.environ.rc.in;l=3))  
- `$LD_LIBRARY_PATH`: Not set by default. ([1](./Termux-file-system-layout#android-lib-directory))  
- `$LD_PRELOAD`: Not set by default.  

---

&nbsp;





## Path Environment Variables Exported By Termux

Check [Termux filesystem layout](./Termux-file-system-layout) docs (including [Termux Paths](./Termux-file-system-layout#termux-paths) and [File Path Limits](./Termux-file-system-layout#file-path-limits) sections) and [`properties.sh`](https://github.com/termux/termux-packages/blob/master/scripts/properties.sh) file for more info on the Termux filesystem directories and variables.

As mentioned in the [Execution](#execution) section, termux packages **are specifically compiled for the Termux `rootfs` directory `/data/data/com.termux/files` (`$TERMUX__ROOTFS`), based on the Termux app package name `com.termux` and the expected [private app data directory](https://developer.android.com/reference/android/content/pm/ApplicationInfo#dataDir) `/data/data/com.termux`** android would assign to the app on installation if its installed on the primary user `0` of the device, as that would be the only directory that an app can access and place its files in and execute files from, which are also kept private from other apps as well for security reasons, The app data directory path assigned by Android will be different if the app package name is changed, or app is installed on a [secondary user](https://source.android.com/docs/devices/admin/multi-user), [work profile](https://developer.android.com/work/managed-profiles) or [adoptable storage](https://source.android.com/docs/core/storage/adoptable) and so **Termux app must be installed in primary user `0`**, unless all its packages are re-compiled for the changes done.

The Termux provided executables currently primarily exist under `/data/data/com.termux/files/usr/bin` (`$TERMUX__PREFIX/bin`). Some packages, like `busybox`, may have their executables under `/data/data/com.termux/files/usr/bin/applets` (`$TERMUX__PREFIX/bin/applets`). The core utilities are provided by `GNU` [`coreutils`](https://www.gnu.org/software/coreutils/manual/coreutils.html) to have a consistent experience with other linux distros, like [`debian`](https://www.debian.org).

The Termux provided shared libraries exist under `/data/data/com.termux/files/usr/lib` (`$TERMUX__PREFIX/lib`). The executables are compiled with `DT_RUNPATH` for Android `>= 7` and do not use `$LD_LIBRARY_PATH`. For Android `5` and `6`, `$LD_LIBRARY_PATH` is used. The `RUNPATH` value can be checked with `readelf -d $TERMUX__PREFIX/bin/<executable>`. Check [`ld.so`](https://manpages.debian.org/testing/manpages/ld.so.8.en.html) and [`dlopen`](https://manpages.debian.org/testing/manpages-dev/dlopen.3.en.html) man page, [`termux-packages` build infrastructure `termux_setup_toolchain`](https://github.com/termux/termux-packages/blob/83e3271c/scripts/build/toolchain/termux_setup_toolchain_26b.sh#L34) ([`c508560e`](https://github.com/termux/termux-packages/commit/c508560e), [`b997c4ea`](https://github.com/termux/termux-packages/commit/b997c4ea)), [termux `clang` package](https://github.com/termux/termux-packages/blob/3b316cfc1782dbe004be880327f98a69e04e573d/packages/libllvm/clang-lib-Driver-ToolChains-Linux.cpp.patch#L32-L41) ([`a4a2aa58`](https://github.com/termux/termux-packages/commit/a4a2aa58), [`d3f8fea1`](https://github.com/termux/termux-packages/commit/d3f8fea1), [`3b316cfc`](https://github.com/termux/termux-packages/commit/3b316cfc)), [`termux-packages` build infrastructure `termux-elf-cleaner`](https://github.com/termux/termux-packages/blob/83e3271c8cf7e11b02ad2a7485dc64a8f6ea89b6/scripts/build/termux_step_massage.sh#L60-L64) and [`termux-elf-cleaner` source](https://github.com/termux/termux-elf-cleaner/blob/v2.2.1/elf-cleaner.cpp#L167) ([`623f314c`](https://github.com/termux/termux-elf-cleaner/commit/623f314c)) for more info.

The Termux provided `$LD_PRELOAD` library implemented by [`termux-exec`](https://github.com/termux/termux-exec) exists at `/data/data/com.termux/files/usr/lib/libtermux-exec.so` (`$TERMUX__PREFIX/lib/libtermux-exec.so`).

Check following source links for info for which other environmental variables are exported by Termux app via `TermuxShellEnvironment.getEnvironment()` method.

- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/termux/shell/command/environment/TermuxShellEnvironment.java
- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/termux/shell/command/environment/TermuxAppShellEnvironment.java
- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/termux/shell/command/environment/TermuxShellCommandShellEnvironment.java
- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/shell/command/environment/ShellCommandShellEnvironment.java
- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/shell/command/environment/AndroidShellEnvironment.java
- https://github.com/termux/termux-app/blob/master/termux-shared/src/main/java/com/termux/shared/shell/command/environment/UnixShellEnvironment.java

The Termux app via [`TermuxShellEnvironment`](https://github.com/termux/termux-app/blob/f102ea20/termux-shared/src/main/java/com/termux/shared/termux/shell/command/environment/TermuxShellEnvironment.java#L41-L48) class exports the `$PATH` and `$LD_LIBRARY_PATH` variables for shells started with the following default values. The [`$TERMUX__PREFIX/bin/login`](https://github.com/termux/termux-tools/blob/v1.40.5/scripts/login.in#L42-L45) script exports the `$LD_PRELOAD` variable currently and is the only core variable that is not exported by the Termux app. For info on `$PATH`, `$LD_LIBRARY_PATH`, `$LD_PRELOAD` environment variables, check [Path Environment Variables](#path-environment-variables).

The following `$TERMUX__` scoped variables are for the currently running Termux rootfs/app environment and **should not be changed by programs** and are only available for Termux app version `>= 0.119.0`.

- `$TERMUX_APP__DATA_DIR`: `/data/data/com.termux`. ([1](./Termux-file-system-layout#termux-private-app-data-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__PROJECT_DIR`: `/data/data/com.termux/termux`. ([1](./Termux-file-system-layout#termux-project-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__CORE_DIR`: `/data/data/com.termux/termux/core`. ([1](./Termux-file-system-layout#termux-core-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__APPS_DIR`: `/data/data/com.termux/termux/apps`. ([1](./Termux-file-system-layout#termux-apps-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__CACHE_DIR`: `/data/data/com.termux/cache`. ([1](./Termux-file-system-layout#termux-app-cache-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__ROOTFS`: `/data/data/com.termux/files`. ([1](./Termux-file-system-layout#termux-rootfs-directory)) (Added in Termux app `v0119.0`)  
- `$TERMUX__HOME`: `/data/data/com.termux/files/home`. ([1](./Termux-file-system-layout#termux-home-directory)) (Added in Termux app `v0119.0`)  
- `$HOME`: `/data/data/com.termux/files/home`. ([1](./Termux-file-system-layout#termux-home-directory))  
- `$TERMUX__PREFIX`: `/data/data/com.termux/files/usr`. ([1](./Termux-file-system-layout#termux-prefix-directory)) (Added in Termux app `v0119.0`)  
- `$PREFIX`: `/data/data/com.termux/files/usr`. ([1](./Termux-file-system-layout#termux-prefix-directory)) (Deprecated in Termux app `v0119.0`)  
- `$PATH`: ([1](./Termux-file-system-layout#termux-bin-directory))  
    - Android `>= 7`: `/data/data/com.termux/files/usr/bin`  
    - Android `< 7`: `/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets`  
- `$LD_LIBRARY_PATH`: ([1](./Termux-file-system-layout#termux-lib-directory))  
    - Android `>= 7`: Not set by default.  
    - Android `< 7`: `/data/data/com.termux/files/usr/lib`  
- `$LD_PRELOAD`: `/data/data/com.termux/files/usr/lib/libtermux-exec.so`  

---

&nbsp;
