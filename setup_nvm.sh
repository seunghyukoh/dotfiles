#!/bin/bash

set -e 

brew install nvm

echo "Adding NVM environment variables and initialization script to your shell profile..."

NVM_PROFILE=""
if [ -n "$ZSH_VERSION" ]; then
    NVM_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    NVM_PROFILE="$HOME/.bashrc"
else
    # Use .profile as default
    NVM_PROFILE="$HOME/.profile"
fi

# Check if it's already added
if ! grep -q 'export NVM_DIR="\$HOME/.nvm"' "$NVM_PROFILE"; then
    {
        echo ''
        echo 'export NVM_DIR="$HOME/.nvm"'
        echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm'
        echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion'
    } >> "$NVM_PROFILE"
    echo "NVM settings have been added to $NVM_PROFILE."
else
    echo "NVM settings already exist in $NVM_PROFILE."
fi

# Apply to current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

nvm install 22
nvm alias default 22
nvm use 22

echo "NVM setup complete!"