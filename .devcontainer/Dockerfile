FROM mcr.microsoft.com/devcontainers/base:ubuntu

# --- apt 패키지 ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    autossh \
    bat \
    cpanminus \
    fd-find \
    fzf \
    git-lfs \
    neovim \
    parallel \
    pkg-config \
    ripgrep \
    tmux \
    watch \
    xclip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# bat, fd symlinks (Ubuntu에서 batcat, fdfind로 설치됨)
RUN ln -sf /usr/bin/batcat /usr/local/bin/bat \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd

# --- eza ---
RUN mkdir -p /etc/apt/keyrings \
    && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        > /etc/apt/sources.list.d/gierens.list \
    && apt-get update && apt-get install -y eza \
    && rm -rf /var/lib/apt/lists/*

# --- git-delta ---
# https://github.com/dandavison/delta/releases
ARG DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" -o /tmp/git-delta.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm -f /tmp/git-delta.deb

# --- lazygit ---
# https://github.com/jesseduffield/lazygit/releases
ARG LAZYGIT_VERSION=0.44.1
RUN ARCH=$(uname -m) && case "$ARCH" in x86_64) ARCH="x86_64" ;; aarch64) ARCH="arm64" ;; esac \
    && curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" \
        | tar xz -C /usr/local/bin lazygit

# --- zoxide ---
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh \
    && mv /root/.local/bin/zoxide /usr/local/bin/zoxide

# --- uv ---
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx
