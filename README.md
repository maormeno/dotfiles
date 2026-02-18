# dotfiles

> Truly minimalistic dotfiles managed with [chezmoi](https://www.chezmoi.io/)

## 🎯 What's Included

This dotfiles repository provides automatic installation and setup for:

- **Ghostty** - Modern GPU-accelerated terminal emulator
- **Zsh** - Enhanced shell with essential plugins only:
  - `zsh-autosuggestions` - Command suggestions based on history
  - `zsh-syntax-highlighting` - Real-time syntax highlighting
  - `zsh-completions` - Additional completion definitions
- **Arc** - The Browser Company's Arc browser
- **Raycast** - Productivity launcher for macOS

## 🚀 Quick Start

Run this one-liner to install everything:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/maormeno/dotfiles/main/install.sh)
```

Or clone and run manually:

```bash
git clone https://github.com/maormeno/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## 📦 What Happens During Installation

1. Installs [chezmoi](https://www.chezmoi.io/) if not present
2. Clones this dotfiles repository
3. Runs installation scripts for each component
4. Applies dotfile configurations to your home directory

## 🔄 Updating

To update your dotfiles after the initial installation:

```bash
chezmoi update
```

## 🛠 Manual Management

### Apply changes
```bash
chezmoi apply
```

### Edit a dotfile
```bash
chezmoi edit ~/.zshrc
```

### See what would change
```bash
chezmoi diff
```

## 📋 Requirements

- **macOS** (primary target) or **Linux**
- **Git**
- **Homebrew** (macOS) or appropriate package manager (Linux)

## 🎨 Philosophy

This dotfiles repository follows a minimalistic approach:

- ✅ Only essential tools and configurations
- ✅ Automatic installation and setup
- ✅ Version-controlled configuration
- ✅ Easy to understand and modify
- ❌ No bloat or unnecessary plugins
- ❌ No complex customizations

## 📝 License

MIT