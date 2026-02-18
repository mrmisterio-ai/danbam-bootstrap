---
name: design-system
description: TFT Agent 디자인 시스템. 디자인 토큰, 컴포넌트 규격, 레이아웃 규칙 정의. 모든 화면 작업 전 이 문서를 반드시 참조할 것.
---

# TFT Agent Design System

## Design Tokens

### Colors
```css
--bg: #0a0e1a;                    /* 메인 배경 */
--bg-card: rgba(255,255,255,0.04); /* 카드 배경 (글래스모피즘) */
--bg-card-border: rgba(255,255,255,0.08); /* 카드 보더 */
--gold: #f0b429;                   /* 골드 강조 */
--op: #ff4444;                     /* OP 뱃지 */

/* 티어 컬러 — 좌측 컬러바에만 사용, 카드 배경에 절대 사용 금지 */
--tier-s: #ff4444;
--tier-a: #ff8c00;
--tier-b: #4a9eff;
--tier-c: #888888;

/* 코스트 컬러 */
--c1: #9ca3af;  /* 1코 회색 */
--c2: #10b981;  /* 2코 초록 */
--c3: #3b82f6;  /* 3코 파랑 */
--c4: #a855f7;  /* 4코 보라 */
--c5: #f59e0b;  /* 5코 노랑 */
```

### Typography
```css
--font-display: 'Exo 2', sans-serif;       /* 제목, 숫자 */
--font-body: 'Pretendard', sans-serif;      /* 본문 */
--font-mono: 'JetBrains Mono', monospace;   /* 통계 숫자 */
```

### Spacing
```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 12px;
--space-lg: 16px;
--space-xl: 24px;
--space-2xl: 32px;
```

### Border Radius
```css
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-full: 9999px;
```

## Component Specifications

### Card — 조합 카드
```
배경: var(--bg-card) + backdrop-filter: blur(20px)
보더: 1px solid var(--bg-card-border)
라운딩: var(--radius-md)
패딩: 16px
카드 간격: 12px (gap)
티어 표시: 좌측 4px 컬러바 (border-left: 4px solid var(--tier-x))
⚠️ 카드 배경에 티어 색상/그라데이션 절대 금지
```

### Hexagon Board — 포지셔닝
```
그리드: 4행 × 7열 = 28칸
셀 크기: 48px × 48px (균일)
셀 간격: 4px (균일)
짝수 줄 오프셋: (cellWidth + gap) / 2 = 26px
빈 셀: --bg (#1a2332), 보더 rgba(255,255,255,0.06)
챔피언 셀: clip-path hexagon, 코스트별 보더, 이름 아래 표시
핵심 챔피언: box-shadow 글로우 효과
⚠️ 모든 셀 정확히 같은 크기, 간격 수학적으로 정확할 것
```

### Section Icons
- 섹션 제목 앞 아이콘은 반드시 의미 매칭되는 Phosphor SVG 사용
- 핫 메타: fire 또는 flame 아이콘
- 포지셔닝: chess/grid/map 관련 아이콘
- 3신기: sword/shield/crown 관련 아이콘
- 전적/히스토리: clipboard-text 또는 chart-line 아이콘
- 아이콘이 의미에 안 맞으면 차라리 아이콘 없이 텍스트만

### Tab Bar
```
5탭: 홈, 메타, AI추천, 즐겨찾기, 설정
아이콘: Phosphor SVG (24px)
활성: var(--gold) + 이름 표시
비활성: rgba(255,255,255,0.4)
```

## Layout Rules

### 전체 화면
```
max-width: 430px (모바일 기준)
padding: 0 20px (좌우 균일)
```

### 카드 리스트
```
display: flex; flex-direction: column;
gap: 12px; /* 카드 간격 필수 */
```

### 챔피언 카드 (핵심 챔피언 섹션)
```
전체 가로폭 활용 — 우측 여백 최소화
좌측: 큰 헥사곤 (64px)
우측: flex-grow: 1 (남은 공간 전부 사용)
아이템 아이콘: 36-40px (충분히 크게)
서브 아이템: 20px
```

## Quality Checklist (매 화면 완성 시 확인)
- [ ] 이모지 아이콘 사용하지 않았는가?
- [ ] 카드 배경에 티어 색상을 넣지 않았는가?
- [ ] 카드 간격(gap)이 12px 이상인가?
- [ ] 좌우 여백이 균일한가?
- [ ] 헥사곤 보드 셀 크기/간격이 균일한가?
- [ ] 모든 섹션 아이콘이 의미에 맞는가?
- [ ] Google Fonts CDN 임포트가 있는가?
- [ ] noise texture 배경이 적용되었는가?
