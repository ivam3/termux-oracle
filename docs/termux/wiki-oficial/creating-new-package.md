# Package Build Config

### Contents

- [Requirements](#requirements)
- [Package Build Script](#package-build-script)
  - [Package Build Script Variables](#package-build-script-variables)
  - [Package Build Step Overrides](#package-build-step-overrides)
  - [Package Build Source URLs](#package-build-source-urls)
- [Subpackage Build Script](#subpackage-build-script)
  - [Subpackage Build Script Variables](#subpackage-build-script-variables)
  - [Subpackage Dependencies](#subpackage-dependencies)
 [Reserved Package Build Variables](#reserved-package-build-variables)

---

&nbsp;





## Requirements

The following requirements exist for packages that need to be built with the `termux-package` build infrastructure and to added to the list of supported packages.

- No operations requiring `root` privileges.
- No operations modifying files outside of build directory or `$TERMUX__PREFIX`.
- All scripts must be formatted according [Coding guideline](./Coding-guideline).

---

&nbsp;





## Package Build Script

Package build script (`build.sh`) is a [`bash`](https://www.gnu.org/software/bash) script that contains definitions for variables/metadata and (if needed) instructions for Termux build system on how to build the package. Such scripts are internally [used](./Building-packages#build-process) by the [`build-package.sh`] script and are not standalone.

The `build.sh` file for a package exist under the `<repo_channel>/<package_name>` directory in the `termux-packages` repo root directory where `repo_channel` refers to the repository `channel` of the package, whose directory is specified in the [`repo.json`](https://github.com/termux/termux-packages/blob/master/repo.json) file.

Termux packages repository hosted on https://packages.termux.dev provides all of its packages in different repository `channels`. A repository `channel` is simply a location which holds packages of similar types, which can be downloaded and installed using a package manager, and each channel has a different purpose. A package can only exist in one repository channel. There are currently `3` repository channels. By default, only packages from the `main` channel can be installed. To install packages from other channels, then that can be set up by installing their respective `channel setup package` provided by the `main` channel, which automatically adds the channel to the `sources.list`.

- `main` channel:  
  - Purpose: Packages that can be run in the Terminal and have no special requirements.  
  - Package sources: https://github.com/termux/termux-packages/tree/master/packages  
  - Package builds: https://packages.termux.dev/apt/termux-main  
- `root` channel:  
  - Purpose: Packages that require Termux app to be granted `root` access.  
  - Package sources: https://github.com/termux/termux-packages/tree/master/root-packages  
  - Package builds: https://packages.termux.dev/apt/termux-root  
  - Channel setup package: [`root-repo`](https://github.com/termux/termux-packages/blob/master/packages/root-repo/build.sh)  
- `x11` channel:  
  - Purpose: Packages related to [`X11`](https://en.wikipedia.org/wiki/X_Window_System) and their libraries that require a GUI.  
  - Package sources: https://github.com/termux/termux-packages/tree/master/x11-packages  
  - Package builds: https://packages.termux.dev/apt/termux-x11  
  - Channel setup package: [`x11-repo`](https://github.com/termux/termux-packages/blob/master/packages/x11-repo/build.sh)  

For example, for a package named `foo`, the following package `build.sh` source paths may be used.

- `main` channel: `packages/foo/build.sh`
- `root` channel: `root-packages/foo/build.sh`
- `x11` channel: `x11-packages/foo/build.sh`

Following is an example of a minimal working package build script.

```shell
# http(s) link to package home page.
TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/ed/

# One-line, short package description.
TERMUX_PKG_DESCRIPTION="Classic UNIX line editor"

# License.
# Use SPDX identifier: https://spdx.org/licenses/
TERMUX_PKG_LICENSE="GPL-2.0"

# Who maintains the package.
# Specify yourself (Github nick, or name + email) if you wish to maintain the
# package, fix its bugs, etc. Otherwise specify "@termux".
# Please note that unofficial repositories are not allowed to reference @termux
# as their maintainer.
# See also:
# - https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-maintainer
# - https://www.debian.org/doc/debian-policy/ch-binary.html#s-maintainer
TERMUX_PKG_MAINTAINER="@termux"

# Version.
TERMUX_PKG_VERSION=1.15

# URL to archive with source code.
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/ed/ed-${TERMUX_PKG_VERSION}.tar.lz

# SHA-256 checksum of the source code archive.
TERMUX_PKG_SHA256=ad4489c0ad7a108c514262da28e6c2a426946fb408a3977ef1ed34308bdfd174
```
Note that order of fields like shown above is preferred. In the above example there are no build step overrides as the default ones are enough to successfully build the package.

[`build-package.sh`] can automatically detect following build systems:

- Autotools
- CMake
- Meson
- Haskell (or cabal)

**NOTE:** If packaging Haskell packages also see [this](./Haskell-package-guidelines).

To pass some additional arguments, use the field `TERMUX_PKG_EXTRA_CONFIGURE_ARGS`.

See also [Auto updating packages](./Auto-updating-packages).

## &nbsp;



### Package Build Script Variables

| Order | Variable | Required | Description |
| -----:|:-------- |:--------:|:----------- |
| 1     | `TERMUX_PKG_HOMEPAGE` | yes | Home page URL. |
| 2     | `TERMUX_PKG_DESCRIPTION` | yes | Short, one-line description of package. |
| 3     | `TERMUX_PKG_LICENSE` | yes | Package license. |
| 4     | `TERMUX_PKG_LICENSE_FILE` | no | Name of license file, if it is not found automatically. |
| 5     | `TERMUX_PKG_MAINTAINER` | yes | Package maintainer. |
| 6     | `TERMUX_PKG_API_LEVEL` | no | Android API level for which package should be compiled. |
| 7     | `TERMUX_PKG_VERSION` | yes | Original package version. |
| 8     | `TERMUX_PKG_REVISION` | no | Package revision. Bumped on each package rebuild. |
| 9     | `TERMUX_PKG_SKIP_SRC_EXTRACT` | no | Whether to omit source code downloading and extraction. Default is **false**. |
| 10    | `TERMUX_PKG_SRCURL` | not, if source extraction was skipped | URL from which source archive should be downloaded, either an archive or a git url ending with .git |
| 11    | `TERMUX_PKG_SHA256` | not, if source URL was not set | SHA-256 checksum of source archive. |
| 12    | `TERMUX_PKG_GIT_BRANCH` | no | Branch to checkout in termux_step_git_clone_src. Default is `v$TERMUX_PKG_VERSION`. |
| 13    | `TERMUX_PKG_METAPACKAGE` | no | Whether to make package treated as metapackage. Default is **false**. |
| 14    | `TERMUX_PKG_DEPENDS` | no | Comma-separated list of dependency package names. |
| 15    | `TERMUX_PKG_BUILD_DEPENDS` | no | Comma-separated list of build-time only dependencies. |
| 16    | `TERMUX_PKG_BREAKS` | no | Comma-separated list of packages that are incompatible with the current one. |
| 17    | `TERMUX_PKG_CONFLICTS` | no | Comma-separated list of packages which have file name collisions with the current one. |
| 18    | `TERMUX_PKG_REPLACES` | no | Comma-separated list of packages being replaced by current one. |
| 19    | `TERMUX_PKG_PROVIDES` | no | Comma-separated list of virtual packages being provided by current one. |
| 20    | `TERMUX_PKG_RECOMMENDS` | no | Comma-separated list of non-absolute dependencies.<br>***These are installed by default along with the package.*** |
| 21    | `TERMUX_PKG_SUGGESTS` | no | Comma-separated list of packages that are related to or enhance the current one.<br>These are not installed with the package by default. |
| 22    | `TERMUX_PKG_ESSENTIAL` | no | Whether to treat package as essential which cannot be uninstalled in usual way. Default is **false**. |
| 23    | `TERMUX_PKG_NO_STATICSPLIT` | no | Whether to split static libraries into a subpackage. Default is **false**. |
| 24    | `TERMUX_PKG_STATICSPLIT_EXTRA_PATTERNS` | no | Extra patterns to include in static package. It must be relative to `$TERMUX__PREFIX`. For example: to include `*.h` files from `$TERMUX__PREFIX/lib`, specify `lib/*.h`. Use bash globstar patterns to recurse sub-directories. |
| 25    | `TERMUX_PKG_IS_HASKELL_LIB` | no | Whether the package is haskell library. Default is `false`. |
| 26    | `TERMUX_PKG_BUILD_IN_SRC` | no | Whether to perform build in a source code directory. Default is **false**. |
| 27    | `TERMUX_PKG_HAS_DEBUG` | no | Whether debug builds are possible for package. Default is **true**. |
| 28    | `TERMUX_PKG_PLATFORM_INDEPENDENT` | no | Whether to treat package as platform independent. Default is **false**. |
| 29    | `TERMUX_PKG_EXCLUDED_ARCHES` | no | Comma-separated list of CPU architectures for which package cannot be compiled. |
| 30    | `TERMUX_PKG_HOSTBUILD` | no | Whether package require building for host. Default is **false**. |
| 31    | `TERMUX_PKG_FORCE_CMAKE` | no | Whether to prefer CMake over Autotools configure script. Default is **false**. |
| 32    | `TERMUX_PKG_EXTRA_CONFIGURE_ARGS` | no | Extra arguments passed to build system configuration utility. |
| 33    | `TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS` | no | Extra arguments passed to build system configuration utility when performing host build. |
| 34    | `TERMUX_PKG_EXTRA_MAKE_ARGS` | no | Extra arguments passed to utility `make`. |
| 35    | `TERMUX_PKG_MAKE_INSTALL_TARGET` | no | Equivalent for `install` argument passed to utility `make` in the installation process. |
| 36    | `TERMUX_PKG_RM_AFTER_INSTALL` | no | List of files that should be removed after installation process. |
| 37    | `TERMUX_PKG_CONFFILES` | no | A space or newline separated list of package configuration files that should not be overwritten on update. |
| 38    | `TERMUX_PKG_SERVICE_SCRIPT` | no | Array of even length containing daemon name(s) and script(s) for use with [termux-services/runit](https://wiki.termux.com/wiki/Termux-services). |
| 39    | `TERMUX_PKG_GO_USE_OLDER` | no | Use the older supported release of Go (1.19.7). Default is **false**. |
| 40    | `TERMUX_PKG_NO_STRIP` | no | Disable stripping binaries. Default is **false**. |
| 41    | `TERMUX_PKG_NO_SHEBANG_FIX` | no | Skip fixing shebang accordingly to $TERMUX__PREFIX. Default is **false**. |
| 42    | `TERMUX_PKG_NO_ELF_CLEANER` | no | Disable running of termux-elf-cleaner on built binaries. Default is **false**. |
| 43    | `TERMUX_PKG_NO_STRIP` | no | Disable stripping binaries. Default is **false**. |
| 44    | `TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED` | no | Whether this package does not support compilation on a device. Default is **false**. |

## &nbsp;



### Package Build Step Overrides

Following is a list of package build steps that can be overridden by the `build.sh` script. Complete reference for all build steps can be found in [Building packages](./Building-packages#build-steps-reference).

| Execution order | Function name | Description |
| ---------------:|:-------------:|:----------- |
| 1               | `termux_step_get_source` | Obtain package source code and put it in `$TERMUX_PKG_SRCDIR`. |
| 2               | `termux_step_post_get_source` | Hook to run commands immediately after obtaining source code. |
| 3               | `termux_step_handle_host_build` | Determine whether a host build is required. |
| 4               | `termux_step_host_build` | Perform a host build. |
| 5               | `termux_step_pre_configure` | Hook to run commands before source configuration. |
| 6               | `termux_step_configure` | Configure sources. By default, it determines build system automatically. |
| 7               | `termux_step_post_configure` | Hook to run commands immediately after configuration. |
| 8               | `termux_step_make` | Compile the source code. |
| 9               | `termux_step_make_install` | Install the compiled artifacts. |
| 10              | `termux_step_post_make_install` | Hook to run commands immediately after installation. |
| 11              | `termux_step_install_license` | Link or copy package-specific LICENSE to `./share/doc/$TERMUX_PKG_NAME`. |
| 12              | `termux_step_post_massage` | Final hook before creating `*.deb` file(s). |
| 13              | `termux_step_create_debscripts` | In this step the `./preinst`, `./postinst`, `./prerm` or `./postrm` scripts can be created which will be executed during the package installation or removing. |

## &nbsp;



### Package Build Source URLs

The `$TERMUX_PKG_SRCURL` in the `build.sh` file defines the URL for where to download the package source. It can either be a remote `*https://*` URL or a local `*file://*` URL.


#### Package Build Remote Source URLs

Remote package source URLs are in the `*https://domain/path` format where `https://` is the [scheme](https://en.wikipedia.org/wiki/File_URI_scheme).

The [`build-package.sh`] scripts support `2` formats for remote `https://` URLs, and both have their own build time behaviour.

- **`https://domain/path` URL** for package source release `tar`/`zip` file.  
    - When the build is started for the package, the source file will be downloaded if not already download and its checksum will be compared against the value set in `$TERMUX_PKG_SHA256` variable of the `build.sh` file, unless its set to `SKIP_CHECKSUM`. If checksum does not match, then build with fail with a `Wrong checksum` error.
    - If package is being rebuilt and `$TERMUX_PKG_SHA256` is not set to `SKIP_CHECKSUM`, like with the [`-f`]/[`-F`] flags and source file already exists, then checksum will be checked again against the already downloaded file, and if it does not match, then package source will be re-downloaded and checksum re-checked. However, if checksum matches against the existing local file, then it will be used without downloading source again.  
    - If package is being rebuilt and `$TERMUX_PKG_SHA256` is set to `SKIP_CHECKSUM`, then package source will be re-downloaded every time and no checksum will be checked.  
    - Any value for the `$TERMUX_PKG_GIT_BRANCH` variable in the `build.sh` of the package will be ignored.  

- **`git+https://*.git` URL** for package remote [`git`] source repository.  
    - The URL path should end with `.git` and host a remote `git` repository. ([1](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols), [2](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server))  
    - If a branch is set in the `$TERMUX_PKG_GIT_BRANCH` variable in the `build.sh` of the package, it will be checked out before building.  
    - If the source directory has been cloned already in a previous build, then it will **NOT be cloned again**, even if [`-f`]/[`-F`] flags are passed for rebuilds, and the **[`-r`] flag WILL be required** to clone the latest sources again/every time.  
    - No checksum checks will be done against the value set in `$TERMUX_PKG_SHA256` variable of the `build.sh` file. To avoid confusion, the `$TERMUX_PKG_SHA256` variable should not be set, or be set to an empty string or `SKIP_CHECKSUM`. 

&nbsp;

#### Package Build Local Source URLs

Local package source URLs are in the `*file:///path/to/source*` formats where `file://` is the [scheme](https://en.wikipedia.org/wiki/File_URI_scheme) and the `/path` is an absolute and normalized path to a directory or file on the local filesystem. **Note that 3 forward slashes `/` are necessary and `file://path` is not a valid URL.** The path must also be normalized with no duplicate or trailing path separators `/`.

The [`build-package.sh`] scripts support `3` formats for local `file://` URLs, and they all have their own build time behaviour.

- **`file:///path/to/source/dir` URL** for path to a source directory, which may or may not be a `git` repository.  
    - When the build is started for the package, a `tar` file will be created from the source directory for its current state and it will be used as is.  
    - If the source directory is a `git` directory, no changes will be made to any `git` branches/tags. Any value for the `$TERMUX_PKG_GIT_BRANCH` variable in the `build.sh` of the package will be ignored and it will have to manually checkout out. **Any uncommitted changes to current `git` branch WILL also get built.**  
    - No checksum checks will be done against the value set in `$TERMUX_PKG_SHA256` variable of the `build.sh` file, and a **`tar` file for the source directory will be created every time package is built**, assuming [`-f`]/[`-F`] flags are passed for rebuilds, and the **[`-r`] flag WILL not be required** to re-download updated sources. To avoid confusion, the `$TERMUX_PKG_SHA256` variable should be set to an empty string or `SKIP_CHECKSUM`.  

- **`file:///path/to/source/file` URL** for path to a source file, like a `tar` or `zip` file.  
    - When the build is started for the package, the source file will be downloaded if not already download and its checksum will be compared against the value set in `$TERMUX_PKG_SHA256` variable of the `build.sh` file, unless its set to `SKIP_CHECKSUM`. If checksum does not match, then build with fail with a `Wrong checksum` error.  
    - If package is being rebuilt and `$TERMUX_PKG_SHA256` is not set to `SKIP_CHECKSUM`, like with the [`-f`]/[`-F`] flags and source file already exists, then checksum will be checked again against the already downloaded file, and if it does not match, then package source will be re-downloaded and checksum re-checked. However, if checksum matches against the existing local file, then it will be used without downloading source again.  
    - If package is being rebuilt and `$TERMUX_PKG_SHA256` is set to `SKIP_CHECKSUM`, then package source will be re-downloaded every time and no checksum will be checked.
    - Any value for the `$TERMUX_PKG_GIT_BRANCH` variable in the `build.sh` of the package will be ignored.  

- **`git+file:///path/to/source/git/dir` URL** path to a [local](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) [`git`] source directory where `git+` is prefixed before `file://`, and the directory must contain a `.git` sub directory.  
    - The directory path does not need to end with `.git`.  
    - If a branch is set in the `$TERMUX_PKG_GIT_BRANCH` variable in the `build.sh` of the package, it will be checked out before building. **Any uncommitted changes to the `git` branch WILL NOT get built.**  
    - If the source directory has been cloned already in a previous build, then it will **NOT be cloned again**, even if [`-f`]/[`-F`] flags are passed for rebuilds, and the **[`-r`] flag WILL be required** to clone the latest sources again/every time.  
    - An additional requirement is that the local [`git`] repository must have its `origin` url in `.git/config` as a `https` URL instead of a `ssh` (`git@`) URL if running in [`termux-packages` docker container]  and `$TERMUX_PKG_GIT_BRANCH` is set, as it doesn't have `ssh` installed by default and `git fetch` while downloading sources would fail otherwise. So if a local `git` repository needs to be cloned from an upstream `git` URL itself, like GitHub, then use `https://github.com/org/repo.git` to clone instead of `git@github.com:org/repo.git`. Or `ssh` can be installed inside the docker container and `ssh` keys set up manually.  
    - No checksum checks will be done against the value set in `$TERMUX_PKG_SHA256` variable of the `build.sh` file. To avoid confusion, the `$TERMUX_PKG_SHA256` variable should not be set, or be set to an empty string or `SKIP_CHECKSUM`.  

---

&nbsp;





## Subpackage Build Script

Subpackage definitions are often used to move optional parts of installation to a separate packages. For example, some libraries come with utilities which may not be used by end user. Thus we can move these utilities to a separate package and reduce installation size in case when library package was installed as dependency.

Minimal subpackage script consist of the following fields:

```shell
TERMUX_SUBPKG_DESCRIPTION= # Sub-package description
TERMUX_SUBPKG_INCLUDE="" # List of files (either space or newline separated) to include in subpackage
```

Order above is preferred as include list may be long.

Subpackage script must be located in same directory as `build.sh` and have file name in the following format:

```shell
{subpackage name}.subpackage.sh
```

Note that its name cannot be same as of parent package.

Additional notes about subpackages:

- Subpackages always have version equal to parent package.
- Subpackages for static libraries are created automatically.

## &nbsp;



### Subpackage Build Script Variables

| Order | Variable | Required | Description |
| -----:|:-------- |:--------:|:----------- |
| 1     | `TERMUX_SUBPKG_DESCRIPTION` | yes | Short, one-line description of subpackage. |
| 2     | `TERMUX_SUBPKG_DEPEND_ON_PARENT` | no | Specifies way how subpackage should depend on parent. See [Subpackage dependencies](#subpackage-dependencies) for more information. |
| 3     | `TERMUX_SUBPKG_DEPENDS` | no | Comma-separated list of subpackage dependencies. |
| 4     | `TERMUX_SUBPKG_RECOMMENDS` | no | Comma-separated list of non-absolute dependencies.<br>***These are installed by default along with the (sub)package.*** |
| 5     | `TERMUX_SUBPKG_SUGGESTS` | no | Comma-separated list of packages that are related to or enhance the current one.<br>These are not installed with the (sub)package by default. |
| 6     | `TERMUX_SUBPKG_BREAKS` | no | Comma-separated list of packages that are incompatible with the current one. |
| 7     | `TERMUX_SUBPKG_CONFLICTS` | no | Comma-separated list of packages which have file name collisions with the current one. |
| 8     | `TERMUX_SUBPKG_REPLACES` | no | Comma-separated list of packages being replaced by current one. |
| 9     | `TERMUX_SUBPKG_ESSENTIAL` | no | Whether to treat subpackage as essential which cannot be uninstalled in usual way. Default is **false**. |
| 10    | `TERMUX_SUBPKG_EXCLUDED_ARCHES` | no | Comma-separated list of CPU architectures for which this subpackage cannot be compiled. |
| 11    | `TERMUX_SUBPKG_PLATFORM_INDEPENDENT` | no | Whether to treat subpackage as platform independent. Default is **false**. |
| 12    | `TERMUX_SUBPKG_INCLUDE` | yes | A space or newline separated list of files to be included in subpackage. |
| 13    | `TERMUX_SUBPKG_CONFFILES` | no | A space or newline separated list of package configuration files that should not be overwritten on update. |

## &nbsp;



### Subpackage Dependencies

By default subpackage depends only on parent package with current version. This behaviour can be changed by setting variable `$TERMUX_SUBPKG_DEPEND_ON_PARENT`.

Allowed values are:

- `deps` - subpackage will depend on dependencies of parent package.
- `unversioned` - subpackage will depend on parent package without specified version.

---

&nbsp;





## Reserved Package Build Variables

Among with variables listed above (i.e. control fields), certain variables have special purpose and used internally by [`build-package.sh`]. They should not be modified in runtime unless there is a good reason.

- `TERMUX_ON_DEVICE_BUILD` - If set, assume that building on device.

- `TERMUX_BUILD_IGNORE_LOCK` - If set to `true`, ignore build process lock.

- `TERMUX_BUILD_LOCK_FILE` - Path to build process lock file.

- `TERMUX_HOST_PLATFORM` - Host platform definition. Usually `$TERMUX_ARCH-linux-android`.

- `TERMUX_PKG_BUILDDIR` - Path to build directory of current package.

- `TERMUX_PKG_BUILDER_DIR` - Path to directory where located `build.sh` of current package.

- `TERMUX_PKG_BUILDER_SCRIPT` - Path to `build.sh` of current package.

- `TERMUX_PKG_CACHEDIR` - Path to source cache directory of current package.

- `TERMUX_PKG_MASSAGEDIR` - Path to directory where package content will be extracted from `$TERMUX__PREFIX`.

- `TERMUX_PKG_PACKAGEDIR` - Path to directory where components of `*.deb` archive of current package will be created.

- `TERMUX_PKG_SRCDIR` - Path to source directory of current package.

- `TERMUX_PKG_TMPDIR` - Path to temporary directory specific for current package.

- `TERMUX_COMMON_CACHEDIR` - Path to global cache directory where build tools are stored.

- `TERMUX_SCRIPTDIR` - Path to directory with utility scripts.

- `TERMUX_PKG_NAME` - Name of current package.

- `TERMUX_REPO_URL` - Array of package repository URLs from which dependencies will be downloaded if [`build-package.sh`] got option `-i` or `-I`.

- `TERMUX_REPO_DISTRIBUTION` - Array of distribution names in addition for `$TERMUX_REPO_URL`.

- `TERMUX_REPO_COMPONENT` - Array of repository component names in addition for `$TERMUX_REPO_URL`.

- `TERMUX_PACKAGE_FORMAT` - Package output format. Either `debian` (default) or `pacman`.

---

&nbsp;





[`-f`]: ./Building-packages#-f
[`-F`]: ./Building-packages#-f-1
[`-r`]: ./Building-packages#-r
[`build-package.sh`]: https://github.com/termux/termux-packages/blob/master/build-package.sh
[`git`]: https://git-scm.com/docs/git
[`termux-packages` docker container]: ./Build-environment#docker-container
