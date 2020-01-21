#!/bin/bash
# Git Made Simple
# A Subversion-like wrapper for Git.

set -e

function main {
    function usage {
        error "USAGE: $0 [<options>] <command> [<arg>...]"
        error 'Git-Made-Simple - A Subversion like wrapper for Git'
        error
        error 'Options:'
        error '   --explain        show git commands run'
        error '   -h, --help       show help'
        error
        error 'Available commands:'
        error '   checkout      Checkout a working copy'
        error '   update        Bring changes from the repository into the working copy'
        error '   add           Put files under version control'
        error '   delete        Remove files from version control'
        error '   copy          Copy files'
        error '   move          Move (rename) a file or directory'
        error '   log           Show log messages for path'
        error '   status        Print status of working copy files'
        error '   diff          Display local changes'
        error '   revert        Restore pristine working copy state (undo local changes)'
        error '   commit        Send changes from your working copy to the repository'
        error '   switch        Switch to a new remote branch'
    }

    while [[ -n "$1" ]]; do
        case "$1" in
            --explain)
                explain=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ -z "$1" ]]; then
        usage
        exit 2
    fi

    local command="gms-$1"
    if ! type -t "${command}" &> /dev/null; then
        error "gms: '${1}' is not a git-made-simple command. See 'gms --help'"
        exit 2
    fi
    shift

    "${command}" "$@"
}

function error {
    echo "$*" >&2
}

function gms-checkout {
    function usage {
        error "USAGE: $0 checkout [<options>] <repo> [<dir>]"
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    case $# in
        1)
            run git clone "${options[@]}" -- "$1"
            ;;
        2)
            run git clone "${options[@]}" -- "$1" "$2"
            ;;
        *)
            usage
            exit 2
            ;;
    esac
}

function gms-update {
    function usage {
        error "USAGE: $0 update [<options>]"
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -gt 0 ]]; then
        usage
        exit 2
    fi

    run git pull --rebase "${options[@]}"
}

function gms-add {
    function usage {
        error "USAGE: $0 add [<options>] <path>..."
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 1 ]]; then
        usage
        exit 2
    fi

    run git add --intent-to-add "${options[@]}" -- "$@"
}

function gms-delete {
    function usage {
        error "USAGE: $0 delete [<options>] <file>..."
        error
        error '--force          force removal'
        error '--keep-local     keep file in working tree'
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            --force)
                options+=(--force)
                ;;
            --keep-local)
                options+=(--cached)
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 1 ]]; then
        usage
        exit 2
    fi

    run git rm "${options[@]}" -- "$@"
}

function gms-remove {
    gms-delete "$@"
}

function gms-rm {
    gms-delete "$@"
}

function gms-copy {
    function usage {
        error "USAGE: $0 copy [<options>] <src>... <dest>"
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 2 ]]; then
        usage
        exit 2
    fi

    run cp -- "$@"
    run git add "${options[@]}" -- "${@: -1}"
}

function gms-cp {
    gms-copy "$@"
}

function gms-move {
    function usage {
        error "USAGE: $0 move [<options>] <src>... <dest>"
        error
        error '--force          force move/rename even if target exists'
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            --force)
                options+=(--force)
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 2 ]]; then
        usage
        exit 2
    fi

    run git mv "${options[@]}" -- "$@"
}

function gms-mv {
    gms-move "$@"
}

function gms-rename {
    gms-move "$@"
}

function gms-log {
    function usage {
        error "USAGE: $0 log [<options>] [<path>...]"
        error
        error "--local          don't fetch remote repository status"
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            --local)
                local local=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ -z "${local}" ]]; then
        # Fetch remote repository status
        run git fetch origin
    fi

    run git log "${options[@]}" -- "$@"
}

function gms-status {
    function usage {
        error "USAGE: $0 status [<options>] <path>..."
        error
        error "--local          don't fetch remote repository status"
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            --local)
                local local=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ -z "${local}" ]]; then
        # Fetch remote repository status
        run git fetch origin
    fi

    run git status "${options[@]}" -- "$@"
}

function gms-diff {
    function usage {
        error "USAGE: $0 diff [<options>] <path>..."
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    run git diff "${options[@]}" HEAD -- "$@"
}

function gms-revert {
    function usage {
        error "USAGE: $0 revert [<options>] <path>..."
        error
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 1 ]]; then
        usage
        exit 2
    fi

    run git reset "${options[@]}" HEAD -- "$@"
    for f in "$@"; do
        # Only checkout files if they're still in the index,
        # otherwise we may delete local changes
        if git ls-files --error-unmatch -- "${f}" &> /dev/null; then
            run git checkout HEAD -- "${f}"
        fi
    done
}

function gms-commit {
    function usage {
        error "USAGE: $0 commit [<options>] [<path>...]"
        error
        error '-m, --message    commit message'
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -m|--message)
                options+=(--message "${2:?}")
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 1 ]]; then
        run git commit --all "${options[@]}"
    else
        run git commit "${options[@]}" -- "$@"
    fi

    # Push upstream (or rollback commit)
    run git push origin HEAD || run git reset -N HEAD^
}

function gms-switch {
    function usage {
        error "USAGE: $0 switch [<options>] <branch>"
        error
        error '-m, --message    commit message'
        error '-h, --help       show help'
    }

    local options=()
    while [[ -n "$1" ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if [[ $# -lt 1 ]]; then
        usage
        exit 2
    fi

    run git fetch origin
    run git checkout -B "$1" --track "origin/$1"
}

function run {
    test -v explain && error "$*"
    "$@"
}

main "$@"
