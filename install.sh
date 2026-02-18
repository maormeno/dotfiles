#!/bin/bash
# Bootstrap script for setting up dotfiles with chezmoi

set -e

DOTFILES_REPO="maormeno/dotfiles"

echo "🚀 Installing minimal dotfiles..."

# Install chezmoi if not already installed
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install chezmoi
        else
            # Install Homebrew first
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install chezmoi
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sh -c "$(curl -fsLS get.chezmoi.io)"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
else
    echo "✓ chezmoi already installed"
fi

# Initialize chezmoi with this repository
echo "Initializing dotfiles..."
chezmoi init --apply "https://github.com/${DOTFILES_REPO}.git"

echo "✨ Dotfiles installation complete!"
echo ""
echo "Installed components:"
echo "  ✓ Ghostty terminal"
echo "  ✓ Zsh with essential plugins (autosuggestions, syntax-highlighting, completions)"
echo "  ✓ Arc browser"
echo "  ✓ Raycast"
echo ""
echo "To update your dotfiles in the future, run:"
echo "  chezmoi update"
