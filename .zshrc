# Make neovim default vim
alias vim='nvim'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set Oh-My-Zsh plugins
plugins=(git)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Source GHCup environment (Haskell)
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# Add Anaconda to the PATH
export PATH="/opt/homebrew/anaconda3/bin:$PATH"

# Source the conda initialization script
if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
fi

# Source zsh-autosuggestions.zsh (installed via Homebrew)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Source zsh-syntax-highlighting.zsh (installed via Homebrew)
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Source zsh-autocomplete.plugin.zsh (installed via Homebrew)
if [ -f /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
    source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

# Source Powerlevel10k theme (installed via Homebrew)
if [ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]; then
    source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
