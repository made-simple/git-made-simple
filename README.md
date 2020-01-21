# Git Made Simple

A Subversion-like wrapper for [Git](http://git-scm.com/).

## Important Note

This is currently alpha-quality code and has not had extensive testing.

There may be nasty bugs that could cause local changes to be lost.

## Requirements

- [Git](https://git-scm.com/)
- [Bash shell](https://www.gnu.org/software/bash/)

On Windows, **Git Bash** is installed by default as part of
[Git for Windows](https://gitforwindows.org/) package.

## Usage

```
USAGE: gms [<options>] <command> [<arg>...]
Git-Made-Simple - A Subversion like wrapper for Git

Options:
   --explain        show git commands run
   -h, --help       show help

Available commands:
   checkout      Checkout a working copy
   update        Bring changes from the repository into the working copy
   add           Put files under version control
   delete        Remove files from version control
   copy          Copy files
   move          Move (rename) a file or directory
   log           Show log messages for path
   status        Print status of working copy files
   diff          Display local changes
   revert        Restore pristine working copy state (undo local changes)
   commit        Send changes from your working copy to the repository
   switch        Switch to a new remote branch
```

## License

Licensed under the [MIT License](/LICENSE).
