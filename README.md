# Directory Cleaner
*Clean your directories in a simple manner*

**author**: Wiktor Zawadzki\
**github**: https://github.com/wiktoz/dir-cleaner

## Features
- Clean temporary files
- Clean empty files
- Remove duplicate files by their content
- Detect and fix unusual and dangerous permissions
- Rename files containing dangerous characters in their filenames
- Works in a recursive way, checking all nested directories

## Usage
`./dir_cleaner.sh [-r] [-tedpnfm] [-h] [dir1 dir2 ...]`

### Flags
`-h` **help** - prints help

`-r` **recursive** - performs check on specified directories and all nested

`-t` **remove temp files** - automatically removes all temp files

`-e` **remove empty files** - automatically removes all empty files

`-d` **remove duplicates** - automatically removes all duplicate files

`-p` **change permissions** - replace all dangerous or unusual permissions with their safe replacement

`-n` **change names** - replace dangerous characters in filenames with a safe substitute

`-f` **force** - do not ask user for permission to perform actions

`-m` **move** - move all files to top parent directory, remove empty subdirectories

### Config
File `.clean_files` is a configuration file where user can specify:
- **temp_extensions** - file extensions that indicate file is temporary\
*default* `("*.tmp" "*~")`

- **unusual_permissions** - permissions that are considered unusual or dangerous\
*default* `("rwxrwxrwx" "---rwxrwx" "---r--r--" "---rw-rw-" "r--rwxrwx" "rw-rwxrwx" "--x--x--x")`

- **dangerous_chars** - characters that are dangerous and should be replaced\
*default* `':\;*?$#|\\/'"'"`

- **default_substitute** - character to replace dangerous characters with\
*default* `"_"`

- **default_permissions** - safe permissions to replace dangerous permissions with\
*default* `"rw-r--r--"`
