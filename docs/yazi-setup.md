# Yazi + zsh 셋업 런북 (에이전트용)

이 문서는 **에이전트(예: Claude Code)에게 시켜서** macOS에 yazi 파일 매니저와
관련 zsh 설정을 재현하기 위한 실행 가이드입니다.
사람이 직접 따라 해도 되지만, 각 단계는 에이전트가 순서대로 실행하고
**검증**할 수 있도록 작성되어 있습니다.

> 에이전트에게 줄 한 줄 지시 예시
> "`~/Developer/dotfiles/docs/yazi-setup.md` 를 읽고 그대로 yazi를 셋업해줘."

---

## 0. 실행 원칙 (에이전트가 반드시 지킬 것)

- **멱등성**: 각 단계는 실행 전에 "이미 적용됐는지" 먼저 확인하고, 됐으면 건너뛴다.
- **백업 우선**: 기존 파일(`~/.zshrc` 등)을 수정하기 전에 내용을 확인하고, 같은 줄을
  중복 추가하지 않는다(`grep` 가드 사용).
- **검증 필수**: 각 섹션 끝의 "검증" 명령을 실행해 결과를 확인한 뒤 다음으로 넘어간다.
- **환경 전제**: macOS 또는 Linux(Homebrew on Linux), 셸은 zsh. 설정은 XDG 기본
  경로 `~/.config/yazi/` 를 사용한다. brew 명령은 두 OS에서 동일하다.

---

## 1. 의존성 설치 (Homebrew)

yazi 본체와 미리보기/탐색용 외부 도구를 설치한다.

```bash
# 본체
brew install yazi

# 탐색/검색 (대부분 이미 깔려 있을 수 있음)
brew install fd ripgrep fzf zoxide jq

# 미리보기용
brew install sevenzip poppler ffmpeg imagemagick resvg chafa
```

| 도구 | 역할 |
|------|------|
| `yazi` / `ya` | 파일 매니저 본체 + 패키지 CLI |
| `fd` | 이름 검색(`s`) |
| `ripgrep` | 내용 검색(`S`) |
| `fzf` | 파일 점프(`z`) |
| `zoxide` | 디렉토리 점프(`Z`) |
| `jq` | 일부 플러그인/미리보기 |
| `sevenzip`(`7zz`) | 압축파일 미리보기 |
| `poppler`(`pdftoppm`) | PDF 미리보기 |
| `ffmpeg` | 비디오 썸네일 |
| `imagemagick`(`magick`) | 다양한 이미지 포맷 |
| `resvg` | SVG 렌더링 |
| `chafa` | 이미지 폴백 렌더러 (tmux/SSH에서 안정적) |

> Brewfile로 재현하고 싶다면 위 패키지들을 `Brewfile`에도 추가하고
> `brew bundle --file=Brewfile` 로 한 번에 설치할 수 있다.

**검증**

```bash
for t in yazi ya fd rg fzf zoxide jq 7zz pdftoppm ffmpeg magick resvg chafa; do
  printf "%-10s " "$t"; command -v "$t" >/dev/null 2>&1 && echo OK || echo MISSING
done
```

`7z`는 없어도 무방하다(`sevenzip`은 `7zz` 바이너리를 제공하며 yazi가 이를 인식).

---

## 2. yazi 메인 설정 — `~/.config/yazi/yazi.toml`

설정 디렉토리를 만들고 아래 내용으로 `yazi.toml`을 생성한다.
(여기 적은 키만 기본값을 덮어쓰고, 나머지는 yazi 내장 기본값을 사용한다.)

```bash
mkdir -p ~/.config/yazi
```

```toml
# ~/.config/yazi/yazi.toml
# 스키마: https://yazi-rs.github.io/docs/configuration/yazi
# 최신 버전은 메인 테이블 이름이 [manager]가 아니라 [mgr] 임에 주의.

[mgr]
show_hidden    = false      # 숨김 파일 표시 여부 — 실행 중 `.` 키로 토글 가능
sort_by        = "natural"  # 사람이 읽는 순서 (file2 < file10)
sort_sensitive = false      # 정렬 시 대소문자 구분 안 함
sort_reverse   = false
sort_dir_first = true       # 디렉토리를 위에 모아서 표시
linemode       = "size"     # 파일명 옆 부가 정보: none|size|btime|mtime|permissions|owner
show_symlink   = true       # 심볼릭 링크의 대상 경로 표시
scrolloff      = 5          # 커서 위/아래 최소 여백 줄 수

[preview]
wrap          = "no"
tab_size      = 2
max_width     = 1000
max_height    = 1000
image_filter  = "lanczos3"  # 고품질 다운스케일
image_quality = 90          # 미리보기 캐시 품질 (50~90)
```

> 숨김 파일을 항상 보이게 하려면 `show_hidden = true` 로 바꾼다.
> 어느 값이든 실행 중 `.` 키로 즉석 토글 가능.

**검증**

```bash
python3 -c "import tomllib; tomllib.load(open('$HOME/.config/yazi/yazi.toml','rb')); print('yazi.toml OK')"
```

---

## 3. 테마(flavor) 설치 — `~/.config/yazi/theme.toml`

yazi의 테마는 "flavor"라고 부르며 `ya pkg`로 관리한다.
여기서는 공식 저장소의 **Catppuccin Latte (라이트)** 를 설치한다.

```bash
ya pkg add yazi-rs/flavors:catppuccin-latte
```

설치되면 `~/.config/yazi/flavors/catppuccin-latte.yazi/`에 배포되고
`~/.config/yazi/package.toml`에 버전/해시가 기록된다.

그다음 `theme.toml`을 아래 내용으로 생성한다.
시스템 다크/라이트 모드와 무관하게 **항상 Latte**로 고정하려고 양쪽 키를 같게 둔다.

```toml
# ~/.config/yazi/theme.toml
# 주의: 이 파일에는 [flavor] 외의 내용을 넣지 않는 것이 좋다(스타일 충돌 방지).
[flavor]
dark  = "catppuccin-latte"
light = "catppuccin-latte"
```

> 다른 테마로 바꾸려면: `ya pkg add yazi-rs/flavors:catppuccin-mocha` 처럼 추가하고
> `theme.toml`의 이름만 교체한다. 공식 4종: `catppuccin-latte/frappe/macchiato/mocha`.
> 설치 목록은 `ya pkg list`, 일괄 업데이트는 `ya pkg upgrade`.

**검증**

```bash
ya pkg list
ls ~/.config/yazi/flavors/catppuccin-latte.yazi/flavor.toml
```

---

## 4. zsh 통합 — `~/.zshrc`

두 가지를 `~/.zshrc`에 추가한다. **이미 있으면 추가하지 않는다.**

### 4-1. `y()` 래퍼 함수 (종료 시 디렉토리 따라가기)

yazi를 `y`로 실행하면 종료 시 머물던 디렉토리로 셸이 자동 `cd` 된다.
(`q` = cd 하며 종료 / `Q` = cd 없이 종료)

멱등 추가:

```bash
grep -q 'function y()' ~/.zshrc || cat >> ~/.zshrc <<'EOF'

# ---- Yazi (파일 매니저) ----
# `y`로 실행하면 Yazi 종료 시 마지막으로 머문 디렉토리로 셸이 자동 cd 됩니다.
#   q  -> 현재 디렉토리로 이동하며 종료   |   Q -> 디렉토리 변경 없이 종료
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
EOF
```

### 4-2. 기본 에디터를 nvim으로

yazi에서 파일에 `Enter` 시, git 커밋 메시지 등에서 쓰는 `$EDITOR`를 nvim으로 지정한다.
(yazi 기본 opener는 `${EDITOR:-vi}` 규칙. EDITOR 미설정 시 `vi`(=system vim)가 열린다.)

멱등 추가:

```bash
# 주석(# export EDITOR=...)이 아니라 '활성' 라인만 매치해야 한다.
grep -qE '^[[:space:]]*export EDITOR=' ~/.zshrc || echo "export EDITOR='nvim'" >> ~/.zshrc
```

> 셸 alias `vim=nvim`은 yazi opener에 적용되지 않는다(비대화형 직접 실행이라 alias를
> 거치지 않음). 그래서 nvim을 쓰려면 반드시 `EDITOR`를 설정해야 한다.

**검증**

```bash
zsh -n ~/.zshrc && echo "zshrc 문법 OK"
zsh -ic 'typeset -f y >/dev/null && echo "y() 정의됨"; echo "EDITOR=$EDITOR"'
```

적용: 새 터미널을 열거나 `source ~/.zshrc`. 그 뒤 `y`로 실행.
(주의: `EDITOR`는 yazi를 띄우기 **전** 셸에 export 돼 있어야 반영된다.)

---

## 5. 통합 검증 — yazi가 설정/테마를 패닉 없이 로드하는지

TUI라 비대화형 검증이 까다로우므로, 격리된 tmux 세션에서 yazi를 띄웠다가
`q`로 종료시키고 **종료 코드 0** 과 stderr를 확인한다.

```bash
tmux kill-session -t yzcheck 2>/dev/null; rm -f /tmp/yz_err /tmp/yz_exit
tmux new-session -d -s yzcheck -x 200 -y 50 'yazi 2>/tmp/yz_err; echo "EXIT=$?" >/tmp/yz_exit'
# 잠시 로딩을 기다린 뒤 (에이전트는 다음 명령을 별도 단계로 실행)
tmux send-keys -t yzcheck q
tmux kill-session -t yzcheck 2>/dev/null
cat /tmp/yz_exit            # EXIT=0 이어야 함
sed 's/\x1b\[[0-9;]*m//g' /tmp/yz_err   # 설정/테마 관련 에러가 없어야 함
rm -f /tmp/yz_err /tmp/yz_exit
```

- `EXIT=0` 이고 stderr에 설정 파싱/flavor 에러가 없으면 성공.
- stderr의 `Terminal response timeout (TRT)` 경고는 **무시해도 된다**(아래 6 참고).

---

## 6. 트러블슈팅 — tmux에서 `Terminal response timeout (TRT)`

tmux 안에서 yazi 실행 시 다음 경고가 보일 수 있다:

```
Terminal response timeout: The request sent by Yazi didn't receive a correct response.
https://yazi-rs.github.io/docs/faq#trt
```

- 원인: tmux가 터미널 능력 질의/이미지 프로토콜 패스스루를 막아서 발생. **설정 오류가 아니다.**
- 영향: 기능에는 지장 없음. 이미지 미리보기는 `chafa` 폴백으로 블록 문자로 표시된다.
- 고해상도 인라인 이미지까지 원하면(iTerm2/WezTerm/Kitty/Ghostty 등) tmux에
  `set -g allow-passthrough on` 등을 추가해야 한다(선택).

---

## 부록: 자주 쓰는 키맵 (yazi 26.x 기본)

실행 중 `~` 키로 전체 도움말을 볼 수 있다.

| 분류 | 키 | 동작 |
|------|----|------|
| 이동 | `j`/`k`, `h`/`l` | 위아래 / 상위·하위 폴더 |
| 이동 | `gg`/`G` | 맨 위 / 맨 아래 |
| 이동 | `H`/`L` | 방문기록 이전 / 다음 디렉토리 |
| 열기 | `Enter`/`o` | 열기 (폴더=진입, 파일=opener→nvim) |
| 열기 | `O` | 열기 방식 직접 선택 |
| 셸 | `;` / `:` | 셸 명령 (비차단 / 완료대기) |
| 선택 | `Space`, `v`/`V` | 토글, 비주얼 선택 |
| 선택 | `<C-a>`/`<C-r>` | 전체 선택 / 반전 |
| 파일 | `y`/`x`/`p` | 복사 / 잘라내기 / 붙여넣기 |
| 파일 | `d`/`D` | 휴지통 / 영구 삭제 |
| 파일 | `a`/`r` | 생성(`/`=폴더) / 이름 변경 |
| 검색 | `s`/`S` | 이름검색(fd) / 내용검색(rg) |
| 검색 | `f`, `/` `n` `N` | 필터 / 찾기·반복 |
| 점프 | `z`/`Z` | fzf / zoxide |
| 표시 | `.` | 숨김 파일 토글 |
| 탭 | `tt`, `1`~`9`, `[`/`]` | 생성 / 전환 / 이전·다음 |
| 종료 | `q`/`Q` | 종료(cd 반영) / 종료(cd 안 함) |
| 종료 | `Esc` | 선택·검색·비주얼모드 해제 |
