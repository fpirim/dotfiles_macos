# If not running interactively, don't do anything
[[ $- != *i* ]] && return

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-completions

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::helm
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

# Load math functions for fzf-tab (must be before fzf-tab loads)
# fzf-tab uses min() and max() functions in arithmetic expressions at lib/-ftb-fzf:98
autoload -Uz zmathfunc && zmathfunc

zinit cdreplay -q

# Load fzf first (must be before fzf-tab)
# Use the new fzf --zsh integration (fzf 0.48.0+)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# fzf-tab needs to be loaded after compinit and fzf, and before plugins that wrap widgets
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
[[ -z "$HISTSIZE" ]] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=4000
HISTDUP=erase
setopt histNoStore
setopt extendedHistory
setopt histIgnoreAllDups
unsetopt appendHistory
setopt incAppendHistoryTime

# Line Editors Options (Completion, Menu, Directory, etc.)
# autoMenu & autoList are on by default
setopt autoCd
setopt globDots

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' special-dirs false
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':autocomplete:history-search:*' list-lines 8  # int
zstyle ':autocomplete:*' min-input 1

# Aliases
alias ls='eza -lah --icons --git'
alias bbd='brew bundle dump --force --describe'
alias vim='nvim'
alias vi='nvim'
alias c='clear'
alias trail='<<<${(F)path}'
# Load history into shell (sharedHistory alternative)
alias lh='fc -RI; echo "History loaded into current session."'

# Handy Functions
function mkcd() {
    mkdir -p "$@" && cd "$_";
}

# Environment Variables
export NULLCMD=bat

# Editor
export EDITOR="nvim"

# Syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Shell integrations
eval "$(zoxide init --cmd=cd zsh)"

# Add custom scripts $HOME/.local/share/scripts/bin to path
export PATH="$PATH:$HOME/.local/share/scripts/bin"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
