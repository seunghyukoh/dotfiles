#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo "========================================="
echo " Dotfiles Installation ($OS)"
echo "========================================="

# 1. 패키지 설치
echo ""
echo "[1/4] Packages..."
if [ "$OS" = "Darwin" ]; then
    bash "$DOTFILES_DIR/setup_brew.sh"
elif [ "$OS" = "Linux" ]; then
    bash "$DOTFILES_DIR/setup_apt.sh"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# 2. Zsh & 플러그인 설정
echo ""
echo "[2/4] Zsh & plugins..."
bash "$DOTFILES_DIR/setup_zsh.sh"

# 3. Node.js (nvm) 설정
echo ""
echo "[3/4] Node.js (nvm)..."
bash "$DOTFILES_DIR/setup_nvm.sh"

# 4. Symlink 및 설정
echo ""
echo "[4/4] Symlinking dotfiles..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# aliases.zsh
ln -sfv "$DOTFILES_DIR/aliases.zsh" "$ZSH_CUSTOM/aliases.zsh"

# tmux.conf
ln -sfv "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# git delta 설정
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global merge.conflictstyle zdiff3
    echo "git-delta configured as default pager."
fi

# ~/.local/bin을 PATH에 추가 (Linux에서 bat, fd symlink 용)
if [ "$OS" = "Linux" ]; then
    ZSHRC="$HOME/.zshrc"
    if ! grep -q 'HOME/.local/bin' "$ZSHRC" 2>/dev/null; then
        echo '' >> "$ZSHRC"
        echo '# local binaries' >> "$ZSHRC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
        echo "Added ~/.local/bin to PATH in .zshrc."
    fi
fi

echo ""
echo "========================================="
echo " Installation complete!"
echo " Run 'source ~/.zshrc' to apply changes."
echo "========================================="
