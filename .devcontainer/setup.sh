#!/bin/bash

# devcontainer postCreateCommand
# Dockerfile에서 시스템 패키지 설치 완료 후, 사용자 환경 설정

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 1. Zsh & 플러그인 설정
echo "[1/3] Zsh & plugins..."
bash "$DOTFILES_DIR/setup_zsh.sh"

# 2. Symlink 설정
echo "[2/3] Symlinking dotfiles..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ln -sfv "$DOTFILES_DIR/aliases.zsh" "$ZSH_CUSTOM/aliases.zsh"
ln -sfv "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# 3. git-delta 설정
echo "[3/3] Configuring tools..."

if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global merge.conflictstyle zdiff3
    echo "git-delta configured as default pager."
fi

# ~/.local/bin을 PATH에 추가 (zoxide 등)
ZSHRC="$HOME/.zshrc"
if ! grep -q 'HOME/.local/bin' "$ZSHRC" 2>/dev/null; then
    echo '' >> "$ZSHRC"
    echo '# local binaries' >> "$ZSHRC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
fi

echo "Devcontainer setup complete!"
