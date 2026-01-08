#!/usr/bin/env bash
# Dotfiles installation script
# Run this script to install all dependencies for vim, zsh, and tmux configs

set -e  # Exit on error

echo "=================================="
echo "Dotfiles Installation Script"
echo "=================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Get the directory where this script lives (the dotfiles directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Using dotfiles directory: $DOTFILES_DIR"
echo

# Detect operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    info "Detected: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    info "Detected: macOS"
else
    OS="unknown"
    warn "Unknown OS: $OSTYPE"
fi
echo

# ============================================================================
# Install Package Manager and Core Dependencies
# ============================================================================
if [ "$OS" = "linux" ]; then
    # Linux (Ubuntu/Debian) - use apt
    info "Installing core dependencies via apt..."

    sudo apt-get update -qq

    # Install base packages
    sudo apt-get install -y \
        tmux \
        git \
        curl \
        wget \
        build-essential \
        zsh \
        fzf \
        ripgrep \
        gh \
        software-properties-common

    # Install vim from PPA (CoC requires Vim 9.0.0438+, Ubuntu's default is too old)
    info "Installing vim 9+ from PPA..."
    sudo add-apt-repository -y ppa:jonathonf/vim
    sudo apt-get update -qq
    sudo apt-get install -y vim

    VIM_VERSION=$(vim --version | head -n1)
    info "Installed: $VIM_VERSION"

    # Install Node.js via NodeSource (includes npm)
    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        info "Installing Node.js and npm..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # Install language servers for CoC.nvim
    if command -v npm &> /dev/null; then
        info "Installing language servers..."
        sudo npm install -g bash-language-server
    else
        error "npm not found after Node.js installation. This should not happen."
        warn "Skipping language server installation. Install manually with: sudo npm install -g bash-language-server"
    fi

    # Install gopls for Go support
    if ! command -v gopls &> /dev/null; then
        info "Installing gopls (Go language server)..."
        go install golang.org/x/tools/gopls@latest 2>/dev/null || {
            warn "Could not install gopls (requires Go). Install manually if needed: go install golang.org/x/tools/gopls@latest"
        }
    fi

    # Install uv via installer
    if ! command -v uv &> /dev/null; then
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add uv to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
    fi

    success "Dependencies installed via apt"

elif [ "$OS" = "macos" ]; then
    # macOS - use Homebrew
    if ! command -v brew &> /dev/null; then
        warn "Homebrew not found. Attempting to install..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    info "Homebrew found: $(brew --version | head -n1)"

    # Update Homebrew
    info "Updating Homebrew..."
    brew update

    # Install core dependencies
    info "Installing core dependencies via Homebrew..."
    brew install vim tmux node fzf ripgrep gh uv

    # Install language servers for CoC.nvim
    info "Installing language servers..."
    npm install -g bash-language-server

    # Install gopls for Go support
    if ! command -v gopls &> /dev/null; then
        info "Installing gopls (Go language server)..."
        go install golang.org/x/tools/gopls@latest 2>/dev/null || {
            warn "Could not install gopls (requires Go). Install manually if needed: go install golang.org/x/tools/gopls@latest"
        }
    fi

    success "Dependencies installed via Homebrew"
else
    error "Unsupported operating system. Please install dependencies manually."
    exit 1
fi

echo

# ============================================================================
# Temporarily disable git URL rewrites for installation
# ============================================================================
# Some environments (like Datadog workspaces) rewrite HTTPS to SSH URLs
# This causes issues when SSH keys aren't set up
info "Configuring git to use HTTPS..."
SAVED_GIT_URL=$(git config --global --get url."git@github.com:".insteadOf 2>/dev/null || echo "")
git config --global --unset-all url."git@github.com:".insteadOf 2>/dev/null || true

# Install Oh-My-Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh-My-Zsh already installed, skipping..."
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    info "Powerlevel10k already installed, skipping..."
fi

# Install zsh plugins
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    info "zsh-autosuggestions already installed, skipping..."
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    info "zsh-syntax-highlighting already installed, skipping..."
fi

# ============================================================================
# Restore git URL rewrites if they existed
# ============================================================================
if [ -n "$SAVED_GIT_URL" ]; then
    info "Restoring git URL configuration..."
    git config --global url."git@github.com:".insteadOf "$SAVED_GIT_URL"
fi

# Install vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    info "Installing vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    info "vim-plug already installed, skipping..."
fi

# Create vim directories
info "Creating vim directories..."
mkdir -p ~/.vim/undo

# Symlink dotfiles to $HOME (except .zshrc which needs special handling)
info "Symlinking dotfiles to home directory..."
DOTFILES=(
    .vimrc
    .tmux.conf
    .p10k.zsh
)

for dotfile in "${DOTFILES[@]}"; do
    if [ -f "$DOTFILES_DIR/$dotfile" ]; then
        # Backup existing file if it exists and is not a symlink
        if [ -f "$HOME/$dotfile" ] && [ ! -L "$HOME/$dotfile" ]; then
            warn "Backing up existing $dotfile to ${dotfile}.backup"
            mv "$HOME/$dotfile" "$HOME/${dotfile}.backup"
        fi

        info "Symlinking $dotfile"
        ln -sf "$DOTFILES_DIR/$dotfile" "$HOME/$dotfile"
    else
        warn "Skipping $dotfile (not found in dotfiles directory)"
    fi
done

# Special handling for .zshrc: create a real file that sources the repo version
# This allows workspace setup scripts to append to ~/.zshrc without affecting the repo
info "Setting up .zshrc..."
if [ ! -f "$HOME/.zshrc" ]; then
    # Create new .zshrc that sources the repo version
    cat > "$HOME/.zshrc" << EOF
# Source base zsh configuration from dotfiles
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    source "$DOTFILES_DIR/.zshrc"
fi
EOF
    info "Created ~/.zshrc that sources dotfiles version"
else
    # Check if it already sources the dotfiles version
    if ! grep -q "source.*$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" 2>/dev/null; then
        warn "Existing ~/.zshrc found. Prepending dotfiles source line..."
        # Backup existing
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
        # Prepend the source line
        cat > "$HOME/.zshrc.tmp" << EOF
# Source base zsh configuration from dotfiles
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    source "$DOTFILES_DIR/.zshrc"
fi

EOF
        cat "$HOME/.zshrc.backup" >> "$HOME/.zshrc.tmp"
        mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
        info "Updated ~/.zshrc to source dotfiles version (backup saved as ~/.zshrc.backup)"
    else
        info "~/.zshrc already sources dotfiles version, skipping"
    fi
fi

# Symlink CoC settings to vim directory
info "Symlinking CoC settings..."
mkdir -p ~/.vim
ln -sf "$DOTFILES_DIR/coc-settings.json" ~/.vim/coc-settings.json

# Ensure ~/.local/bin is in PATH (for uv tools)
export PATH="$HOME/.local/bin:$PATH"

# Install Python tools via uv
info "Installing Python tools (ty, ruff) via uv..."
uv tool install ty@latest
uv tool install ruff

# Vim plugins will auto-install on first launch
info "Vim plugins will auto-install when you first open vim"
info "Note: CoC.nvim will take ~30 seconds to build on first vim startup"

echo

# ============================================================================
# Set zsh as default shell
# ============================================================================
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
        echo "$(which zsh)" | sudo tee -a /etc/shells > /dev/null
    fi
    sudo chsh -s "$(which zsh)" "$USER" 2>/dev/null || {
        warn "Could not change default shell. You may need to run: chsh -s \$(which zsh)"
    }
    success "Default shell set to zsh (takes effect on next login)"
else
    info "zsh is already the default shell"
fi

echo
info "=================================="
info "Installation complete!"
info "=================================="
echo
info "Dotfiles symlinked from: $DOTFILES_DIR"
echo
info "Next steps:"
echo "  1. Start zsh: zsh (or logout and login for new default shell)"
echo "  2. Authenticate with GitHub CLI: gh auth login"
echo "  3. Open vim to verify plugins are working"
echo
info "Installed tools:"
echo "  - vim: $(vim --version | head -n1)"
echo "  - tmux: $(tmux -V)"
echo "  - Node.js: $(node --version)"
echo "  - fzf: $(fzf --version)"
echo "  - ripgrep: $(rg --version | head -n1)"
echo "  - gh: $(gh --version | head -n1)"
echo "  - uv: $(uv --version)"
echo "  - ty: $(uv tool run ty --version 2>/dev/null || echo 'Check installation')"
echo "  - ruff: $(uv tool run ruff --version 2>/dev/null || echo 'Check installation')"
