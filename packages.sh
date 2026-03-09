#!/bin/bash

# 패키지 목록 단일 관리 파일
# 모든 설치 스크립트가 이 파일을 source하여 사용

# --- Homebrew taps (macOS만 해당) ---
BREW_TAPS=(
    "runpod/runpodctl"
    "tsung-ju/iguanatexmac"
)

# --- CLI 도구 ---
# "brew_name:apt_name" 형식 (이름이 같으면 하나만 기입)
CLI_PACKAGES=(
    "autossh"
    "bat"
    "cpanminus:cpanminus"
    "eza"
    "fd:fd-find"
    "fzf"
    "gh"
    "git-delta"
    "git"
    "git-lfs"
    "helm"
    "kubernetes-cli:kubectl"
    "lazygit"
    "neovim"
    "nvm"
    "parallel"
    "pkgconf:pkg-config"
    "ripgrep"
    "syncthing"
    "tmux"
    "uv"
    "watch"
    "zoxide"
    "zsh"
)

# syncthing 옵션 (macOS에서 restart_service 사용)
BREW_SYNCTHING_OPTS="restart_service: :changed"

# --- macOS GUI 앱 (cask) ---
CASK_PACKAGES=(
    "1password-cli"
    "alfred"
    "appcleaner"
    "codex"
    "cyberduck"
    "docker-desktop"
    "fliqlo"
    "font-meslo-lg-nerd-font"
    "heynote"
    "iguanatexmac"
    "iterm2"
    "karabiner-elements"
    "latexit-metadata"
    "obsidian"
    "skim"
    "visual-studio-code"
)

# --- VSCode 확장 ---
VSCODE_EXTENSIONS=(
    "aaron-bond.better-comments"
    "alefragnani.bookmarks"
    "anthropic.claude-code"
    "bradlc.vscode-tailwindcss"
    "charliermarsh.ruff"
    "christian-kohler.npm-intellisense"
    "codezombiech.gitignore"
    "cweijan.dbclient-jdbc"
    "cweijan.vscode-mysql-client2"
    "davidanson.vscode-markdownlint"
    "docker.docker"
    "donjayamanne.githistory"
    "donjayamanne.python-environment-manager"
    "donjayamanne.python-extension-pack"
    "durzn.brackethighlighter"
    "editorconfig.editorconfig"
    "elagil.pre-commit-helper"
    "equinusocio.vsc-material-theme-icons"
    "esbenp.prettier-vscode"
    "felipecaputo.git-project-manager"
    "formulahendry.auto-rename-tag"
    "github.codespaces"
    "github.copilot"
    "github.copilot-chat"
    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
    "gruntfuggly.todo-tree"
    "james-yu.latex-workshop"
    "kevinrose.vsc-python-indent"
    "magicstack.magicpython"
    "mathematic.vscode-latex"
    "mechatroner.rainbow-csv"
    "mhutchie.git-graph"
    "miguelsolorio.fluent-icons"
    "mikestead.dotenv"
    "monokai.theme-monokai-pro-vscode"
    "ms-azuretools.vscode-containers"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"
    "ms-toolsai.datawrangler"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.vscode-remote-extensionpack"
    "ms-vscode.cpptools"
    "ms-vscode.live-server"
    "ms-vscode.remote-explorer"
    "ms-vscode.remote-server"
    "natizyskunk.sftp"
    "necatiarslan.aws-s3-vscode-extension"
    "nickfode.latex-formatter"
    "njpwerner.autodocstring"
    "openai.chatgpt"
    "pkief.material-icon-theme"
    "pkief.material-product-icons"
    "rangav.vscode-thunder-client"
    "redhat.vscode-yaml"
    "rvest.vs-code-prettier-eslint"
    "shakram02.bash-beautify"
    "solitechnologyllc.sync-code-cloud"
    "spencerjames.ss3sync"
    "tecosaur.latex-utilities"
    "tomoki1207.pdf"
    "unifiedjs.vscode-mdx"
    "usernamehw.errorlens"
    "waderyan.gitblame"
    "wholroyd.jinja"
    "zainchen.json"
)

# --- 헬퍼 함수 ---

# brew_name:apt_name 에서 brew 이름 추출
get_brew_name() {
    echo "${1%%:*}"
}

# brew_name:apt_name 에서 apt 이름 추출 (없으면 brew 이름 반환)
get_apt_name() {
    if [[ "$1" == *:* ]]; then
        echo "${1#*:}"
    else
        echo "$1"
    fi
}
