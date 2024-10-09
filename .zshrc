# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew environment setup (make homebrew installed apps available in path)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Zinit installation path
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# add powerlevel10k with Zinit and plugins
# ice: adds arguments next zinit command to use, adding something to something else...
# - like ice to a drink. okay.
zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets from Oh My Zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx

# Initialize zsh completion system
autoload -U compinit && compinit
zinit cdreplay -q

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings for history search
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History config for terminal multiplexer
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Useful aliases 
alias vim='nvim'
alias ls='ls --color'
alias c='clear'

# Shell integrations for fzf
eval "$(fzf --zsh)"

# Source GHCup environment for Haskell
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# Source the conda initialization script if exists
[ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ] && . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
