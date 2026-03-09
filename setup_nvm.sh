#!/bin/bash

set -e

OS="$(uname -s)"

# nvm 설치
if ! command -v nvm >/dev/null 2>&1 && [ ! -d "$HOME/.nvm" ]; then
    if [ "$OS" = "Darwin" ]; then
        if ! brew list nvm &>/dev/null; then
            echo "Installing nvm via Homebrew..."
            brew install nvm
        else
            echo "nvm is already installed via Homebrew."
        fi
    else
        echo "Installing nvm via install script..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
else
    echo "nvm is already installed."
fi

echo "Adding NVM environment variables and initialization script to your shell profile..."

# 사용자의 기본 셸 기준으로 판단
NVM_PROFILE=""
USER_SHELL="$(basename "$SHELL")"
if [ "$USER_SHELL" = "zsh" ]; then
    NVM_PROFILE="$HOME/.zshrc"
elif [ "$USER_SHELL" = "bash" ]; then
    NVM_PROFILE="$HOME/.bashrc"
else
    NVM_PROFILE="$HOME/.profile"
fi

# NVM 로딩 스크립트 (macOS와 Linux 모두 지원)
if ! grep -q 'export NVM_DIR="\$HOME/.nvm"' "$NVM_PROFILE"; then
    {
        echo ''
        echo 'export NVM_DIR="$HOME/.nvm"'
        if [ "$OS" = "Darwin" ]; then
            echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"'
            echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"'
        else
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
        fi
    } >> "$NVM_PROFILE"
    echo "NVM settings have been added to $NVM_PROFILE."
else
    echo "NVM settings already exist in $NVM_PROFILE."
fi

# 현재 셸 세션에 적용
export NVM_DIR="$HOME/.nvm"
if [ "$OS" = "Darwin" ]; then
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

nvm install 22
nvm alias default 22
nvm use 22

echo "NVM setup complete!"
