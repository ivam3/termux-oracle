## Markdown formatting

- Files must be encoded in UTF-8 and do not have executable permission.

- Page headers should be indented with hashes (`#`) rather than equal signs (`=`).

- Bullet lists should be indented with hyphens (`-`).

- Characters that are special for Markdown must be escaped. Example: `\*`.

- Use `inline code formatting` for file names unless they are links.

- All code blocks should be enclosed in backticks, with language specified.

- Use spaces for indentation to keep documents readable in plain text format.

## Script formatting

- File must be encoded in UTF-8.

- Package scripts `build.sh` and `*.subpackage.sh` should not have executable
  permission.

- Use tabs for indentation in Shell scripts.

- Use spaces for indentation in Python scripts.

- Parenthesis of functions should not be preceded with a space.

- Avoid trailing spaces and tabs.

- Lines shouldn't be longer than 80 characters.

- Comments should be reasonable, compact and attached to a place they refer to.
  Do not indent them if not necessary.

- Banner comments in `build.sh` or `*.subpackage.sh` are not allowed.

## Shell script coding practices

### General

- Dollar parentheses `$()` rather than backticks ``` `` ``` should be employed
  in command substitution.

### Build script (`build.sh`)

- Usage of `sudo` or `su` in build scripts is disallowed.

- Global scope variables must be defined in `termux_step_pre_configure()`
  function unless they are part of package metadata.

- Local (step-specific) variables must be defined with keyword `local`. If
  variable does not have such keyword, it automatically becomes visible outside
  of function where it was defined.

- Do not export variables if not necessary.

- Utility `install` is preferred over `cp` as the file installation program.

- Do not hardcode version numbers. Instead, use the `$TERMUX_PKG_VERSION` and
  `$TERMUX_PKG_REVISION` variables.

- Do not hardcode Termux prefix directory. Instead, use the `$TERMUX_PREFIX`
  variable.

- Do not hardcode Termux home directory. Instead, use the `$TERMUX_ANDROID_HOME`
  variable.

## Patches

- Files must be in format usable by GNU `patch` utility and do not have executable
  permission.

- Do not hardcode Termux prefix directory. Use `@TERMUX_PREFIX@` instead.

- Do not hardcode Termux home directory. Use `@TERMUX_HOME@` instead.

- Highly recommended to document changes unless they are just FHS path
  replacements.

See also: https://github.com/termux/termux-packages/blob/master/CONTRIBUTING.md#creating-patch-files
