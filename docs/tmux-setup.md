# tmux 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** macOS에 tmux를 설치하고 이 저장소의
`tmux.conf`를 적용하기 위한 실행 가이드입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/tmux-setup.md` 를 읽고 그대로 tmux를 셋업해줘."

이 저장소의 tmux 설정(`tmux.conf`)은 **TPM(플러그인 매니저) 없이** 순수 설정만
사용한다. 따라서 셋업은 "설치 → `~/.tmux.conf` 심링크 → 검증"으로 끝난다.

---

## 0. 실행 원칙

- **멱등성**: 심링크는 `ln -sfv`로 항상 같은 결과를 보장한다(이미 있어도 안전).
- **검증 필수**: 마지막에 별도 소켓(`-L`)으로 설정을 로드해 에러가 없는지 확인한다.
- **환경 전제**: macOS 또는 Linux(Homebrew), dotfiles는 `~/Developer/dotfiles`에 클론돼 있다.
  (클립보드는 `tmux.conf`가 `uname`으로 macOS=pbcopy / Linux=xclip을 자동 분기한다.)

---

## 1. 설치

```bash
brew install tmux
```

**검증**

```bash
tmux -V    # tmux 3.x 이상
```

---

## 2. 설정 적용 — `~/.tmux.conf` 심링크

설정 본체는 이 저장소의 `tmux.conf`다. 홈에 심링크만 건다.

```bash
ln -sfv "$HOME/Developer/dotfiles/tmux.conf" "$HOME/.tmux.conf"
```

이미 실행 중인 tmux가 있다면 설정을 다시 읽는다(없으면 생략):

```bash
tmux source-file ~/.tmux.conf 2>/dev/null || true
```

**검증**

```bash
readlink ~/.tmux.conf   # .../Developer/dotfiles/tmux.conf 를 가리켜야 함
```

---

## 3. 설정 로드 검증 (격리)

현재 tmux 세션을 건드리지 않도록 **별도 소켓**(`-L tmuxcheck`)에서 설정을
로드해보고, 문법/명령 에러가 없는지 확인한다.

```bash
tmux -L tmuxcheck -f ~/.tmux.conf new-session -d -s t 2>/tmp/tmux_err
echo "exit=$?"
cat /tmp/tmux_err          # 비어 있어야 정상
tmux -L tmuxcheck kill-server 2>/dev/null
rm -f /tmp/tmux_err
```

`exit=0`이고 stderr가 비어 있으면 성공.

---

## 부록: 이 설정의 핵심 (요점)

전체 내용은 `~/Developer/dotfiles/tmux.conf` 참조. 자주 헷갈리는 부분만:

| 항목 | 설정 |
|------|------|
| Prefix | `C-b` → **`C-a`** 로 변경 (`C-a` 두 번 = 리터럴 C-a 전송) |
| Pane 이동 | `Alt+방향키` (prefix 없이) |
| Pane 분할 | `prefix \|` 수평 / `prefix -` 수직 (현재 경로 유지) |
| 새 창 | `prefix c` (현재 경로 유지) |
| 창 번호 | 1부터 시작, 닫으면 자동 재정렬 |
| 마우스 | 켜짐 / `prefix C-c` = 버퍼를 pbcopy로 복사 |
| 카피모드 | vi 키 (`v` 선택 시작, `y` 복사→pbcopy) |
| 기타 | true color, ESC 지연 0, 스크롤백 50000, 상태바 상단 |

> TPM 플러그인을 도입하려면: `tmux.conf`에 `set -g @plugin '...'`와 TPM 부트스트랩을
> 추가하고 `~/.tmux/plugins/tpm`를 클론해야 한다(현재는 사용 안 함).
