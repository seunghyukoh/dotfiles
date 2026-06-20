# Homebrew + 패키지 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** Homebrew를 설치하고 이 저장소의 `Brewfile`로
CLI/GUI/VSCode 패키지를 일괄 설치하기 위한 실행 가이드입니다.
**macOS와 Linux(Homebrew on Linux) 공통**으로 동작합니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/brew-setup.md` 를 읽고 그대로 패키지를 셋업해줘."

이 런북은 보통 **가장 먼저** 실행한다(다른 런북들이 brew 패키지에 의존).

---

## 0. 실행 원칙

- **멱등성**: Homebrew와 `brew bundle`은 이미 설치된 항목을 건너뛴다.
- **OS 분기**: macOS는 cask/VSCode 포함 전체, Linux는 CLI 패키지만(아래 3-B).
- **검증 필수**: 마지막에 `brew bundle check`로 누락을 확인한다.

---

## 1. Homebrew 설치

```bash
command -v brew >/dev/null || \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Linux 추가 단계 — shellenv 등록

macOS는 설치 시 PATH가 잡히지만, **Linux는 직접 등록**해야 한다.

```bash
# Linux일 때만
if [ "$(uname -s)" = "Linux" ]; then
  BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
  [ -x "$BREW_BIN" ] || BREW_BIN="$HOME/.linuxbrew/bin/brew"
  eval "$("$BREW_BIN" shellenv)"
  # 셸 시작 시마다 적용되도록 프로파일에 멱등 추가
  grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || \
    echo "eval \"\$($BREW_BIN shellenv)\"" >> ~/.zprofile
fi
```

**검증**

```bash
brew --version && echo "HOMEBREW_PREFIX=$(brew --prefix)"
# macOS(Apple Silicon): /opt/homebrew, Linux: /home/linuxbrew/.linuxbrew
```

---

## 2. 정본(source of truth) 방침

현재 저장소에는 패키지 목록이 **두 군데**에 있고 서로 어긋나 있다:

- `Brewfile` — `brew bundle dump` 기반의 실제 머신 백업(정본 권장)
- `packages.sh` — 과거 `setup_brew.sh`가 Brewfile을 생성할 때 쓰던 손관리 목록(레거시)

**권장**: `Brewfile`을 **단일 정본**으로 삼는다.
- 새 패키지 설치 후 반영: `brew bundle dump --force --file=Brewfile`
- `packages.sh`/`setup_brew.sh`는 레거시이므로 신규 작업에 사용하지 않는다.

> 이 방침을 따른다면 아래 3번은 `Brewfile`만 사용한다.

---

## 3. 패키지 설치

### 3-A. macOS — 전체 설치

```bash
brew bundle install --file="$HOME/Developer/dotfiles/Brewfile"
```

`Brewfile`의 `tap`/`brew`/`cask`/`vscode` 항목을 모두 설치한다.

### 3-B. Linux — CLI 패키지만

Linux의 Homebrew는 **cask(GUI 앱)를 지원하지 않는다**. `cask`/`vscode` 라인이
있으면 `brew bundle`이 실패하므로, **`tap`/`brew` 라인만 필터**해서 설치한다.

```bash
grep -E '^(tap|brew) ' "$HOME/Developer/dotfiles/Brewfile" \
  | brew bundle install --file=/dev/stdin
```

GUI 앱/폰트/VSCode 확장은 Linux에서는 각 환경 방식으로 별도 설치한다.

**검증**

```bash
# macOS
brew bundle check --file="$HOME/Developer/dotfiles/Brewfile" || echo "누락 항목 있음(위 목록 참고)"
# Linux
grep -E '^(tap|brew) ' "$HOME/Developer/dotfiles/Brewfile" | brew bundle check --file=/dev/stdin
```

`The Brewfile's dependencies are satisfied.` 가 나오면 완료.

---

## 부록: 주요 패키지 그룹

전체는 `~/Developer/dotfiles/Brewfile` 참조.

| 그룹 | 예시 |
|------|------|
| 셸/탐색 | `zsh` `tmux` `fzf` `zoxide` `fd` `ripgrep` `eza` `bat` `tree` |
| 파일 매니저 | `yazi` + 미리보기(`sevenzip` `poppler` `ffmpeg` `imagemagick` `resvg` `chafa`) |
| 에디터 | `neovim` |
| git | `git` `git-delta` `git-lfs` `gh` `lazygit` |
| 개발 | `uv` `nvm` `mise` `python@3.11` `direnv` |
| 인프라 | `kubernetes-cli` `helm` `autossh` `mosh` `syncthing` |
| GUI(cask, macOS만) | `iterm2` `visual-studio-code` `cursor` `obsidian` `docker-desktop` `1password-cli` |
