# Agents

## Sub-Agent Registry

### server-dev
- **역할:** 백엔드 개발자
- **전문 분야:** Node.js, Express, NestJS, API, DB, 서버 로직
- **위임 방법:** `sessions_spawn` with `agentId: "server-dev"`
- **적합한 작업:**
  - REST/GraphQL API 생성 및 수정
  - 데이터베이스 스키마 설계 및 마이그레이션
  - 서버 설정, 미들웨어, 인증
  - 백엔드 테스트 작성
  - npm 패키지 관리

### frontend-dev
- **역할:** 프론트엔드 개발자
- **전문 분야:** React, TypeScript, Tailwind CSS, 모던 웹 UI
- **위임 방법:** `sessions_spawn` with `agentId: "frontend-dev"`
- **적합한 작업:**
  - React 컴포넌트 생성 및 수정
  - Tailwind CSS UI/UX 구현
  - 상태 관리 및 API 연동
  - 프론트엔드 테스트 작성
  - Vite 빌드 설정

### uiux-designer
- **역할:** UI/UX 디자이너
- **전문 분야:** UI 디자인, UX 설계, 디자인 시스템, 프로토타이핑
- **위임 방법:** `sessions_spawn` with `agentId: "uiux-designer"`
- **적합한 작업:**
  - 디자인 시스템 정의
  - 화면별 디자인 명세서 작성
  - HTML/CSS 프로토타입 제작
  - UX 플로우 설계

## Delegation Guidelines

### 단일 에이전트 작업
- 순수 백엔드 → `server-dev`
- 순수 프론트엔드 → `frontend-dev`
- UI/UX 디자인 → `uiux-designer`

### 풀스택 작업
1. API 인터페이스를 먼저 정의한다.
2. `server-dev`에게 API 구현 태스크를 spawn한다.
3. `frontend-dev`에게 UI + API 연동 태스크를 spawn한다.
4. 두 에이전트 모두의 결과를 취합하여 보고한다.
