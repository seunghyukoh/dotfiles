# Ghostty 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** macOS에 Ghostty(GPU 가속 터미널)를 설치하고
이 저장소의 `ghostty/config`를 적용하기 위한 실행 가이드입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/ghostty-setup.md` 를 읽고 그대로 Ghostty를 셋업해줘."

이 저장소의 Ghostty 설정(`ghostty/config`)은 외부 플러그인 없이 순수 설정만
사용한다. 따라서 셋업은 "설치 → `~/.config/ghostty/config` 심링크 → 검증"으로 끝난다.

---

## 0. 실행 원칙

- **멱등성**: 심링크는 `ln -sfv`로 항상 같은 결과를 보장한다(이미 있어도 안전).
- **백업 우선**: 기존 설정이 일반 파일이면 덮어쓰기 전에 백업한 뒤 심링크로 교체한다.
- **검증 필수**: 마지막에 `ghostty +show-config`로 파싱 에러가 없는지 확인한다.
- **환경 전제**: macOS(Homebrew), dotfiles는 `~/Developer/dotfiles`에 클론돼 있다.
  Ghostty는 GUI 앱(cask)이라 이 런북은 **macOS 전용**이다. (Linux는 별도 설치 경로를
  쓰지만 설정 파일 위치 `~/.config/ghostty/config`와 심링크 방식은 동일하다.)

---

## 1. 설치

Brewfile에 `cask "ghostty"`가 포함돼 있어 `brew-setup`을 거쳤다면 이미 설치돼 있다.
단독 설치는 아래와 같다(멱등: 이미 있으면 건너뜀).

```bash
brew list --cask ghostty >/dev/null 2>&1 || brew install --cask ghostty
```

**검증**

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty --version   # 1.x 이상
```

---

## 2. 설정 적용 — `~/.config/ghostty/config` 심링크

설정 본체는 이 저장소의 `ghostty/config`다. 대상 디렉터리를 만든 뒤 심링크만 건다.

```bash
mkdir -p "$HOME/.config/ghostty"

# 기존 설정이 "일반 파일"이면(=심링크 아님) 백업 후 교체
target="$HOME/.config/ghostty/config"
if [ -f "$target" ] && [ ! -L "$target" ]; then
  cp "$target" "$target.bak"
  echo "기존 설정 백업: $target.bak"
fi

ln -sfv "$HOME/Developer/dotfiles/ghostty/config" "$target"
```

**검증**

```bash
readlink ~/.config/ghostty/config   # .../Developer/dotfiles/ghostty/config 를 가리켜야 함
```

설정 변경 후 적용: 실행 중인 Ghostty에서 **`Cmd+Shift+,`**(Reload Config) 또는 재실행.

---

## 3. 설정 로드 검증 (파싱)

설정 파일에 문법/키 에러가 없는지 `+show-config`로 확인한다(현재 창에 영향 없음).

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config >/dev/null 2>/tmp/ghostty_err
echo "exit=$?"
cat /tmp/ghostty_err          # 비어 있어야 정상
rm -f /tmp/ghostty_err
```

`exit=0`이고 stderr가 비어 있으면 성공. 적용된 `theme` 값만 확인하려면:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config | grep -i '^theme'
```

---

## 부록: 이 설정의 핵심 (요점)

전체 내용은 `~/Developer/dotfiles/ghostty/config` 참조. 자주 헷갈리는 부분만:

| 항목 | 설정 |
|------|------|
| 폰트 | `MesloLGM Nerd Font Mono` 14pt + 한글 폴백 `D2Coding`, 셀 높이 +10% |
| 테마 | `Monokai Pro Light Sun` (라이트). 변종/자동전환은 config 주석 참조 |
| 창 | 여백 12px, 종료 상태 복원(`window-save-state = always`), 네이티브 탭 UI |
| 커서 | block, 깜빡임 없음, 타이핑 중 마우스 포인터 숨김 |
| 키 | `macos-option-as-alt = true` (tmux/zsh/nvim의 Alt 단축키용) |
| 클립보드 | `copy-on-select` (선택만 해도 복사) |
| 셸 통합 | `detect` (cwd 추적·점프·커서 모양) |
| Quick terminal | `Cmd+Ctrl+Space` 전역 토글 |

> 미리보기 도구: 테마 `ghostty +list-themes`, 폰트 `ghostty +list-fonts`,
> 전체 옵션 `ghostty +show-config --default --docs` 또는 <https://ghostty.org/docs/config>.
