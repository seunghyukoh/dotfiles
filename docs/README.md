# dotfiles 셋업 런북

이 디렉토리는 도구별 **에이전트 실행형 셋업 런북**을 모아둔 곳입니다.
각 문서는 에이전트(예: Claude Code)에게 읽혀서 그대로 실행·검증할 수 있도록
작성되어 있습니다. 셸 스크립트 대신 문서 방식으로 관리합니다.

> 사용법 — 새 머신이나 원격에서 에이전트에게:
> "`~/Developer/dotfiles/docs/<도구>-setup.md` 를 읽고 그대로 셋업해줘."

## 지원 환경

모든 런북은 **macOS** 와 **Linux(Homebrew on Linux)** 공통으로 동작합니다.
Linux는 패키지 설치에 Homebrew를 사용하며, GUI 앱(cask)은 macOS 전용입니다.

## 런북 목록

| 런북 | 도구 | 내용 |
|------|------|------|
| [brew-setup.md](brew-setup.md) | Homebrew | Homebrew 설치 + Brewfile 일괄 설치 (정본 방침 포함) |
| [zsh-setup.md](zsh-setup.md) | zsh / oh-my-zsh | oh-my-zsh + 플러그인 + zoxide/fzf + aliases 심링크 |
| [nvm-setup.md](nvm-setup.md) | nvm / Node.js | nvm 설치 + `.zshrc` init + Node 22 |
| [nvim-setup.md](nvim-setup.md) | Neovim | neovim 설치 + LazyVim 구성 |
| [tmux-setup.md](tmux-setup.md) | tmux | tmux 설치 + `tmux.conf` 심링크 |
| [git-setup.md](git-setup.md) | git | git-delta(pager) + 1Password SSH 서명 + git-lfs |
| [yazi-setup.md](yazi-setup.md) | yazi | 파일 매니저 설치/설정 + 테마(flavor) + zsh 통합 |

## 권장 실행 순서

다른 런북들이 Homebrew 패키지에 의존하므로 **brew를 가장 먼저** 실행합니다.

```
1. brew-setup   # 모든 패키지의 기반
2. zsh-setup    # 셸 환경 (oh-my-zsh, 플러그인, alias)
3. nvm-setup    # Node.js
4. nvim-setup   # LazyVim
5. tmux-setup   # tmux 설정 심링크
6. git-setup    # git delta / 서명 / lfs
7. yazi-setup   # 파일 매니저 (+ EDITOR=nvim 연동)
```

## 공통 원칙 (모든 런북이 지키는 규칙)

- **멱등성**: 각 단계는 적용 여부를 먼저 확인하고, 됐으면 건너뜁니다.
- **백업 우선**: 기존 설정 파일을 덮어쓰기 전에 확인/백업하고, `grep` 가드로
  중복 추가를 막습니다.
- **검증 필수**: 각 섹션 끝의 검증 명령으로 결과를 확인한 뒤 다음으로 넘어갑니다.
