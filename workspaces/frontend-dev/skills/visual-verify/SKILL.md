---
name: visual-verify
description: |
  UI 시각적 검증 스킬.
  Playwright로 스크린샷 캡처 → 디자인 시안과 비교 → 차이점 수정.
  UI 작업 완료 시 반드시 시각적 검증을 거칠 것.
---

# Visual Verify — UI 시각적 검증 스킬

## 핵심 원칙
**"코드가 맞다"와 "화면이 맞다"는 다르다.**
코드가 빌드되더라도 화면이 디자인과 다를 수 있다.
반드시 실제 렌더링 결과를 확인한다.

## 검증 프로세스

### Step 1: Expo Web 빌드 & 배포
```bash
cd /home/ubuntu/projects/tft-agent-frontend
npx expo export --platform web
# 빌드 결과 → dist/ 폴더

# type="module" 추가
sed -i 's/<script src/<script type="module" src/' dist/index.html

# TFT 서버에 배포
scp -r dist/* ubuntu@3.38.240.35:/home/ubuntu/tft-agent-backend/public/app/
```

### Step 2: Playwright 스크린샷 캡처
```bash
# 모바일 뷰 (430px) 캡처
npx playwright screenshot \
  --viewport-size="430,932" \
  --full-page \
  "http://3.38.240.35:3000/app/" \
  /tmp/app-screenshot.png
```

### Step 3: 디자인 시안과 비교
v4 디자인 프로토타입과 실제 구현 비교:
```bash
# 디자인 시안 캡처
npx playwright screenshot \
  --viewport-size="430,932" \
  --full-page \
  "http://3.38.240.35:3000/design/v4/home.html" \
  /tmp/design-screenshot.png
```

### Step 4: 차이점 확인 및 수정
두 스크린샷을 비교하여 차이점 목록 작성:
- 간격/패딩 차이
- 폰트 사이즈/웨이트 차이
- 색상 차이
- 컴포넌트 누락
- 레이아웃 깨짐

## 체크리스트 (UI 작업 완료 시)

### 레이아웃
- [ ] 좌우 패딩이 디자인과 동일한가?
- [ ] 카드 간격이 일정한가?
- [ ] 스크롤 시 탭바가 고정되는가?
- [ ] Safe Area (노치/인디케이터)가 처리되었는가?

### 컴포넌트
- [ ] 챔피언 아이콘이 정상 렌더링되는가?
- [ ] 아이템 아이콘이 정상 렌더링되는가?
- [ ] 티어 뱃지 색상이 맞는가?
- [ ] 빈 상태(Empty State)가 처리되었는가?
- [ ] 로딩 상태(Skeleton)가 처리되었는가?

### 반응성
- [ ] 다양한 화면 크기에서 깨지지 않는가? (375px, 390px, 430px)
- [ ] 긴 텍스트가 overflow 없이 처리되는가?
- [ ] 이미지 404 시 placeholder가 표시되는가?

## 디자인 토큰 참조
v4 디자인 시안의 CSS 변수를 React Native StyleSheet로 변환:
```typescript
// colors.ts
export const colors = {
  bg: '#0a0e1a',
  bgCard: 'rgba(255,255,255,0.04)',
  gold: '#f0b429',
  op: '#ff4444',
  // 코스트
  c1: '#9ca3af',
  c2: '#10b981',
  c3: '#3b82f6',
  c4: '#a855f7',
  c5: '#f59e0b',
  // 티어
  tierS: '#ff4444',
  tierA: '#ff8c00',
  tierB: '#4a9eff',
};
```
