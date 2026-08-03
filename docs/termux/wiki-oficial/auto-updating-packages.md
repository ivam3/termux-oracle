# Auto updating

We have an auto-update system which runs 4 times a day.

- Currently, most of the packages hosted on github, gitlab or tracked by repology can be updated automatically by just setting `TERMUX_PKG_AUTO_UPDATE=true` in build.sh.

Use [scripts/bin/check-auto-update](https://github.com/termux/termux-packages/blob/master/scripts/bin/check-auto-update) script to check and enable automatic updates.
```
❯ ./scripts/bin/check-auto-update -h

Usage: check-auto-update [-h|--help] [-s|--silent] [--enable] PACKAGE_DIR

Check if packages can be auto-updated and optionally enable if so.

NOTE: You should not trust this script if
        - package uses commit hashes for versioning (eg. 'tsu') or
        - TERMUX_PKG_VERSION is defined by us and not upstream, i.e we use some arbitrary version.
          For eg. when only getting source files based on commit hash.

Options:
-h --help Show this help message.
--enable Enable auto-update for package if check was successful. (writes TERMUX_PKG_AUTO_UPDATE=true to build.sh)
-s --silent Do not print anything to stdout.

Example: check-auto-update x11-packages/xorg-server
```
- In case script returns false, you may want to write your own update steps. See [here](#Overriding) for more details.

## Control fields

| S.No. | Variable | Required | Description |
|-------|----------|----------|-------------|
| 1    | `TERMUX_PKG_AUTO_UPDATE` | yes  | Whether to enable automatic updates for this package. Currently packages hosted on GitHub, Gitlab or tracked by repology can be auto updated. For using your own method see [here](./Auto-updating-packages). After writing build.sh you can check if package can be auto-updated using script at [scripts/bin/check-auto-update](https://github.com/termux/termux-packages/blob/master/scripts/bin/check-auto-update).|
| 2    | `TERMUX_PKG_UPDATE_VERSION_REGEXP` | no | Regex to extract version from the new computed version. <br><br> &bull; `grep -P` is set, so you can use perl regex.<br><br>**Use case**: any api may return new version as `Release_8.9.0`, but we want only `8.9.0`. So, we can extract it using `\d+\.\d+\.\d+`. |
| 3    | `TERMUX_PKG_UPDATE_METHOD` | no | Which method to use for auto-update. Can be `github`, `gitlab` or `repology`. By default it is decided on the basis of `TERMUX_PKG_SRCURL` |
| 4    | `TERMUX_PKG_UPDATE_TAG_TYPE` | no | Whether to get `latest-release-tag` or `newest-tag` (sorted by commit date) if using `github` or `gitlab` method for auto-update. By default if `TERMUX_PKG_SRCURL` ends in `.git` then `newest-tag` is fetched otherwise `latest-release-tag`. |
| 5    | `TERMUX_GITLAB_API_HOST` | no | Which host to use for gitlab api. Default `gitlab.com` |

## Auto update steps refrence

Following functions are used by update system.

Order specifies function sequence. 0 order specifies utility functions.

Suborder specifies a function triggered by the main function. Functions with
different suborders are not executed simultaneously.


| Order | Function Name | Overridable | Description | Parameters |
|------ | ------------- | ----------- | ----------- | ---------- |
| 0.1   | `termux_error_exit` | No | Function to write error message to `stderr` and exit. | Any number of string arguments. You can use heredoc for long messages. |
| 0.2   | `termux_github_api_get_tag` | No | Query GitHub API for: <br><br> &bull; `latest-release-tag`: useful for projects using github's release mechanism. <br><br> &bull; `newest-tag`(sorted by commit date): useful for projects having tags but no releases. | &bull; PKG_SRCURL - Source url of package. <br><br> &bull; TAG_TYPE - Optional. Type of tag to query. It is one of the queries mentioned in description. If not given it is decided on the basis of PKG_SRCURL. For urls ending in `.git` `newest-tag` is queried, otherwise `latest-release-tag`.|
| 0.3   | `termux_gitlab_api_get_tag` | No | *same as above, but for gitlab* | *same as above, except for optional 3rd argument:* <br> &bull; API_HOST - Host for gitlab api. Default `gitlab.com`. |
| 0.4   | `termux_repology_api_get_latest_version` | No | Query repology api for latest version. | &bull; PKG_NAME - Name of the package to query for. |
| 1     | `termux_pkg_auto_update` | Yes | By default, decide which method (gitlab, github or repology) to use for update, but can be overrided to use custom method (See [here](#Overriding)). | *None* |
| 2.1     | `termux_github_auto_update` | No | Default update method for packages hosted on github.com. It decides which type of tag to fetch based on `TERMUX_PKG_SRCURL`. | *None* |
| 2.2     | `termux_gitlab_auto_update` | No | Default update method for packages hosted on gitlab.com (or host specified by `TERMUX_GITLAB_API_HOST`). It decides which type of tag to fetch based on `TERMUX_PKG_SRCURL`. | *None* |
| 3       | `termux_pkg_upgrade_version` | No | Write the latest version and updated checksum, check whether updated package builds properly and then push changes to repo. | &bull; LATEST_VERSION - version to write to build.sh. <br><br> &bull; --skip-version-check - Optional flag. Do not check whether given LATEST_VERSION is greater than current TERMUX_PKG_VERSION. |
| 3.1     | `termux_pkg_is_update_needed` | No | Check whether LATEST_VERSION is greater than TERMUX_PKG_VERSION or not. <br> Called if `--skip-version-check` was not passed to `termux_pkg_upgrade_version`. <br><br> **NOTE:** You should not call it manually otherwise if `TERMUX_PKG_UPDATE_VERSION_REGEXP` is used, it won't compare versions extracted from it. Version is extracted by `termux_pkg_upgrade_version`. | *Not for public use.* |

## Overriding

If default steps doesn't work, you may override `termux_pkg_auto_update()` function to write your own steps.

For example see [neovim-nightly's build.sh](https://github.com/termux/termux-packages/blob/3c617f6222405cc51935bb13d557eb0b7b6fe95f/packages/neovim-nightly/build.sh#L27).

- All functions marked as utility in [function refrence](#auto-update-steps-refrence), are available within `termux_pkg_auto_update()` or functions spawned by it.
- After extracting latest version, call `termux_pkg_upgrade_version` with it to write changes to build.sh.

---
**Warning**

Bash *fail-fast* (i.e `set -euo pipefail`) is set, so consider it during error handling.

*Read more about bash fail-fast [here](https://dougrichardson.us/notes/fail-fast-bash-scripting.html).*

For example:

Following code won't work as expected:
```bash
local curl_response
curl_response=$(curl --silent "https://example.com" --write-out '|%{http_code}')

# XXXX: following code won't execute if curl fails as script will exit immediately there.

local http_code="${curl_response##*|}"
if [[ "${http_code}" != "200" ]]; then
	echo "Error: failed to get latest version."
	exit 1
fi
```
Instead use something like:
```bash
local curl_response
curl_response=$(
	curl --silent "https://example.com" --write-out '|%{http_code}'
) || {
        # This will run as expected.
	local http_code="${curl_response##*|}"
	if [[ "${http_code}" != "200" ]]; then
		echo "Error: failed to get latest version"
		exit 1
	fi
}
```
---