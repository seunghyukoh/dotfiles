# nvm / Node.js 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** nvm(Node Version Manager)을 설치하고 Node.js를
구성하기 위한 실행 가이드입니다. **macOS와 Linux(Homebrew) 공통**입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/nvm-setup.md` 를 읽고 Node 환경을 셋업해줘."

전제: Homebrew가 설치돼 있다(→ `brew-setup.md`).

---

## 0. 실행 원칙

- **멱등성**: 설치/초기화 라인은 존재 여부를 확인하고 추가한다.
- **경로 무관**: `$HOMEBREW_PREFIX`를 써서 macOS/Linux 경로 차이를 흡수한다.
  (`brew shellenv`가 설정하는 변수. 없으면 `$(brew --prefix)`로 대체)
- **검증 필수**: 마지막에 `node`/`npm` 버전을 확인한다.

---

## 1. nvm 설치

```bash
brew list nvm >/dev/null 2>&1 || brew install nvm
mkdir -p ~/.nvm
```

---

## 2. `.zshrc` 초기화 라인 (멱등 추가)

nvm은 셸 시작 시 로드돼야 한다. macOS/Linux 모두에서 동작하도록
`$HOMEBREW_PREFIX` 기반으로 추가한다.

```bash
grep -q 'NVM_DIR' ~/.zshrc || cat >> ~/.zshrc <<'EOF'

# ---- nvm (Node Version Manager) ----
export NVM_DIR="$HOME/.nvm"
# Homebrew 설치 경로 (macOS: /opt/homebrew, Linux: /home/linuxbrew/.linuxbrew)
NVM_BREW="${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/nvm"
[ -s "$NVM_BREW/nvm.sh" ] && \. "$NVM_BREW/nvm.sh"
[ -s "$NVM_BREW/etc/bash_completion.d/nvm" ] && \. "$NVM_BREW/etc/bash_completion.d/nvm"
EOF
```

> 참고: 기존 `~/.zshrc`에는 macOS 경로가 하드코딩된 nvm 라인이 있을 수 있다
> (`/opt/homebrew/opt/nvm/nvm.sh`). Linux와 공유하는 dotfiles라면 위처럼
> `$HOMEBREW_PREFIX` 기반으로 통일하는 것을 권장한다.

---

## 3. Node.js 설치

현재 셸 세션에 nvm을 로드한 뒤 LTS(22)를 설치하고 기본값으로 지정한다.

```bash
export NVM_DIR="$HOME/.nvm"
. "${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/nvm/nvm.sh"
nvm install 22
nvm alias default 22
nvm use 22
```

---

## 4. 검증

```bash
zsh -n ~/.zshrc && echo "zshrc 문법 OK"
zsh -ic 'command -v nvm >/dev/null && echo "nvm: $(nvm --version)"; echo "node: $(node -v)"; echo "npm: $(npm -v)"'
```

`node v22.x`가 나오면 완료. 적용은 새 터미널 또는 `source ~/.zshrc`.
