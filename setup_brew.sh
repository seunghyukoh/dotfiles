#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/packages.sh"

echo "Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# packages.sh에서 Brewfile 자동 생성
BREWFILE="$DOTFILES_DIR/Brewfile"
echo "Generating Brewfile from packages.sh..."

{
    # taps
    for tap in "${BREW_TAPS[@]}"; do
        echo "tap \"$tap\""
    done

    # CLI packages
    for pkg in "${CLI_PACKAGES[@]}"; do
        name=$(get_brew_name "$pkg")
        if [ "$name" = "syncthing" ]; then
            echo "brew \"$name\", $BREW_SYNCTHING_OPTS"
        else
            echo "brew \"$name\""
        fi
    done

    # Casks
    for cask in "${CASK_PACKAGES[@]}"; do
        echo "cask \"$cask\""
    done

    # VSCode extensions
    for ext in "${VSCODE_EXTENSIONS[@]}"; do
        echo "vscode \"$ext\""
    done
} > "$BREWFILE"

echo "Installing Brewfile..."
brew bundle install --file "$BREWFILE"
echo "Brewfile installation complete!"
