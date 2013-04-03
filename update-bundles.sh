#!/bin/sh
# **update-bundles** is a quick-and-dirty hack to update
# [pathogen][pathogen_home]-managed `vim` plugins.
#
# `update-bundles` works by descending into the subdirectories of
# `$HOME/.vim/bundle`, testing to see if they are `git` or `hg` repos,
# and—if they are—pulling in the latest updates.
#
# [pathogen_home]: https://github.com/tpope/vim-pathogen

# The most important line in any shell script: error out if any of the
# commands we invoke return a non-zero exit code.
set -e

# Also, exit on uninitialized variables.
set -o nounset

# This is the same trick used by [`shocco`][shocco_home] to embed a
# usage message into a shell script.
#
# [shocco_home]: http://rtomayko.github.io/shocco/
#
# First: embed the usage message as a comment, and tag it with a
# special, non-space character after the `#` (I followed `shocco`'s
# convention of using a `/`.
#
#/ Usage: update-bundles.sh
#
# Second: use `grep` trickery to pull out the usage message (assuming
# they asked for it).
expr -- "$*" : ".*--help" > /dev/null && {
    grep '^#/' < "$0" | cut -c4-
    exit 0
}

# Up next, we have a pair of functions to encapsulate the logic for
# updating the plugins; one function for `git`-managed plugins, and one
# function for `hg`-managed plugins. If you're not using one of those, you
# can handle updating them yourself.

# This one is for `git`-managed repos, and is slightly more complicated
# than the function for `hg`-managed repos. How apropros.
update_git_repo() {
    # Get the latest and greatest changes.
    git fetch > /dev/null 2>&1

    # Look before you leap: We fetched the changes, but rather than
    # blindly trying to merge them in (which, obviously, doesn't make
    # sense if we are in a detached `HEAD` state, such as being on a
    # release tag), we check to make sure we're on a branch before
    # attempting to merge them in.
    #
    # *NOTE*: Once again, we need to capture non-zero exit codes and
    # test against them, so we are temporarily going to allow them.
    set +e
    git symbolic-ref HEAD 2>/dev/null
    is_on_branch="$?"
    set -e
    if test 0 -eq "$is_on_branch" ; then
        git pull > /dev/null 2>&1
    fi
}

# This function handles `hg`-managed repos, and relies on having the
# `fetch` extension installed/enabled. Since that has been distributed
# w/ Mercurial for ages, it shouldn't be a big deal. If it is really a
# deal-breaker for you, you can change the command to use the rebase
# extension or something.
update_hg_repo() {
    hg fetch > /dev/null 2>&1
}

# Loop across all the files in the bundle directory.
for file in "$HOME/.vim/bundle/*" ; do
    # Skip anything that isn't a directory; this is unlikely. Pathogen
    # likely frowns on non-directory children the bundle directory, anyway.
    if test ! -d "$file" ; then
        continue
    fi

    # Descend into the directory.
    cd "$file"

    # Test if it's a `git` or `hg` repo. The way we do it will give us a
    # non-zero exit code when it's not a repo, so we have to disable
    # `-e` for a bit.
    set +e
    git rev-parse > /dev/null 2>&1
    am_i_git="$?"
    hg root > /dev/null 2>&1
    am_i_hg="$?"

    # OK, done with the exit status-based testing. Re-enable `-e`.
    set -e

    # Now delegate to the appropriate function for the
    # <abbr title="Version Control System">VCS</abbr> at hand. If it's
    # not managed by a supported
    # <abbr title="Version Control System">VCS</abbr>, just ignore it.
    if test 0 -eq "$am_i_git" ; then
        update_git_repo
    elif test 0 -eq "$am_i_hg" ; then
        update_hg_repo
    fi
done
