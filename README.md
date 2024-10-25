# Dotfiles

This is a dotfiles repo containing my configurations for certain programs, these configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.

## General Setup

In order to setup these dotfiles on another machine, [Homebrew](https://brew.sh/) will need to be installed, as it is my package manager of choice, as well as [Git](https://formulae.brew.sh/formula/git).

Next, install GNU Stow:

```bash
brew install stow
```

This configuration uses tmux, tpm, fzf, so install with:

```bash
brew install tmux
brew install tpm
brew install fzf
```

Install Tmux styling dependencies [here](https://github.com/janoamaral/tokyo-night-tmux):

After this, clone this repo in to the `$HOME` directory using git.

```bash
git clone git@github.com:hvenry/dotfiles.git
```

Now, `cd` in to the dotfiles repo that was just cloned, and then use **GNU stow** to create the symlinks:

**NOTE**: Be sure to remove any configurations that are under `~/` have been cloned from this repo. For instance, to create symlinks for `~/dotfiles/.config/nvim`, be sure to `rm -rf ~/.config/nvim` before doing so.

```bash
stow .
```

This should now create symlinks from `~/` to the `~/dotfiles/` folder, allowing for consistent management of dotfiles.

Finally, source necessary configuration files, for example:

```
source ~/.zshrc
tmux source ~/.config/tmux/tmux.conf
```

## Iterm2 Setup

In order to use my config for [iterm2](https://iterm2.com/), simply install iterm2, open it and go to `general/settings`, select `Load settings from a custom folder or URL` and set it to `~/dotfiles/iterm2`.
