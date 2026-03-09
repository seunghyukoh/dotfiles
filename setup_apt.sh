#!/bin/bash

# Linux (Ubuntu/Debian) 패키지 설치 스크립트

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/packages.sh"

echo "Updating apt package list..."
sudo apt-get update

# --- apt로 직접 설치 가능한 패키지 ---
# packages.sh에서 apt 이름만 추출하되, 커스텀 설치가 필요한 것은 제외
CUSTOM_INSTALL=(eza git-delta lazygit zoxide uv nvm syncthing helm kubernetes-cli)

APT_PACKAGES=()
for pkg in "${CLI_PACKAGES[@]}"; do
    brew_name=$(get_brew_name "$pkg")
    apt_name=$(get_apt_name "$pkg")

    # 커스텀 설치 목록에 있으면 skip
    skip=false
    for custom in "${CUSTOM_INSTALL[@]}"; do
        if [ "$brew_name" = "$custom" ]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = false ]; then
        APT_PACKAGES+=("$apt_name")
    fi
done

echo "Installing apt packages: ${APT_PACKAGES[*]}"
sudo apt-get install -y "${APT_PACKAGES[@]}"

# --- bat: Ubuntu에서 batcat으로 설치됨 ---
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    echo "Created symlink: bat -> batcat"
fi

# --- fd: Ubuntu에서 fdfind로 설치됨 ---
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    echo "Created symlink: fd -> fdfind"
fi

# --- gh (GitHub CLI) ---
if ! command -v gh >/dev/null 2>&1; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
else
    echo "gh is already installed."
fi

# --- eza ---
if ! command -v eza >/dev/null 2>&1; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y eza
else
    echo "eza is already installed."
fi

# --- git-delta ---
if ! command -v delta >/dev/null 2>&1; then
    echo "Installing git-delta..."
    DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    ARCH=$(dpkg --print-architecture)
    curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" -o /tmp/git-delta.deb
    sudo dpkg -i /tmp/git-delta.deb
    rm -f /tmp/git-delta.deb
else
    echo "git-delta is already installed."
fi

# --- lazygit ---
if ! command -v lazygit >/dev/null 2>&1; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) ARCH="x86_64" ;;
        aarch64) ARCH="arm64" ;;
    esac
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" -o /tmp/lazygit.tar.gz
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
else
    echo "lazygit is already installed."
fi

# --- zoxide ---
if ! command -v zoxide >/dev/null 2>&1; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "zoxide is already installed."
fi

# --- uv ---
if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed."
fi

# --- VSCode 확장 (code가 설치된 경우만) ---
if command -v code >/dev/null 2>&1; then
    echo "Installing VSCode extensions..."
    for ext in "${VSCODE_EXTENSIONS[@]}"; do
        code --install-extension "$ext" --force 2>/dev/null || true
    done
    echo "VSCode extensions installation complete!"
else
    echo "VSCode (code) not found, skipping extensions."
fi

echo "Linux package installation complete!"
