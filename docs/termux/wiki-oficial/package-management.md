# Package Management

Check [Package Management Wiki Page](https://wiki.termux.com/wiki/Package_Management) for more details on managing In-App Termux packages.

### Package Command Errors

If you installed termux from google playstore or a very old version, then you will receive package command errors. **Playstore builds are deprecated and no longer supported.** It is highly recommended that you update to `termux-app` `v0.118.0` or higher ASAP for various bug fixes, including a critical world-readable vulnerability reported at https://termux.github.io/general/2022/02/15/termux-apps-vulnerability-disclosures.html. It is recommended that you shift to [F-Droid or Github releases](https://github.com/termux/termux-app#installation).

Termux had to move the primary Termux package repository hosting from [**Bintray to Fosshost**](https://github.com/termux/termux-packages/issues/6348) since [**Bintray shut down on May 1st, 2021**](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/) which created problems for users while running package installation and update commands with `pkg` or `apt` and their commands would fail with errors similar to the following:

```
E: The repository 'https://termux.org/packages stable Release' does no longer have a Release file.
N: Metadata integrity can't be verified, repository is disabled now.
N: Possible cause: repository is under maintenance or down (wrong sources.list URL?).
```

```
E: The repository 'https://dl.bintray.com/grimler/game-packages-24 games Release' does not have a Release file.
N: Metadata integrity can't be verified, repository is disabled now.
N: Possible cause: repository is under maintenance or down (wrong sources.list URL?).
```

```
E: The repository 'https://science.termux-mirror.ml science Release' does not have a Release file.
N: Metadata integrity can't be verified, repository is disabled now.
N: Possible cause: repository is under maintenance or down (wrong sources.list URL?).
```

If that is the case, then run `termux-change-repo` command and **change your mirror** for the `main` repository to a different [Termux Mirror](https://github.com/termux/termux-packages/wiki/Mirrors). If you have installed [`other package repositories`](https://github.com/termux/termux-packages/wiki#packages), like `x11` and `root`, then you **must** select and change those mirrors as well. You can check your current mirrors by running the `termux-info` command. Note that the `science` and `game` repos have been merged into `main` repo and should be removed with `apt remove science-repo game-repo` if you have them installed.

For **step by step instructions** on how to change mirrors, check [here](https://github.com/termux/termux-packages/issues/6726).

If you receive errors like `...Release' changed its 'Origin' value from 'Bintray' to...` after changing the mirror, then [accept them](https://github.com/termux/termux-packages/issues/6455).

After changing the mirror, it is **highly advisable** to run `pkg upgrade` command to update all packages to the latest available versions, or at least update `termux-tools` package with `pkg install termux-tools` command. Also make sure your device has internet connectivity and the repository URLs are accessible in a browser.

If for some reason `termux-change-repo` is not available, you can manually edit `sources.list` to replace the `main` url with a value obtained from [Termux Mirrors List](https://github.com/termux/termux-packages/wiki/Mirrors). Run `nano $PREFIX/etc/apt/sources.list` to edit it. This will not change the urls of `other package repositories`, to change those run `pkg install termux-tools` afterwards and use `termux-change-repo` or manually edit their files under `$PREFIX/etc/apt/sources.list.d` directory.

Changing the mirror may specially be needed if a user is still using `bintray` as the mirror or `pkg upgrade` command hasn't been run in a while to update termux package related scripts.