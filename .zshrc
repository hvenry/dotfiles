# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew environment setup
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Source GHCup environment for Haskell
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# set defaul editor
export EDITOR=nvim

# Zinit installation path
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Downlaod Zinit if it is not installed
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source Zinit
source "$ZINIT_HOME/zinit.zsh"

# Add powerlevel10k with Zinit and plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add Zsh Plugins
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
zinit snippet OMZP::command-not-found

# Initialize zsh completion system
autoload -U compinit && compinit

zinit cdreplay -q

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings for history search
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[w' kill-region

# No highlighting on paste
zle_highlight+=(paste:none)


# History config for terminal multiplexer
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Useful aliases 
alias vim='nvim'
alias ls='ls --color'
alias c='clear'

# Shell integrations for fzf
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

