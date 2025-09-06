#!/bin/bash

# .zshrc에 플러그인을 추가하는 함수 정의
add_plugin_to_zshrc() {
    local plugin="$1"
    local zshrc="$HOME/.zshrc"

    if grep -q "^plugins=" "$zshrc"; then
        if ! grep -q "$plugin" "$zshrc"; then
            echo "'$plugin' 플러그인을 .zshrc에 추가합니다..."
            # 현재 plugins 라인을 찾아서 플러그인 추가
            # 멀티라인 plugins 배열 처리를 위해 더 정교한 방법 사용
            awk -v plugin="$plugin" '
            /^plugins=\(/ {
                if ($0 ~ /\)$/) {
                    # 한 줄로 된 plugins 배열
                    gsub(/\)$/, " " plugin ")")
                } else {
                    # 멀티라인 plugins 배열 시작
                    print $0
                    in_plugins = 1
                    next
                }
            }
            in_plugins && /^\)/ {
                # 멀티라인 plugins 배열 끝
                print "\t" plugin
                in_plugins = 0
            }
            { print }
            ' "$zshrc" > "$zshrc.tmp" && mv "$zshrc.tmp" "$zshrc"
            echo "플러그인 추가 완료!"
        else
            echo "'$plugin' 플러그인은 이미 .zshrc에 추가되어 있습니다."
        fi
    else
        echo "plugins=($plugin)" >> "$zshrc"
        echo "plugins 라인을 .zshrc에 추가했습니다."
    fi
}

echo "zsh 설치 여부 확인 중..."

if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh가 설치되어 있지 않습니다. 설치를 진행합니다..."
    if command -v brew >/dev/null 2>&1; then
        brew install zsh
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh
    else
        echo "zsh를 자동으로 설치할 수 없습니다. 수동으로 설치해 주세요."
        exit 1
    fi
else
    echo "zsh가 이미 설치되어 있습니다."
fi

echo "Oh My Zsh 설치 확인 중..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh가 설치되어 있지 않습니다. 설치를 진행합니다..."
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command -v wget >/dev/null 2>&1; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "curl 또는 wget이 필요합니다. 설치 후 다시 시도해 주세요."
        exit 1
    fi
    echo "Oh My Zsh 설치 완료!"
else
    echo "Oh My Zsh가 이미 설치되어 있습니다."
fi

echo "zsh-autosuggestions 플러그인 설치 중..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    echo "zsh-autosuggestions가 설치되어 있지 않습니다. 설치를 진행합니다..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
    echo "zsh-autosuggestions 설치 완료!"
else
    echo "zsh-autosuggestions가 이미 설치되어 있습니다."
fi

# 함수로 플러그인 추가
add_plugin_to_zshrc "zsh-autosuggestions"

echo "zsh-syntax-highlighting 플러그인 설치 중..."
ZSH_SYNTAX_HIGHLIGHTING_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
    echo "zsh-syntax-highlighting이 설치되어 있지 않습니다. 설치를 진행합니다..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
    echo "zsh-syntax-highlighting 설치 완료!"
else
    echo "zsh-syntax-highlighting이 이미 설치되어 있습니다."
fi

# 함수로 플러그인 추가
add_plugin_to_zshrc "zsh-syntax-highlighting"

echo "설정이 완료되었습니다! 변경사항을 적용하려면 'source ~/.zshrc'를 실행하세요."
