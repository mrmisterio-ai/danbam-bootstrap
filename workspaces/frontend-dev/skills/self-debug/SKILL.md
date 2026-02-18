---
name: self-debug
description: |
  실행 및 디버깅 자동화 스킬.
  코드 작성 후 스스로 빌드/실행하여 에러를 잡는 Self-Correction Loop.
  모든 코드 작업 완료 시 반드시 이 프로세스를 거칠 것.
---

# Self-Debug — 실행 및 디버깅 스킬

## 핵심 원칙
**코드를 짠다 → 빌드한다 → 에러를 잡는다 → 고친다**
"실행이 안 되는데요?"를 듣기 전에 스스로 잡는다.

## 필수 디버깅 루프 (모든 작업 완료 시)

### Step 1: TypeScript 타입 체크
```bash
cd /home/ubuntu/projects/tft-agent-frontend
npx tsc --noEmit 2>&1
```
- 에러 0이면 통과
- 에러 있으면 **전부 수정** 후 재실행

### Step 2: 빌드 테스트
```bash
# Expo Web 빌드
npx expo export --platform web 2>&1
```
- 빌드 성공이면 통과
- 에러 시 로그 분석 → 수정 → 재빌드

### Step 3: Metro Bundler 에러 로그 분석
빌드/실행 시 에러가 나면 로그에서 핵심 정보 추출:
```
패턴 분석:
- "Unable to resolve module" → import 경로 오류 또는 패키지 미설치
- "Cannot find module" → 패키지 설치 필요 (npm install)
- "Type error" → TypeScript 타입 불일치
- "SyntaxError" → 문법 오류 (보통 JSX/TSX)
- "EMFILE" → 파일 핸들 한도 → watchman 재시작
```

### Step 4: 패키지 의존성 확인
```bash
# 누락된 패키지 확인
npm ls --depth=0 2>&1 | grep -E "MISSING|ERR"

# 필요하면 설치
npm install <패키지명>
```

## 에러 자동 수정 패턴

| 에러 패턴 | 원인 | 자동 수정 |
|-----------|------|----------|
| `Cannot find module 'X'` | 패키지 미설치 | `npm install X` |
| `Module not found: './X'` | import 경로 오류 | 실제 파일 경로 확인 후 수정 |
| `Type 'X' is not assignable to type 'Y'` | 타입 불일치 | 타입 정의 수정 |
| `Property 'X' does not exist on type 'Y'` | 필드명 오류 | API 응답 또는 타입 확인 |
| `Unexpected token` | 문법 오류 | JSX/TSX 문법 수정 |
| `Hook "useX" is called conditionally` | Hook 규칙 위반 | Hook을 컴포넌트 최상위로 이동 |

## 최대 반복: 3회
- 3회 수정 후에도 빌드 실패하면 매니저에게 보고
- 보고 시 포함: 에러 메시지, 시도한 수정, 추정 원인

## ⚠️ 절대 규칙
- 빌드 실패 상태로 커밋하지 않는다
- `any` 타입으로 에러를 피하지 않는다 (올바른 타입 정의)
- 에러를 `@ts-ignore`로 무시하지 않는다
