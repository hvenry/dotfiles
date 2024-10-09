# Dotfiles

This is a dotfiles repo containing my configurations for certain programs, these configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.

## Setup

In order to setup these dotfiles on another machine, [Homebrew](https://brew.sh/) will need to be installed, as it is my package manager of choice, as well as [Git](https://formulae.brew.sh/formula/git).

Next, install GNU Stow:

```bash
brew install stow
```

After this, clone this repo in to the `$HOME` directory using git.

```bash
git clone git@github.com:hvenry/dotfiles.git
```

Now, `cd` in to the dotfiles repo that was just cloned, and then use **GNU stow** to create the symlinks.

```bash
stow .
```

This should now create symlinks from `~/` to the `~/dotfiles/` folder, allowing for consistent managment of dotfiles.
