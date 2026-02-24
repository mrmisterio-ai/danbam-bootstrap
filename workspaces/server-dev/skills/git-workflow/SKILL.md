---
name: git-workflow
description: |
  Git 브랜치, 워크트리, 롤백 전략. 안전한 개발 흐름을 위한 필수 스킬.
  새 기능/변경 시 반드시 브랜치를 만들고, main은 항상 안정 상태를 유지한다.
---

# Git Workflow — 브랜치 & 워크트리 & 롤백

## 핵심 원칙
**main 브랜치는 항상 동작하는 상태여야 한다.**
새 기능, 리팩토링, 실험은 반드시 **별도 브랜치**에서 작업한다.

## 브랜치 전략

### 브랜치 생성 (필수)
```bash
# 새 기능
git checkout -b feature/시안-컬러-적용

# 버그 수정
git checkout -b fix/hexboard-border

# 리팩토링
git checkout -b refactor/colors-system

# 실험
git checkout -b experiment/new-animation
```

### 네이밍 컨벤션
- `feature/기능명` — 새 기능
- `fix/버그명` — 버그 수정
- `refactor/대상` — 리팩토링
- `experiment/실험명` — 실험적 변경
- `hotfix/긴급수정` — 프로덕션 긴급 수정

### 작업 흐름
```
1. git checkout -b feature/xxx    ← 브랜치 생성
2. 작업 + 커밋 (여러 번 가능)
3. git checkout main              ← main으로 이동
4. git merge feature/xxx          ← 머지 (또는 PR)
5. 문제 없으면 → git branch -d feature/xxx
6. 문제 있으면 → git revert 또는 git reset
```

## 워크트리 (동시에 여러 브랜치 작업)

### 기본 사용법
```bash
# 워크트리 추가 (별도 디렉토리에 브랜치 체크아웃)
git worktree add ../project-feature feature/xxx

# 워크트리 목록 확인
git worktree list

# 워크트리 제거
git worktree remove ../project-feature
```

### 언제 사용하나?
- main에서 서비스 돌리면서 별도 디렉토리에서 개발할 때
- 두 개 이상의 기능을 동시에 개발할 때
- 빌드 결과물을 보존하면서 다른 브랜치에서 작업할 때

## 롤백 전략

### 방법 1: git revert (안전, 히스토리 유지)
```bash
# 특정 커밋 되돌리기 (새 커밋 생성)
git revert <commit-hash>

# 여러 커밋 되돌리기
git revert <oldest>..<newest>
```

### 방법 2: git reset (강력, 히스토리 삭제)
```bash
# 커밋은 취소하되 변경사항은 유지 (staged)
git reset --soft HEAD~1

# 커밋 + staging 취소, 파일은 유지
git reset --mixed HEAD~1

# 완전히 되돌리기 (변경사항도 삭제) ⚠️ 주의
git reset --hard HEAD~1
```

### 방법 3: 브랜치 버리기 (가장 안전)
```bash
# 브랜치에서 작업했으니 main은 깨끗
git checkout main
git branch -D feature/xxx  # 브랜치 통째로 삭제
```

## 머지 전 체크리스트
- [ ] 빌드 성공 확인 (`npm run build` 또는 `tsc --noEmit`)
- [ ] 테스트 통과 (`npm test`)
- [ ] main과 충돌 없음 (`git merge main --no-commit` 으로 미리 확인)
- [ ] 불필요한 파일 커밋 안 했는지 (`git diff --stat main`)

## 커밋 컨벤션 (기존 유지)
- `feat:` 새 기능
- `fix:` 버그 수정
- `refactor:` 코드 구조 변경
- `style:` 스타일/UI 변경 (기능 변화 없음)
- `docs:` 문서
- `chore:` 유지보수

## ⚠️ 절대 하지 말 것
- main에서 직접 실험적 코드 작성 금지
- `git push --force` on main 금지
- 테스트 안 돌리고 main에 머지 금지
- node_modules 커밋 금지
