`update-bundles`
================

**update-bundles** is a quick-and-dirty hack to update
[pathogen][pathogen_home]-managed `vim` plugins.

`update-bundles` works by descending into the subdirectories of
`$HOME/.vim/bundle`, testing to see if they are `git` or `hg` repos,
and—if they are—pulling in the latest updates.

[pathogen_home]: https://github.com/tpope/vim-pathogen

Installation
------------

It's a shell script. Just put it somewhere and `chmod` it.

Usage
-----

    $ ./update-bundles.sh

That's it; nothing fancy here. I told you was a quick-and-dirty hack.

**NOTE**: It expects you to have your bundles in the traditional
`$HOME/.vim/bundle` directory.

Roadmap
-------

* Parameterize the script:
    * Allow overriding the bundle directory
    * Add a verbose mode that provides some feedback
    * Add a really verbose mode that also passes through the output
      from the various <abbr title="Version Control System">VCS</abbr>
      commands
