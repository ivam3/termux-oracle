# Build Environment

Welcome to the docs for the `termux-packages` build environment.

### Contents

- [Directory Structure](#directory-structure)
- [Setup](#setup)

---

&nbsp;





## Directory Structure

Following is a list of files and directories inside the `termux-packages` repo root directory, which are used by the build environment.

- `./build-package.sh` - script for building one or more packages.

- `./build-all.sh` - script for building all available packages.

- `./clean.sh` - script for cleaning build environment.

- `./disabled-packages` - directory with packages excluded from main build tree due to various reasons.

- `./ndk-patches` - directory with patches for Android NDK sysroot.

- `./output` - directory where built packages will be placed. Does not exist by default.

- `./packages` - directory where all `main` channel packages (scripts and patches) are located.

- `./root-packages` - directory where all `root` channel packages (scripts and patches) are located.

- `./sample` - sample structure for creating new package.

- `./scripts` - internal parts of build system and some utility scripts.

- `./x11-packages` - directory where all `x11` channel packages (scripts and patches) are located.

---

&nbsp;





## Setup

The `termux-packages` build environment can be setup through the following way. Once the build environment has been setup, the packages can be built, **check [`Building-Packages`](#Building-packages) docs for info on how to build packages.**

- [Docker Container](#docker-container) (**recommended**)
- [VirtualBox VM](#virtualbox-vm)
- [Host OS](#host-os)
- [Termux App](#termux-app)

### Docker Container

**Using official Docker image is the recommended way for building Termux packages** which ensures that the build environment is the same as Termux maintainers and therefore builds are reproducible.

If `docker` has been [installed](https://docs.docker.com/engine/install/) and running, then launching a build environment should be as simple as running following, which will automatically create a docker container if it does not exist with the name `termux-package-builder`  by default for the `ghcr.io/termux/package-builder` image ([1](https://github.com/termux/termux-packages/pkgs/container/package-builder), [2](https://hub.docker.com/r/termux/package-builder)). **See also [Multiple Containers](#multiple-containers) section.**

```shell
./scripts/run-docker.sh
```

Wait until latest image is downloaded and then container's shell prompt should appear. The `termux-packages` repo root directory will be mounted at `/home/builder/termux-packages`.

Commands can be executed inside the container without launching interactive shell by supplying them as arguments to `./scripts/run-docker.sh`. Example:

```shell
./scripts/run-docker.sh ./build-package.sh bash
```

Sometimes Docker image should be updated if there have been significant changes made in the latest image provided by us required for building packages. If latest `termux-packages` `git` repo changes have been pulled, and docker image for which the current container was created for is outdated, then it may result in errors like `NDK not pointing at a directory` since expected newer `NDK` version path specified in [`properties.sh`](https://github.com/termux/termux-packages/blob/master/scripts/properties.sh) will not be found in old image container.

Following command will download the latest docker image, delete outdated container and then create a new container for the latest image. Note that deleting a container will delete all built files inside the container and any packages previously built in old container will need to be built again in the new container. The `deb`/`tar` files in `output` directory are not deleted though.

```shell
./scripts/update-docker.sh
```

&nbsp;

#### Building own Docker image

`Dockerfile` is [located](https://github.com/termux/termux-packages/blob/master/scripts/Dockerfile) in `./scripts/` directory and configured to build Ubuntu-based image.

To build the Docker image, execute following commands:

```shell
cd ./scripts
docker build -t termux/package-builder .
```

If getting error like `-bash: /tmp/setup-ubuntu.sh: Permission denied`, make sure that all `*.sh` files have permission `755` and `umask` is `0022`.

&nbsp;

#### Docker on Windows

For Windows users there is a PowerShell script available:

```shell
.\scripts\run-docker.ps1
```

&nbsp;

#### Docker Container Config

##### Multiple Containers

The `termux-packages` `git` repo directory from which a container is created when `run-docker.sh` is first run is mounted at `/home/builder/termux-packages` inside the docker container as a docker [`volume`](https://docs.docker.com/reference/cli/docker/container/run/#volume). The original volume source mount path (`termux-packages` `git` repo directory) does not change for the life of the container. So if running `run-docker.sh` from a different `termux-packages` `git` repo directory (`cwd`), like of a fork, the original volume source mount path will be what is used for building instead of the current repo root/`cwd` and any changes in the later would not get used.

So **each `termux-packages` `git` repo directory must have its own docker container to build packages**. Multiple containers may also be needed if the docker image required for the current branch is newer or older than the branch with which container was created. The default or the first docker container is created with the name `termux-package-builder`. To create a new container for the current repo that can be used build its packages, export the `$CONTAINER_NAME` environment variable with a different name and run `run-docker.sh` again.

   ```shell
   CONTAINER_NAME=termux-package-builder-fork ./scripts/run-docker.sh
   ```

   List all docker containers created by running. The `IMAGE` column will show the image id for which the container was created for. The command will list non-Termux containers too.

   ```shell
   docker container ls --all --size
   ```

   List all docker image for Termux packages docker image by running.

   ```shell
   docker image ls --all --filter "reference=ghcr.io/termux/package-builder"
   ```

##### Custom Docker Image

   To use a custom Docker image instead of the default `ghcr.io/termux/package-builder` image by exporting the `$TERMUX_BUILDER_IMAGE_NAME` environment variable. Ideally a custom container name for the container should also be specified as mentioned in the [Multiple Containers](multiple-containers) section.  

   ```shell
   export TERMUX_BUILDER_IMAGE_NAME=username/termux-custom-builder
   export CONTAINER_NAME=termux-package-builder-custom
   ./scripts/run-docker.sh
   ```

## &nbsp;



### VirtualBox VM

There is a [Vagrantfile](https://github.com/termux/termux-packages/blob/master/scripts/Vagrantfile) for setting up a VirtualBox Ubuntu installation.

- Run `vagrant plugin install vagrant-disksize` to install disksize plugin for Vagrant.
- Run `cd scripts && vagrant up` to setup and launch the virtual machine.
- Run `vagrant ssh` to ssh into the virtual machine.

## &nbsp;



### Host OS

We have scripts that automate installation of packages used in build process.

For now only Ubuntu and Arch Linux distributions are supported. Note that all scripts execute commands under `sudo`.

For Ubuntu:

```shell
./scripts/setup-ubuntu.sh
```

For Arch Linux:

```shell
./scripts/setup-archlinux.sh
```

Additionally, Android SDK and NDK will need to be installed. By default, it is expected that both SDK and NDK are installed into `$HOME/lib`, so it is recommended to use following script to properly setup them:

```shell
./scripts/setup-android-sdk.sh
```

## &nbsp;



### Termux App

Our build system can be used to build packages on device inside the Termux app itself, but not all packages can be built on the device due to various reasons (like certain host build tools not being available) and such packages have `$TERMUX_PKG_ON_DEVICE_BUILD_NOT_SUPPORTED` set in their `build.sh` file.

**Warning:** devices on which [`termux-exec`](https://github.com/termux/termux-exec) is not working are not supported!

To set up the Termux app to be able to build packages, execute the following command inside the root directory of cloned `termux-package` repository.

```shell
./scripts/setup-termux.sh
```

Note that files generated in build process are installed to `$TERMUX__PREFIX` and are not tracked by the package manager. It is also highly recommended to [backup](https://wiki.termux.com/wiki/Backing_up_Termux) both `$HOME` and `$TERMUX__PREFIX` before building any package.

---
