# Claude Code 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** 이 저장소가 관리하는 Claude Code 슬래시 커맨드를
`~/.claude/commands/`에 적용하기 위한 실행 가이드입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/claude-setup.md` 를 읽고 그대로 Claude Code 커맨드를 셋업해줘."

이 저장소는 Claude Code 설정 중 **슬래시 커맨드만** 관리한다(설정 본체는
`claude/commands/*.md`). `settings.json`·`CLAUDE.md`·세션 등 머신/계정에 종속적인
것들은 의도적으로 제외한다. 따라서 셋업은 "전제 확인 → 커맨드 심링크 → 검증"으로 끝난다.

---

## 0. 실행 원칙

- **멱등성**: 심링크는 `ln -sfv`로 항상 같은 결과를 보장한다(이미 있어도 안전).
- **파일별 심링크**: `~/.claude/commands/` 디렉터리를 통째로 갈아끼우지 않고
  `claude/commands/*.md`를 **파일 단위**로 건다. 그래야 이 저장소가 관리하지 않는
  기존 로컬 커맨드와 충돌 없이 공존한다.
- **OS 공통**: 커맨드 경로(`~/.claude/commands/`)는 macOS·Linux 동일하다. (단,
  `install.sh`는 macOS 전용 진입점이라 Linux에서는 아래 명령을 직접 실행한다.)
- **전제**: Claude Code가 이미 설치돼 있고, dotfiles는 `~/Developer/dotfiles`에 있다.

---

## 1. 전제 확인 — Claude Code 설치 여부

```bash
command -v claude && claude --version
```

설치돼 있지 않으면 커맨드 심링크는 걸어둬도 무방하지만, 실제 사용은 Claude Code
설치 후 가능하다(설치는 이 런북 범위 밖).

---

## 2. 커맨드 적용 — `~/.claude/commands/*.md` 심링크

`install.sh`의 심링크 단계에 이미 포함돼 있다. 단독 실행(또는 Linux)은 아래와 같다.

```bash
DOTFILES_DIR="$HOME/Developer/dotfiles"
mkdir -p "$HOME/.claude/commands"
for cmd in "$DOTFILES_DIR"/claude/commands/*.md; do
  [ -e "$cmd" ] || continue
  ln -sfv "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
done
```

새 커맨드 추가 시: `claude/commands/`에 `.md` 파일만 추가하고 위 루프를 다시 돌리면
된다(또는 `install.sh` 재실행). install.sh 수정은 필요 없다.

---

## 3. 검증

심링크가 이 저장소를 가리키는지 확인한다.

```bash
ls -l "$HOME/.claude/commands"/*.md | grep Developer/dotfiles
readlink "$HOME/.claude/commands/monitor-experiment.md"
# .../Developer/dotfiles/claude/commands/monitor-experiment.md 를 가리켜야 함
```

Claude Code 세션을 새로 시작하면 `/monitor-experiment` 가 슬래시 커맨드 목록에
나타나야 한다.

---

## 부록: 현재 관리되는 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/monitor-experiment` | 실험이 끝날 때까지 주기적으로 모니터링하고 중간 결과를 공유하는 `loop` 시작. 인자: `[간격] [대상 설명]` |
| `/cleanup` | 디버그 로그·주석 처리 코드·미사용 import 정리. 인자: `[파일/경로]` |
| `/explain` | 코드 동작을 실행 흐름·사용 예시와 함께 설명. 인자: `[파일/함수/주제]` |
| `/review` | 버그·보안·성능 관점 코드 리뷰. 인자: `[파일/경로]` |
| `/security-review` | 보안 취약점 리뷰. 인자: `[파일/경로]` |

> 커맨드 본문은 영어, frontmatter(`description`/`argument-hint`)도 영어로 통일돼 있다.
> 이 저장소가 **관리하지 않는** 로컬 커맨드를 추가하려면 해당 `.md`를
> `claude/commands/`에 넣고 위 심링크 루프를 다시 돌리면 된다.
