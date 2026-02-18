---
name: expo-rn
description: |
  React Native (Expo) 전문 스킬.
  Expo SDK, 네이티브 모듈 호환성, 플랫폼별 처리, Config Plugin.
  모바일 앱 작업 시 반드시 참조.
---

# Expo React Native — 플랫폼 특화 스킬

## 프로젝트 정보
- 경로: `/home/ubuntu/projects/tft-agent-frontend/`
- SDK: Expo SDK 54
- Router: Expo Router (file-based)
- 상태관리: Zustand + React Query
- i18n: i18next + react-i18next
- 스타일: React Native StyleSheet (NativeWind 미사용)

## Expo CLI 핵심 명령어
```bash
# 개발 서버
npx expo start

# 웹 빌드
npx expo export --platform web

# 타입 체크
npx tsc --noEmit

# 패키지 설치 (Expo 호환 버전 자동 선택)
npx expo install <패키지명>
```

## ⚠️ Expo 필수 규칙

### 1. 패키지 설치는 반드시 `npx expo install`
```bash
# ✅ 올바른 방법 — Expo SDK 호환 버전 자동 선택
npx expo install react-native-reanimated

# ❌ 잘못된 방법 — 호환 안 되는 최신 버전 설치될 수 있음
npm install react-native-reanimated
```

### 2. 네이티브 코드 직접 수정 금지
- `android/`, `ios/` 폴더를 직접 수정하지 않는다
- 네이티브 설정은 **Expo Config Plugin** 통해서만
- `app.json` 또는 `app.config.js`에서 plugins 배열로 설정

### 3. 네이티브 모듈 호환성 체크
라이브러리 추가 전 확인:
```bash
# Expo SDK 호환 확인
npx expo install <패키지> --check

# React Native Directory에서 Expo 지원 여부 확인
# https://reactnative.directory/?expo=true
```

### 4. 플랫폼별 처리
```typescript
import { Platform } from 'react-native';

// 플랫폼별 분기
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 0,
    ...Platform.select({
      web: { maxWidth: 430, margin: '0 auto' },
      default: {},
    }),
  },
});
```

## Expo Router 패턴

### 파일 구조 = 라우트 구조
```
app/
├── _layout.tsx        # 루트 레이아웃
├── (tabs)/
│   ├── _layout.tsx    # 탭 네비게이션
│   ├── index.tsx      # 홈 탭 (/)
│   ├── meta.tsx       # 메타 탭
│   ├── recommend.tsx  # AI추천 탭
│   ├── favorites.tsx  # 즐겨찾기 탭
│   └── settings.tsx   # 설정 탭
└── comp/
    └── [id].tsx       # 조합 상세 (/comp/:id)
```

### 네비게이션
```typescript
import { router } from 'expo-router';

// 이동
router.push('/comp/123');

// 뒤로가기 (안전하게)
router.canGoBack() ? router.back() : router.push('/');

// 탭 전환
router.push('/(tabs)/meta');
```

## 웹 빌드 특이사항

### base URL 설정
```json
// app.json
{
  "expo": {
    "experiments": {
      "baseUrl": "/app"
    }
  }
}
```

### script type="module" 필수
```bash
# 빌드 후 index.html 수정
sed -i 's/<script src/<script type="module" src/' dist/index.html
```

### 이미지 경로
```typescript
// 웹에서 외부 이미지 URL 사용 시
const getChampionImage = (name: string) => {
  const API_BASE = 'http://3.38.240.35:3000';
  return `${API_BASE}/images/champions/tft16_${name.toLowerCase()}.png`;
};
```

## React Native StyleSheet 패턴

### ✅ 올바른 패턴
```typescript
const styles = StyleSheet.create({
  card: {
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
});
```

### ❌ 하지 말 것
- CSS 클래스명 사용 (className 속성 없음, NativeWind 미사용)
- `vh`, `vw` 단위 (Dimensions API 또는 useWindowDimensions 사용)
- CSS Grid (React Native에 없음, Flexbox만 사용)
- `position: fixed` (RN에 없음, `position: 'absolute'` 사용)
- `hover` 스타일 (모바일에 hover 없음, Pressable의 pressed 상태 사용)

## 성능 최적화
- FlatList 사용 (ScrollView 대신, 긴 목록에서)
- 이미지 캐싱: expo-image 또는 react-native-fast-image
- 메모이제이션: useMemo, useCallback 적절히 사용
- 번들 사이즈: tree-shaking 가능한 라이브러리 선택
