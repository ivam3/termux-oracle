## General

- Most programs expect that target is [FHS](https://uk.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)
  compliant. They have hardcoded paths like `/etc`, `/bin`, `/usr/share`, `/tmp`
  which are not available in Termux at standard locations but only in `$TERMUX_PREFIX`.

- `tmpnam()` function may not respect `TMPDIR` variable and use hardcoded path to `/tmp` directory on
  some Android builds. This was changed by [commit 439ebbd3](https://cs.android.com/android/_/android/platform/bionic/+/439ebbd3492ad3a8b8398fa80b0860baeb50a40e)
  in Bionic libc but some new devices still use the old `tmpnam()` implementation.

- The Android bionic libc does not have iconv and gettext/libintl functionality
  built in. A `libandroid-support` package contains these and may be used by all
  packages.

- "error: z: no archive symbol table (run ranlib)" usually means that the build
  machine's libz is used instead of the one for cross-compilation due to the
  builder library -L path being setup incorrectly.

- rindex(3) does not exist, but strrchr(3) is preferred anyway.

- &lt;sys/termios.h&gt; does not exist, but &lt;termios.h&gt; is the standard
  location.

- &lt;sys/fcntl.h&gt; does not exist, but &lt;fcntl.h&gt; is the standard
  location.

- &lt;sys/timeb.h&gt; does not exist (removed in POSIX 2008), but ftime(3) can
  be replaced with gettimeofday(2).

- &lt;glob.h&gt; does not exist, but is available through the `libandroid-glob`
  package.

- SYSV shared memory is not supported by the kernel. A `libandroid-shmem`
  package, which emulates SYSV shared memory on top of the [ashmem](http://elinux.org/Android_Kernel_Features#ashmem)
  shared memory system, is available. Use it with `LDFLAGS+=" -landroid-shmem`.

- SYSV semaphores are not supported by the kernel. The package `libandroid-posix-semaphore` supports named semaphores and functions such as `sem_open`, `sem_close` and `sem_unlink`.

- Starting from Android 8, a [Seccomp](https://android-developers.googleblog.com/2017/07/seccomp-filter-in-android-o.html)
  was enabled for applications. Seccomp forbids usage of some system calls
  which results in crash with `Bad system call` errors.

- Starting from Android 8, programs cannot use `tcsetattr()` with `TCSAFLUSH`
  parameter due to SELinux. Use `TCSANOW` instead.

- Starting from Android 9, [Seccomp](https://android-developers.googleblog.com/2017/07/seccomp-filter-in-android-o.html)
  began to block `setuid()`-related system calls. Since Termux is primarily for
  single-user non-root usage, setuid/setgid functionality is discouraged anyway.

## dlopen() and RTLD&#95;&#42; flags

&lt;dlfcn.h&gt; declares
```C
RTLD_NOW=0; RTLD_LAZY=1; RTLD_LOCAL=0; RTLD_GLOBAL=2;       RTLD_NOLOAD=4; // 32-bit
RTLD_NOW=2; RTLD_LAZY=1; RTLD_LOCAL=0; RTLD_GLOBAL=0x00100; RTLD_NOLOAD=4; // 64-bit
```
These differs from glibc ones in that

1. They differ in value from glibc ones, so cannot be hardcoded in files
   (DLFCN.py in python does this)

2. They are missing some values (`RTLD_BINDING_MASK`, ...)

## Android Dynamic Linker

The Android dynamic linker is located at `/system/bin/linker` (32-bit) or
`/system/bin/linker64` (64-bit). Here are source links to different versions of
the linker:

- [Android 5.0 linker](https://android.googlesource.com/platform/bionic/+/lollipop-mr1-release/linker/linker.cpp)

- [Android 6.0 linker](https://android.googlesource.com/platform/bionic/+/marshmallow-mr1-release/linker/linker.cpp)

- [Android 7.0 linker](https://android.googlesource.com/platform/bionic/+/nougat-mr1-release/linker/linker.cpp)

Some notes about the linker:

- The linker warns about unused [dynamic section entries](https://docs.oracle.com/cd/E23824_01/html/819-0690/chapter6-42444.html)
  with a `WARNING: linker: $BINARY: unused DT entry: type ${VALUE_OF_d_tag}`
  message.

- The supported types of dynamic section entries have increased over time.

- The Termux build system uses [termux-elf-cleaner](https://github.com/termux/termux-elf-cleaner)
  to strip away unused ELF entries causing the above mentioned linker warnings.

- `DT_RPATH`, the list of directories where the linker should look for shared
  libraries is not supported, so is stripped away. `DT_RUNPATH` should be used
  instead (supported since Android 7.0).

- Symbol visibility when opening shared libraries using `dlopen()` works
  differently. On a normal linker, when an executable linking against a shared
  library libA dlopen():s another shared library libB, the symbols of libA are
  exposed to libB without libB needing to link against libA explicitly. This
  does not work with the Android linker, which can break plug-in systems where
  the main executable dlopen():s a plug-in which does not explicitly link against
  some shared libraries already linked to by the executable.
  See [the relevant NDK issue](https://github.com/android-ndk/ndk/issues/201)
  for more information.
