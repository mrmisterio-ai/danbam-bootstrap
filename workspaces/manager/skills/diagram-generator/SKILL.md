---
name: diagram-generator
description: |
  Mermaid.js 다이어그램 생성 스킬.
  유저 플로우, 시퀀스 다이어그램, ERD, 아키텍처 도를 텍스트로 생성.
  노션/GitHub/마크다운에서 깨지지 않는 시각 자료 제작.
  기획서, 위임 태스크, 리서치 문서에 포함하여 에이전트/사장님에게 전달.
---

# Diagram Generator — Mermaid.js 다이어그램

## 핵심 원칙
**"글로 설명하면 3분, 그림으로 보여주면 3초."**
기획서, 위임 태스크, 아키텍처 설명에 Mermaid 다이어그램을 포함한다.

## 왜 Mermaid인가
- **텍스트 기반** → LLM이 생성/수정 가능
- **노션 지원** → `/mermaid` 블록으로 바로 렌더링
- **GitHub 지원** → `.md` 파일에서 자동 렌더링
- **버전 관리** → Git diff로 변경 추적 가능
- **깨지지 않음** → 이미지와 달리 해상도/크기 문제 없음

## 다이어그램 유형별 템플릿

### 1. 유저 플로우 (User Flow) — 가장 자주 사용

기능 기획 시 사용자가 어떤 경로로 이동하는지 시각화.

```mermaid
flowchart TD
    A[앱 실행] --> B{첫 방문?}
    B -->|Yes| C[스플래시 → 온보딩]
    B -->|No| D[홈 화면]
    C --> D
    D --> E[메타 조합 탭]
    D --> F[AI 추천 탭]
    D --> G[즐겨찾기 탭]
    D --> H[설정 탭]
    E --> I[조합 상세]
    F --> J[아이템 선택]
    J --> K[추천 결과]
    K --> I
    I --> L{즐겨찾기 추가?}
    L -->|Yes| G
    L -->|No| M[뒤로가기]
```

### 2. 시퀀스 다이어그램 (Sequence) — API 흐름

프론트↔백엔드 API 호출 순서 시각화. 풀스택 작업 위임 시 필수.

```mermaid
sequenceDiagram
    participant U as 사용자
    participant F as 프론트엔드
    participant B as 백엔드 API
    participant R as Riot API
    participant S as S3 Cache

    U->>F: 메타 조합 탭 클릭
    F->>B: GET /api/meta/comps
    B->>S: 캐시 확인
    alt 캐시 있음
        S-->>B: 캐시 데이터
    else 캐시 없음
        B->>R: 매치 데이터 요청
        R-->>B: 원본 데이터
        B->>S: 캐시 저장
    end
    B-->>F: 메타 조합 목록
    F-->>U: 화면 렌더링
```

### 3. ERD (Entity-Relationship) — 데이터 구조

DB 설계, 데이터 모델 설명 시 사용.

```mermaid
erDiagram
    COMP {
        string id PK
        string name
        string nameKo
        string tier
        float avgPlacement
        float top4Rate
        float winRate
    }
    CHAMPION {
        string id PK
        string name
        string nameKo
        int cost
        string apiName
    }
    TRAIT {
        string id PK
        string name
        string nameKo
    }
    ITEM {
        string id PK
        string name
        string apiName
    }
    COMP ||--o{ COMP_CHAMPION : contains
    CHAMPION ||--o{ COMP_CHAMPION : belongs
    COMP ||--o{ COMP_TRAIT : activates
    TRAIT ||--o{ COMP_TRAIT : activated_by
    COMP_CHAMPION ||--o{ ITEM : equips
```

### 4. 아키텍처 다이어그램 — 시스템 구조

프로젝트 전체 아키텍처 또는 인프라 시각화.

```mermaid
flowchart LR
    subgraph Client
        A[React Native App]
        B[Web Browser]
    end
    subgraph AWS
        C[EC2 - NestJS API]
        D[S3 - Static Assets]
        E[PostgreSQL]
        F[Redis Cache]
    end
    subgraph External
        G[Riot API]
    end

    A --> C
    B --> C
    C --> D
    C --> E
    C --> F
    C --> G
```

### 5. 상태 다이어그램 (State) — 프로세스 흐름

작업 상태 전이, 결제 흐름 등.

```mermaid
stateDiagram-v2
    [*] --> Free: 앱 설치
    Free --> Premium: 결제 완료
    Premium --> Free: 구독 해지
    Free --> Free: 광고 시청
    
    state Free {
        [*] --> AdSupported
        AdSupported --> AIRecommend: 3회/일 제한
        AIRecommend --> AdSupported
    }
    
    state Premium {
        [*] --> Unlimited
        Unlimited --> AIRecommend_Pro: 무제한
    }
```

### 6. 간트 차트 (Gantt) — 일정 관리

프로젝트 마일스톤, 스프린트 계획.

```mermaid
gantt
    title TFT Agent 개발 일정
    dateFormat YYYY-MM-DD
    
    section Phase 1: Backend
    NestJS 마이그레이션       :done, p1a, 2026-02-17, 1d
    API 테스트/안정화          :active, p1b, after p1a, 2d
    
    section Phase 2: Frontend
    v4 디자인 구현            :p2a, after p1a, 5d
    API 연동                 :p2b, after p2a, 3d
    
    section Phase 3: Launch
    모바일 테스트             :p3a, after p2b, 3d
    앱스토어 배포             :p3b, after p3a, 5d
```

### 7. 파이 차트 — 데이터 시각화

```mermaid
pie title TFT Agent 예상 수익 구조
    "광고 수익 (Free)" : 40
    "프리미엄 구독" : 50
    "인앱 구매" : 10
```

## 사용 가이드

### 기획서에 포함할 때
```markdown
## 3. 유저 플로우

아래 다이어그램은 메인 네비게이션 흐름을 보여줍니다.

```mermaid
flowchart TD
    ...
```​
```

### 노션에 붙여넣기
1. 노션에서 `/mermaid` 입력
2. 코드 블록에 Mermaid 코드 붙여넣기
3. 자동 렌더링 ✅

### GitHub에서
마크다운 파일(`.md`)의 ```mermaid 코드 블록은 자동 렌더링.

### HTML로 렌더링 (대시보드/리서치)
```html
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({theme: 'dark'});</script>

<div class="mermaid">
flowchart TD
    A --> B
</div>
```

## 이서의 사용 규칙

### 반드시 다이어그램 포함하는 경우
- **풀스택 위임 시**: 시퀀스 다이어그램 (프론트↔백 API 흐름)
- **새 기능 기획 시**: 유저 플로우
- **데이터 구조 변경 시**: ERD
- **프로젝트 킥오프 시**: 아키텍처 + 간트 차트

### 다이어그램 포함 안 해도 되는 경우
- 단순 버그 수정
- 텍스트/스타일 수정
- 단일 API 엔드포인트 추가

## 스타일 가이드
- 노드 텍스트는 **한국어** 우선 (사장님 리뷰용)
- 기술 용어는 영문 허용 (API, DB, Redis 등)
- 색상: Mermaid 기본 테마 사용 (노션/GitHub 호환성)
- 복잡한 다이어그램은 subgraph로 그룹화
