#!/bin/bash

set -e

# Function to add plugins to .zshrc
add_plugin_to_zshrc() {
    local plugin="$1"
    local zshrc="$HOME/.zshrc"

    if grep -q "^plugins=" "$zshrc"; then
        if ! grep -q "$plugin" "$zshrc"; then
            echo "Adding '$plugin' plugin to .zshrc..."
            # Find current plugins line and add plugin
            # Use more sophisticated method to handle multiline plugins array
            awk -v plugin="$plugin" '
            /^plugins=\(/ {
                if ($0 ~ /\)$/) {
                    # Single line plugins array
                    gsub(/\)$/, " " plugin ")")
                } else {
                    # Multiline plugins array start
                    print $0
                    in_plugins = 1
                    next
                }
            }
            in_plugins && /^\)/ {
                # Multiline plugins array end
                print "\t" plugin
                in_plugins = 0
            }
            { print }
            ' "$zshrc" > "$zshrc.tmp" && mv "$zshrc.tmp" "$zshrc"
            echo "Plugin addition complete!"
        else
            echo "'$plugin' plugin is already added to .zshrc."
        fi
    else
        echo "plugins=($plugin)" >> "$zshrc"
        echo "Added plugins line to .zshrc."
    fi
}

echo "Checking zsh installation..."

if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh is not installed. Proceeding with installation..."
    if command -v brew >/dev/null 2>&1; then
        brew install zsh
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh
    else
        echo "Cannot automatically install zsh. Please install manually."
        exit 1
    fi
else
    echo "zsh is already installed."
fi

echo "Checking Oh My Zsh installation..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Proceeding with installation..."
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command -v wget >/dev/null 2>&1; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "curl or wget is required. Please install and try again."
        exit 1
    fi
    echo "Oh My Zsh installation complete!"
else
    echo "Oh My Zsh is already installed."
fi

echo "Installing zsh-autosuggestions plugin..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    echo "zsh-autosuggestions is not installed. Proceeding with installation..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
    echo "zsh-autosuggestions installation complete!"
else
    echo "zsh-autosuggestions is already installed."
fi

# Add plugin using function
add_plugin_to_zshrc "zsh-autosuggestions"

echo "Installing zsh-syntax-highlighting plugin..."
ZSH_SYNTAX_HIGHLIGHTING_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
    echo "zsh-syntax-highlighting is not installed. Proceeding with installation..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
    echo "zsh-syntax-highlighting installation complete!"
else
    echo "zsh-syntax-highlighting is already installed."
fi

# Add plugin using function
add_plugin_to_zshrc "zsh-syntax-highlighting"

# Add autojump plugin
add_plugin_to_zshrc "autojump"

echo "Setup complete! Run 'source ~/.zshrc' to apply changes."
