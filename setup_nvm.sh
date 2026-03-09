#!/bin/bash

set -e

if ! brew list nvm &>/dev/null; then
    echo "Installing nvm..."
    brew install nvm
else
    echo "nvm is already installed."
fi

echo "Adding NVM environment variables and initialization script to your shell profile..."

# 현재 실행 셸이 아닌 사용자의 기본 셸 기준으로 판단
NVM_PROFILE=""
USER_SHELL="$(basename "$SHELL")"
if [ "$USER_SHELL" = "zsh" ]; then
    NVM_PROFILE="$HOME/.zshrc"
elif [ "$USER_SHELL" = "bash" ]; then
    NVM_PROFILE="$HOME/.bashrc"
else
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