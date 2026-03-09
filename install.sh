#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo " Dotfiles Installation"
echo "========================================="

# 1. Homebrew 및 패키지 설치
echo ""
echo "[1/4] Homebrew & packages..."
bash "$DOTFILES_DIR/setup_brew.sh"

# 2. Zsh & 플러그인 설정
echo ""
echo "[2/4] Zsh & plugins..."
bash "$DOTFILES_DIR/setup_zsh.sh"

# 3. Node.js (nvm) 설정
echo ""
echo "[3/4] Node.js (nvm)..."
bash "$DOTFILES_DIR/setup_nvm.sh"

# 4. Symlink 설정
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

echo ""
echo "========================================="
echo " Installation complete!"
echo " Run 'source ~/.zshrc' to apply changes."
echo "========================================="
