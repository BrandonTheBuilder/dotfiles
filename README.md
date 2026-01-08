# Dotfiles

Personal development environment configuration for vim, tmux, and zsh.

## Features

### Vim
- **Plugin Manager:** vim-plug with auto-installation
- **LSP Support:** CoC.nvim with language servers for Python (ty), Bash, and Go
- **Fuzzy Finding:** FZF integration for files, buffers, and text search
- **Git Integration:** vim-signify for git diff indicators
- **GitHub:** vim-pr-comments for reviewing pull requests in vim
- **Editing:** vim-commentary, vim-surround, auto-pairs
- **UI:** Custom lightline statusbar with mode-based colors
- **Settings:** Relative line numbers, persistent undo, system clipboard integration

### Tmux
- **Prefix Key:** `Ctrl-g` (instead of default `Ctrl-b`)
- **Vi Keybindings:** hjkl navigation, vi-style copy mode
- **Copy Mode:** Yank to system clipboard, smart vim detection
- **Pane Management:** Easy splitting with `v` (vertical) and `s` (horizontal)
- **Visual Style:** Minimal status bar with color-matched active indicators

### Zsh
- **Theme:** Powerlevel10k with custom configuration
- **Plugins:** autosuggestions, syntax highlighting, vi-mode
- **Features:** Vi mode, fuzzy history search (FZF), case-insensitive completion
- **Colors:** Custom LS_COLORS with blue directories
- **Aliases:** Quick navigation (`..`, `...`), shortened commands (`v`, `ll`)

## Installation

### Prerequisites
- macOS or Linux
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/BrandonTheBuilder/dotfiles.git ~/dotfiles

# Run the installation script
cd ~/dotfiles
./install.sh
```

The install script will:
1. Install Homebrew (if not present)
2. Install required packages: vim, tmux, node, fzf, ripgrep, gh, uv
3. Install Oh-My-Zsh and Powerlevel10k theme
4. Install zsh plugins (autosuggestions, syntax highlighting)
5. Install vim-plug and all vim plugins
6. Symlink dotfiles to your home directory
7. Create `~/.zshrc` that sources the repository version

### Post-Installation

1. Restart your terminal or run: `source ~/.zshrc`
2. Authenticate with GitHub CLI: `gh auth login`
3. Run Powerlevel10k configuration: `p10k configure`
4. Open vim to verify plugins are working

### Remote Clipboard Setup (Optional)

For remote workspaces, set up OSC 52 to copy from the workspace to your local machine's clipboard:

```bash
./setup-remote-clipboard.sh
```

This enables:
- Copy in tmux → paste on your local Mac (works through SSH)
- Mosh installation for better remote connections
- xclip for local workspace clipboard
- UTF-8 locale configuration

## Workspace Usage

This repository is designed to work with remote workspace tools that support the `--dotfiles` flag:

```bash
workspaces create --dotfiles https://github.com/BrandonTheBuilder/dotfiles
```

The workspace will automatically:
- Clone the repository to `~/dotfiles`
- Run `install.sh` to set up the environment
- Allow workspace-specific scripts to append to `~/.zshrc` without affecting the repository

## File Structure

```
.
├── .vimrc                          # Vim configuration
├── .tmux.conf                      # Tmux configuration
├── .zshrc                          # Zsh configuration (sourced by system .zshrc)
├── .p10k.zsh                       # Powerlevel10k theme configuration
├── coc-settings.json               # CoC.nvim language server settings
├── install.sh                      # Automated installation script
├── setup-remote-clipboard.sh       # Optional: OSC 52 and mosh setup for remote workspaces
├── vim-shortcuts-cheatsheet.md     # Quick reference for vim keybindings
└── README.md                       # This file
```

## Key Bindings

### Vim
- **Leader:** `Space`
- **Files:** `<leader>f` fuzzy find, `<leader>b` buffers, `<leader>g` grep
- **LSP:** `gd` definition, `K` docs, `<leader>rn` rename
- **Comments:** `gcc` toggle line, `gc{motion}` comment motion
- **Surround:** `ys{motion}{char}` add, `cs{old}{new}` change, `ds{char}` delete

### Tmux
- **Prefix:** `Ctrl-g`
- **Panes:** `prefix v` vertical split, `prefix s` horizontal split
- **Navigate:** `prefix h/j/k/l` move between panes
- **Resize:** `prefix H/J/K/L` resize panes
- **Copy Mode:** `prefix [` enter copy mode, `v` select, `y` yank

### Zsh
- **Vi Mode:** `Esc` for normal mode, `i/a` for insert mode
- **History:** `Ctrl-r` reverse search
- **Suggestions:** `→` accept autosuggestion

See [vim-shortcuts-cheatsheet.md](vim-shortcuts-cheatsheet.md) for complete reference.

## Customization

### Local Overrides

The `~/.zshrc` file is NOT symlinked - it's a real file that sources the repository version. This allows you to:
- Add local customizations after the source line
- Have workspace tools append configuration
- Keep local changes separate from the repository

### Updating

To get the latest changes:

```bash
cd ~/dotfiles  # or ~/.dotfiles
git pull
```

Changes to vim, tmux, and zsh configs are immediately reflected (no need to re-run install.sh).

### Adding New Plugins

**Vim:** Edit `.vimrc`, add `Plug 'author/plugin'`, then run `:PlugInstall`

**Zsh:** Clone plugin to `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/`, add to `plugins=()` in `.zshrc`

## Tools Included

| Tool | Purpose |
|------|---------|
| vim | Text editor |
| tmux | Terminal multiplexer |
| fzf | Fuzzy finder |
| ripgrep | Fast text search |
| gh | GitHub CLI |
| node | JavaScript runtime (for CoC.nvim) |
| uv | Python package manager |
| ty | Python LSP server |
| ruff | Python linter |

## License

MIT - Feel free to use and modify as you wish.

## Credits

Built with assistance from [Claude Code](https://claude.com/claude-code).
