# Neovim (LazyVim) 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** Neovim을 설치하고 **LazyVim** 구성을 적용하기
위한 실행 가이드입니다. **macOS와 Linux(Homebrew) 공통**입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/nvim-setup.md` 를 읽고 LazyVim을 셋업해줘."

전제: Homebrew가 설치돼 있다(→ `brew-setup.md`).

---

## 0. 실행 원칙

- **백업 우선**: 기존 nvim 설정/데이터가 있으면 **반드시 백업**한 뒤 진행한다(2번).
- **멱등성**: 이미 LazyVim이 설치돼 있으면(아래 확인) 재설치하지 않는다.
- **검증 필수**: 헤드리스 동기화와 `:LazyHealth`로 확인한다.

---

## 1. Neovim 및 권장 도구 설치

```bash
brew install neovim
# LazyVim 권장 외부 도구 (대부분 이미 설치돼 있음)
brew install ripgrep fd lazygit git curl
```

- **Nerd Font** 필요(아이콘 표시). macOS는 `font-meslo-lg-nerd-font`(cask)가 이미
  설치돼 있고, 터미널 폰트를 MesloLGS Nerd Font로 지정한다. Linux는 폰트를 수동
  설치하고 터미널에서 지정한다.
- Neovim은 **0.9+ 권장**(Homebrew 최신이면 충족).

---

## 2. 기존 설정 백업 (있을 때만)

LazyVim starter를 깔기 전에 충돌을 피하려고 기존 nvim 관련 디렉토리를 백업한다.

```bash
for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  [ -e "$d" ] && mv "$d" "${d}.bak" && echo "backed up: $d -> ${d}.bak"
done
```

> 이미 LazyVim을 쓰고 있다면(`~/.config/nvim/lua/config/lazy.lua` 존재) 이 단계와
> 3번을 건너뛰고 4번 검증만 수행한다.

---

## 3. LazyVim starter 설치

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

> `.git`을 지우는 이유: 이 nvim 설정을 본인 dotfiles로 따로 관리하기 위함.
> (원한다면 `~/.config/nvim`을 별도 저장소로 만들어 커밋해도 된다.)

---

## 4. 플러그인 설치 & 검증

첫 실행 시 플러그인이 자동 설치된다. 헤드리스로 동기화한 뒤 헬스 체크한다.

```bash
nvim --headless "+Lazy! sync" +qa
echo "Lazy sync 완료 (exit=$?)"
nvim --version | head -1
# 대화형으로 nvim을 열어 ':LazyHealth' 실행 시 각 플러그인 상태를 점검할 수 있다.
```

`exit=0`이고 `~/.config/nvim/lazy-lock.json`이 생성됐으면 정상.

```bash
ls ~/.config/nvim/lazy-lock.json && echo "LazyVim 설치 확인"
```

---

## 5. 기본 에디터 연동

yazi/git 등에서 nvim을 쓰도록 `~/.zshrc`에 `EDITOR`를 지정한다(이미 있으면 스킵).
(자세한 내용은 `yazi-setup.md` 4-2 참고)

```bash
grep -qE '^[[:space:]]*export EDITOR=' ~/.zshrc || echo "export EDITOR='nvim'" >> ~/.zshrc
```

---

## 부록: 자주 쓰는 LazyVim 기본키

리더키는 `Space`. 실행 후 `Space`를 누르면 which-key 메뉴가 뜬다.

| 키 | 동작 |
|----|------|
| `Space Space` | 파일 찾기(루트) |
| `Space /` | 프로젝트 전체 grep |
| `Space e` | 파일 탐색기(neo-tree) 토글 |
| `Space ,` | 열린 버퍼 전환 |
| `Space gg` | lazygit |
| `Space l` | Lazy 플러그인 매니저 |
| `Space cf` | 코드 포맷 |
| `Space bd` | 버퍼 닫기 |
| `<C-h/j/k/l>` | 창(split) 이동 |

> 커스터마이징: `~/.config/nvim/lua/config/`(옵션·키맵·자동명령),
> `~/.config/nvim/lua/plugins/`(플러그인 추가/오버라이드).
