# git 셋업 런북 (에이전트용)

이 문서는 **에이전트에게 시켜서** macOS에서 git을 설치하고 delta(pager),
1Password SSH 커밋 서명, git-lfs를 구성하기 위한 실행 가이드입니다.

> 에이전트 지시 예시
> "`~/Developer/dotfiles/docs/git-setup.md` 를 읽고 그대로 git을 셋업해줘."

---

## 0. 실행 원칙

- **멱등성**: `git config --global`은 같은 키를 덮어쓰므로 반복 실행해도 안전하다.
- **개인 값 주의**: 사용자 이름/이메일/서명키는 **본인 환경 값**으로 채운다(아래 1-2).
- **검증 필수**: 마지막에 설정값을 다시 읽어 확인한다.
- **환경 전제**: macOS + Homebrew.

---

## 1. 설치

```bash
brew install git git-delta git-lfs
```

| 도구 | 역할 |
|------|------|
| `git` | 본체 (Apple 기본 git 대신 최신 버전) |
| `git-delta`(`delta`) | diff/pager를 보기 좋게 (side-by-side, 구문 강조) |
| `git-lfs` | 대용량 파일 추적 |

---

## 2. 사용자 정보 & 커밋 서명

### 2-1. 사용자

```bash
git config --global user.name  "Seunghyuk Oh"
git config --global user.email "seunghyukoh@furiosa.ai"
git config --global init.defaultBranch main
```

### 2-2. 1Password SSH 키로 커밋 서명

이 환경은 GPG 대신 **SSH 키 서명**을 쓰고, 서명 도구로 1Password의
`op-ssh-sign`을 사용한다. (1Password 데스크톱 앱 + SSH 에이전트가 설정돼 있어야 함)

```bash
git config --global gpg.format ssh
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
git config --global commit.gpgsign true
# 서명에 쓸 공개키 (본인 키로 교체)
git config --global user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTCfJ+OMZtgnidWkTNKhGxRMMgXat5Wn/JEXtuF9nEV"
```

> 1Password를 쓰지 않는 머신이라면 이 블록은 건너뛰고 `commit.gpgsign`을
> 설정하지 않는다(서명 없는 커밋).

---

## 3. delta(pager) 설정

```bash
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global merge.conflictstyle zdiff3
```

| 키 | 효과 |
|----|------|
| `core.pager=delta` | `git diff`/`git show`/`git log -p`를 delta로 렌더 |
| `interactive.diffFilter` | `git add -p` 등 인터랙티브 diff도 delta로 |
| `delta.navigate` | `n`/`N`으로 파일 간 이동 |
| `delta.side-by-side` | 좌우 2단 비교 |
| `merge.conflictstyle=zdiff3` | 충돌 표시에 공통 조상 포함(해결 쉬움) |

---

## 4. git-lfs 초기화

```bash
git lfs install
```

이러면 전역 `~/.gitconfig`에 lfs filter(`clean`/`smudge`/`process`, `required=true`)가 등록된다.

---

## 5. 검증

```bash
delta --version
echo "--- 적용된 설정 ---"
git config --global --get-regexp '^(core|delta|interactive|merge|gpg|commit|init)\.' 
echo "--- 서명 동작 테스트(선택) ---"
# 임시 저장소에서 서명 커밋이 되는지 확인하고 싶다면:
# tmp=$(mktemp -d); git -C "$tmp" init -q; : > "$tmp/f"; git -C "$tmp" add f; \
#   git -C "$tmp" commit -qm test && git -C "$tmp" log --show-signature -1; rm -rf "$tmp"
```

`core.pager delta`, `delta.side-by-side true` 등이 보이면 정상.

> 전체 참조 설정은 `~/.gitconfig`에 있다. 이 런북은 그 내용을 재현하는 절차다.
