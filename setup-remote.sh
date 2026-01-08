#!/usr/bin/env bash
# Remote Workspace Setup Script
# Configures OSC 52, mosh, and other tools for remote development

set -e

echo "=========================================="
echo "Remote Workspace Setup"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo -e "${BLUE}[✓]${NC} $1"
}

# Get the directory where this script lives (the dotfiles directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "Dotfiles directory: $DOTFILES_DIR"
echo

# ============================================================================
# Test OSC 52 Support
# ============================================================================
info "Testing if your terminal supports OSC 52..."

# Try to copy a test string using OSC 52
printf "\033]52;c;$(printf "OSC52-test" | base64)\a"

echo
echo "If OSC 52 is supported, 'OSC52-test' should now be in your LOCAL clipboard."
echo "Try pasting (Cmd+V on Mac) to verify."
echo
read -p "Did the test work? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "OSC 52 doesn't seem to be working with your terminal."
    echo
    echo "Common fixes:"
    echo "  - iTerm2: Preferences → General → Selection → 'Applications in terminal may access clipboard'"
    echo "  - WezTerm: Should work by default"
    echo "  - Alacritty: Add 'osc52' to features in config"
    echo "  - Terminal.app: Not supported, use iTerm2"
    echo
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Setup cancelled."
        exit 1
    fi
else
    success "OSC 52 is working!"
fi

echo

# ============================================================================
# Install xclip and mosh (for remote sessions)
# ============================================================================
info "Installing xclip and mosh for remote workspace..."

if command -v apt-get &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y xclip mosh locales

    # Configure locale for mosh
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8

    success "xclip and mosh installed"

    # Add locale settings to .zshrc if not already present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "export LANG=en_US.UTF-8" "$HOME/.zshrc" 2>/dev/null; then
            info "Adding locale settings to ~/.zshrc"
            cat >> "$HOME/.zshrc" << 'EOF'

# Locale settings for mosh
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF
            success "Locale settings added to ~/.zshrc"
        fi
    fi

    info "To connect with mosh from your local machine:"
    echo "  mosh user@host -- tmux new -A -s main"
    echo
    info "Mosh uses UDP ports 60000-61000 by default"

elif command -v brew &> /dev/null; then
    # macOS
    info "On macOS, using pbcopy instead of xclip"

    if ! command -v mosh &> /dev/null; then
        info "Installing mosh..."
        brew install mosh
        success "mosh installed"
    fi
else
    warn "No package manager found, skipping installation"
fi

echo

# ============================================================================
# Configure Tmux for OSC 52
# ============================================================================
info "Configuring tmux for OSC 52..."

# Create a local tmux config extension (not tracked in git)
TMUX_LOCAL="$HOME/.tmux.local.conf"

# Check if OSC 52 is already configured
if [ -f "$TMUX_LOCAL" ] && grep -q "set -s set-clipboard on" "$TMUX_LOCAL" 2>/dev/null; then
    info "Tmux OSC 52 already configured"
else
    info "Adding OSC 52 support to local tmux config..."

    # Create local config file with OSC 52 support
    cat > "$TMUX_LOCAL" << 'EOF'
# ============================================================================
# Remote Clipboard Support (OSC 52)
# ============================================================================
# Enable OSC 52 passthrough to copy to local machine clipboard
set -s set-clipboard on

# Override copy-pipe-and-cancel to use OSC 52
# This sends the copied text to your local machine's clipboard
unbind -T copy-mode-vi y
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "yank-osc52"
EOF

    success "Tmux OSC 52 config created at ~/.tmux.local.conf"
    info "The dotfiles .tmux.conf automatically sources this file"
fi

echo

# ============================================================================
# Create yank-osc52 Helper Script
# ============================================================================
info "Creating yank-osc52 helper script..."

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/yank-osc52" << 'EOF'
#!/usr/bin/env bash
# Helper script to copy to clipboard via OSC 52
# Works through SSH and nested tmux sessions

# Read input from stdin
input=$(cat)

# Encode to base64
encoded=$(printf "%s" "$input" | base64 | tr -d '\n')

# Send OSC 52 escape sequence
# This works even through tmux/SSH by wrapping in DCS
if [ -n "$TMUX" ]; then
    # Inside tmux, use DCS passthrough
    printf "\ePtmux;\e\e]52;c;%s\a\e\\" "$encoded"
else
    # Direct to terminal
    printf "\e]52;c;%s\a" "$encoded"
fi

# Also copy to local clipboard as fallback
if command -v xclip &> /dev/null; then
    printf "%s" "$input" | xclip -selection clipboard
elif command -v pbcopy &> /dev/null; then
    printf "%s" "$input" | pbcopy
fi
EOF

chmod +x "$HOME/.local/bin/yank-osc52"
success "Created yank-osc52 helper at ~/.local/bin/yank-osc52"

echo

# ============================================================================
# Ensure ~/.local/bin is in PATH
# ============================================================================
info "Ensuring ~/.local/bin is in PATH..."

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "~/.local/bin is not in PATH"

    # Check if we should add it to .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
            info "Adding ~/.local/bin to PATH in ~/.zshrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            success "Updated ~/.zshrc"
        fi
    fi

    echo "Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    success "~/.local/bin is already in PATH"
fi

echo

# ============================================================================
# Optional: Configure Vim for OSC 52
# ============================================================================
info "Vim clipboard support..."
echo "To enable OSC 52 in vim, you can install a plugin like:"
echo "  Plug 'ojroques/vim-oscyank'"
echo
echo "Then add to your .vimrc:"
echo "  vnoremap <leader>y :OSCYank<CR>"
echo

# ============================================================================
# Completion
# ============================================================================
echo
success "=========================================="
success "Remote Workspace Setup Complete!"
success "=========================================="
echo
info "How to use remote clipboard:"
echo "  1. In tmux copy mode: press 'y' to yank"
echo "  2. Text is copied to your LOCAL machine's clipboard via OSC 52"
echo "  3. Paste on your Mac with Cmd+V"
echo
info "Testing:"
echo "  1. Open tmux: tmux"
echo "  2. Enter copy mode: Ctrl-g ["
echo "  3. Select text with 'v' and 'y' to yank"
echo "  4. Exit tmux and paste on your local machine"
echo
info "Note: Restart tmux for changes to take effect:"
echo "  tmux kill-server && tmux"
echo

# ============================================================================
# Optional: Start Mosh Server
# ============================================================================
if command -v mosh-server &> /dev/null; then
    echo
    read -p "Would you like to start a mosh server now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Starting mosh server on ports 60000-60010..."
        echo
        echo "Run this command from your LOCAL machine to connect:"
        echo
        echo "  mosh $USER@$(hostname) -- tmux new -A -s main"
        echo
        echo "Or if you need to specify ports:"
        echo
        echo "  mosh --server='mosh-server new -s -c 8 -p 60000:60010' $USER@$(hostname) -- tmux new -A -s main"
        echo
        info "Mosh server info:"
        mosh-server new -s -c 8 -p 60000:60010
    else
        info "Skipped. You can start mosh server later with:"
        echo "  mosh-server new -s -c 8 -p 60000:60010"
    fi
fi
echo
