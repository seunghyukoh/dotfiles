# zsh / oh-my-zsh 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** macOS에 zsh + oh-my-zsh 환경(플러그인,
zoxide/fzf 통합, alias)을 재현하기 위한 실행 가이드입니다.
(과거 `setup_zsh.sh`를 대체하는 런북입니다.)

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/zsh-setup.md` 를 읽고 그대로 zsh 환경을 셋업해줘."

---

## 0. 실행 원칙

- **멱등성**: 각 단계는 적용 여부를 먼저 확인하고, 됐으면 건너뛴다.
- **백업 우선**: `~/.zshrc` 수정 전 중복 여부를 `grep`으로 확인한다.
- **검증 필수**: 마지막에 `zsh -n`/`zsh -ic`로 문법과 로드를 확인한다.
- **환경 전제**: macOS 또는 Linux(Homebrew), dotfiles는 `~/Developer/dotfiles`에 클론돼 있다.
  (oh-my-zsh·플러그인·brew 도구는 두 OS에서 동일하게 동작한다.)

---

## 1. zsh & Oh My Zsh 설치

```bash
# zsh (macOS 기본 제공이지만 최신 버전 권장)
command -v zsh >/dev/null || brew install zsh

# Oh My Zsh (미설치 시에만)
[ -d "$HOME/.oh-my-zsh" ] || \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

---

## 2. 외부 도구 (Homebrew)

플러그인/통합이 의존하는 CLI 도구.

```bash
brew install zoxide fzf autojump
```

| 도구 | 역할 |
|------|------|
| `zoxide` | 똑똑한 `cd` (자주 가는 디렉토리 점프) |
| `fzf` | 퍼지 파인더 + 키바인딩/보완 |
| `autojump` | `j` 디렉토리 점프 (oh-my-zsh `autojump` 플러그인이 사용) |

---

## 3. 커스텀 플러그인 클론

oh-my-zsh 기본 외 플러그인은 `$ZSH_CUSTOM/plugins`에 git clone 한다.

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

---

## 4. `.zshrc` 구성

### 4-1. plugins 목록

`~/.zshrc`의 `plugins=(...)`가 아래를 포함해야 한다(순서 무관):

```sh
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    autojump
    fzf
)
```

확인:

```bash
awk '/^plugins=\(/{f=1} f{print} f&&/\)/{exit}' ~/.zshrc
```

빠진 항목이 있으면 `plugins=(...)` 안에 추가한다.
(`syntax-highlighting`은 다른 플러그인보다 **뒤**에 와야 정상 동작.)

### 4-2. zoxide / fzf 초기화

`~/.zshrc` 끝에 init 라인을 멱등 추가한다.

```bash
grep -q 'zoxide init zsh' ~/.zshrc || printf '\n# zoxide (smarter cd)\neval "$(zoxide init zsh)"\n' >> ~/.zshrc
grep -q 'fzf --zsh'       ~/.zshrc || printf '\n# fzf key bindings and completion\nsource <(fzf --zsh)\n' >> ~/.zshrc
```

### 4-3. 테마

기본 테마는 `robbyrussell` (oh-my-zsh 기본값과 동일).

```bash
grep -q '^ZSH_THEME=' ~/.zshrc || echo 'ZSH_THEME="robbyrussell"' >> ~/.zshrc
```

---

## 5. alias 연결 — `aliases.zsh` 심링크

alias 본체는 이 저장소의 `aliases.zsh`다. oh-my-zsh custom으로 심링크해서
자동 로드되게 한다.

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ln -sfv "$HOME/Developer/dotfiles/aliases.zsh" "$ZSH_CUSTOM/aliases.zsh"
```

포함된 주요 alias: `vim=nvim`, `sz`(source zshrc), `t`(tmux new -As),
`ls/ll/la/lt`(eza), `cat`(bat), `gs/gd/gp/gl/...`(git), `lg`(lazygit).
이들은 `eza`/`bat`/`lazygit` 설치를 전제로 한다(`brew install eza bat lazygit`).

---

## 6. 검증

```bash
zsh -n ~/.zshrc && echo "zshrc 문법 OK"
zsh -ic 'echo "plugins=$plugins"; for t in zoxide fzf autojump; do command -v $t >/dev/null && echo "$t OK"; done'
```

적용: 새 터미널을 열거나 `source ~/.zshrc`.

> 참고: 이 저장소의 `yazi-setup.md`도 `~/.zshrc`에 `y()` 함수와 `EDITOR=nvim`을
> 추가한다. zsh 환경을 새로 구성했다면 yazi 런북의 4번 항목도 함께 적용하면 된다.
