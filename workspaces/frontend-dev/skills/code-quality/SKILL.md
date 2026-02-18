---
name: code-quality
description: |
  코드 품질 및 자체 리뷰 스킬.
  TypeScript strict 타입, 컴포넌트 구조, 코드 리뷰 체크리스트.
  코드 작성 시 반드시 따를 것.
---

# Code Quality — 코드 품질 스킬

## TypeScript 규칙

### 타입 안전성
```typescript
// ✅ 올바른 타입 정의
interface CompCardProps {
  comp: MetaComp;
  onPress: (id: string) => void;
}

// ❌ any 사용 금지
interface CompCardProps {
  comp: any;  // 절대 금지
  onPress: Function;  // 구체적 시그니처 사용
}
```

### API 응답 타입 — 실제 응답과 일치시킬 것
```typescript
// API 응답 구조를 정확히 반영
interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}

// API 호출 시 타입 적용
const fetchMeta = async (): Promise<ApiResponse<MetaComp[]>> => {
  const res = await fetch(`${API_BASE}/api/meta/comps`);
  return res.json();
};
```

## 컴포넌트 구조

### Atomic Design 패턴
```
src/components/
├── atoms/          # 최소 단위 (ChampionIcon, ItemIcon, TierBadge)
├── molecules/      # 조합 (CompCard, CoreChampionCard, TraitBadge)
└── organisms/      # 섹션 (MetaList, RecommendResult)
```

### 컴포넌트 작성 규칙
```typescript
// 1. Props 인터페이스 별도 정의
interface ChampionIconProps {
  name: string;
  cost: number;
  size?: number;
}

// 2. 기본값은 destructuring에서
export function ChampionIcon({ name, cost, size = 48 }: ChampionIconProps) {
  // 3. 조기 리턴으로 예외 처리
  if (!name) return <View style={styles.placeholder} />;
  
  // 4. 이미지 에러 핸들링
  return (
    <Image
      source={{ uri: getChampionImage(name) }}
      style={[styles.icon, { width: size, height: size }]}
      onError={() => setFailed(true)}
    />
  );
}
```

## 자체 코드 리뷰 체크리스트

### 작업 완료 시 반드시 확인:

#### 타입
- [ ] `any` 타입 사용하지 않았는가?
- [ ] `@ts-ignore` 사용하지 않았는가?
- [ ] API 응답 타입이 실제 응답과 일치하는가?
- [ ] Props 인터페이스가 정의되었는가?

#### 에러 처리
- [ ] API 호출에 try/catch가 있는가?
- [ ] 로딩 상태를 표시하는가?
- [ ] 에러 상태를 표시하는가?
- [ ] 빈 상태(데이터 없음)를 처리하는가?
- [ ] 이미지 404를 처리하는가?

#### 성능
- [ ] FlatList를 사용하는가? (긴 목록)
- [ ] 불필요한 리렌더링이 없는가?
- [ ] useCallback/useMemo가 적절한가?

#### 접근성
- [ ] 터치 타겟이 44px 이상인가?
- [ ] accessibilityLabel이 있는가? (주요 요소)

#### 코드 스타일
- [ ] 함수/변수명이 의미를 나타내는가?
- [ ] 중복 코드가 없는가? (공통 함수로 추출)
- [ ] 매직 넘버를 상수로 정의했는가?
- [ ] 컴포넌트 파일이 200줄 이하인가? (넘으면 분리)

## 코드 리뷰 자동화 패턴

### 빌드 전 자동 체크
```bash
# 1. 타입 체크
npx tsc --noEmit

# 2. 린트 (설정되어 있다면)
npx eslint src/ --ext .ts,.tsx

# 3. 빌드
npx expo export --platform web
```

### 커밋 전 최종 확인
```bash
# 변경된 파일 확인
git diff --name-only

# any 사용 여부
grep -rn ': any' src/ --include="*.ts" --include="*.tsx"

# @ts-ignore 사용 여부
grep -rn '@ts-ignore' src/ --include="*.ts" --include="*.tsx"

# console.log 잔여 여부
grep -rn 'console.log' src/ --include="*.ts" --include="*.tsx"
```
