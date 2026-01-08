# Loren's Zsh Configuration
# Generated with baseline settings

# ============================================================================
# Oh-My-Zsh Installation Path
# ============================================================================
# If you haven't installed Oh-My-Zsh yet, run:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
export ZSH="$HOME/.oh-my-zsh"

# ============================================================================
# Theme Configuration
# ============================================================================
# Powerlevel10k theme
# Install with: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Plugins
# ============================================================================
# Note: git and vi-mode come with Oh-My-Zsh
# Install zsh-autosuggestions:
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Install zsh-syntax-highlighting:
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(
  git
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# UV Tools PATH
# ============================================================================
# Add UV tool binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# Vi Mode Configuration
# ============================================================================
# Enable vi mode (already loaded via plugin)
bindkey -v

# Reduce ESC delay to 0.1 seconds (default is 0.4s)
export KEYTIMEOUT=1

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE=~/.zsh_history          # Where to save history
HISTSIZE=10000                   # Number of commands to keep in memory
SAVEHIST=10000                   # Number of commands to save to file
setopt SHARE_HISTORY             # Share history across all sessions in real-time
setopt HIST_IGNORE_DUPS          # Don't save duplicate commands consecutively
setopt HIST_IGNORE_SPACE         # Don't save commands that start with space
setopt HIST_VERIFY               # Show command with history expansion before running
setopt APPEND_HISTORY            # Append to history file rather than replace
setopt INC_APPEND_HISTORY        # Write to history file immediately, not on exit

# ============================================================================
# LS Colors Configuration
# ============================================================================
# Change directory color from teal (36) to blue (34)
# Format: di=color_code where di=directory
export LS_COLORS='di=01;34'      # Bold blue for directories

# ============================================================================
# Completion Configuration
# ============================================================================
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Enable menu selection for completions
zstyle ':completion:*' menu select

# Use LS_COLORS for tab completion colors (matches ls output)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Partial completion - complete from middle of words
setopt COMPLETE_IN_WORD

# Enable spell correction for commands
setopt CORRECT

# Initialize completion system
autoload -Uz compinit
compinit

# ============================================================================
# Directory Navigation Aliases
# ============================================================================
# Quick directory listings with colors enabled
alias ls='ls --color=auto'       # Enable colors for ls
alias ll='ls -lah'               # List all files in long format with human-readable sizes
alias la='ls -A'                 # List all files except . and ..
alias l='ls -CF'                 # List files in columns with indicators

# Quick navigation up directories
alias ..='cd ..'                 # Go up one directory
alias ...='cd ../..'             # Go up two directories
alias ....='cd ../../..'         # Go up three directories

# ============================================================================
# Development Tool Aliases
# ============================================================================
alias v='vim'                    # Quick vim shortcut
alias python='python3'           # Use python3 by default
alias pip='pip3'                 # Use pip3 by default

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================
# To customize prompt, run: `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Development Environment Setup
# ============================================================================
# Load homebrew (if installed)
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Prefer GNU binaries to macOS binaries
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi

# Load pyenv (if installed)
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

# Load rbenv (if installed)
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
fi

# Load direnv (if installed)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Standard Go configuration
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
