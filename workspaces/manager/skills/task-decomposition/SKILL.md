---
name: task-decomposition
description: |
  기능을 WBS(작업 분해 구조)로 쪼개고, 에이전트별 태스크를 구조화된 형식으로 생성.
  spawn 시 명확한 인터페이스(JSON 형태 AC 포함)로 전달하여 해석 오류를 방지.
---

# Task Decomposition — 작업 분해 및 위임

## 핵심 원칙
**"애매하게 시키면 애매하게 만든다."**
기능 하나를 받으면 → WBS로 쪼개고 → 에이전트별 태스크로 분리 → AC(인수 조건) 포함하여 위임.

## 프로세스

### Step 1: 기능 분석
사장님의 요청을 받으면 3가지를 파악:
- **무엇을**: 기능의 정확한 범위
- **누가**: 어떤 에이전트가 필요한지 (백엔드? 프론트? 디자인? 복수?)
- **어떤 순서로**: 의존성 파악 (백엔드 먼저? 동시 가능?)

### Step 2: WBS 작성
기능을 최소 작업 단위로 분해:

```markdown
## Feature: 아이템 기반 추천

### Backend (승권이)
- [ ] POST /api/recommend/by-items 엔드포인트 구현
- [ ] 아이템 조합 매칭 로직 작성
- [ ] 응답 DTO 정의 (RecommendResult)

### Frontend (현이)
- [ ] 아이템 선택 UI 구현
- [ ] 추천 결과 화면 구현
- [ ] API 연동 (React Query)

### Design (토니)
- [ ] 아이템 선택 화면 디자인
- [ ] 추천 결과 화면 디자인
```

### Step 3: 태스크 구조화
각 에이전트에게 보내는 spawn 태스크에 반드시 포함할 항목:

```markdown
## 태스크 템플릿

### 1. 목표 (What)
[한 문장으로 명확하게]

### 2. 컨텍스트 (Context)
- 관련 파일: [경로]
- 참고 디자인: [URL]
- 선행 작업: [완료된 것/의존하는 것]

### 3. API 계약 (Interface) — 풀스택 작업 시 필수
```json
{
  "endpoint": "POST /api/recommend/by-items",
  "request": {
    "items": ["BFSword", "NeedlesslyLargeRod"]
  },
  "response": {
    "success": true,
    "data": [
      {
        "compId": "comp_001",
        "compName": "Watcher Kalista",
        "matchingItems": ["Guinsoos Rageblade"],
        "score": 0.95
      }
    ]
  }
}
```

### 4. 인수 조건 (Acceptance Criteria)
- [ ] AC1: API가 200을 반환하고 data 배열에 1개 이상의 추천 결과
- [ ] AC2: 잘못된 아이템명 시 400 에러 반환
- [ ] AC3: 빈 items 배열 시 400 에러 반환
- [ ] AC4: 빌드 성공 (tsc --noEmit 또는 npm run build 에러 없음)

### 5. 제약사항 (Constraints)
- 기존 API 응답 형식 깨지면 안 됨
- .env에 하드코딩 금지
- [기타 프로젝트 특화 제약]
```

### Step 4: TODO 등록
대시보드 TODO API에 자동 등록:
```bash
curl -s -X POST http://3.37.8.223:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "[BE] POST /api/recommend/by-items 구현",
    "projectId": "52c3b136-e671-4331-8cd0-4a4a2bce06be",
    "priority": "high"
  }'
```

### Step 5: spawn
```
sessions_spawn({
  task: "[위 템플릿 내용]",
  agentId: "server-dev",
  label: "recommend-by-items-api"
})
```

## 의존성 판단 기준

### 동시 진행 가능 (Parallel)
- API 계약이 명확하게 정의된 경우
- 프론트가 Mock 데이터로 작업 가능한 경우
- 디자인과 백엔드가 서로 독립적인 경우

### 순차 진행 필수 (Sequential)
- API 응답 형식이 아직 미정 → 백엔드 먼저
- 디자인 시안이 없음 → 디자인 먼저
- 기존 코드를 수정하는 작업 → 한 명만

## ⚠️ 이서의 실수 기록 — 반복 금지
- 필드명 불일치 (`thisWeek` vs `week`) → API 계약에 JSON 예시 필수
- `coreChampions`를 string 배열로 전달 → 정확한 타입 명시
- 동시 작업 시 충돌 → 같은 파일 수정하는 작업은 순차로
