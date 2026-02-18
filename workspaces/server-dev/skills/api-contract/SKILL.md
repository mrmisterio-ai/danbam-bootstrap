---
name: api-contract
description: |
  API 명세 및 계약 스킬. Schema-First 접근.
  코드를 짜기 전 API 명세서를 먼저 작성하고, 구현 후 명세서와 일치하는지 검증.
  프론트엔드(현이)와의 계약을 지키는 것이 최우선.
---

# API Contract — API 명세 및 계약

## 핵심 원칙
**명세 먼저, 코드 나중. 계약을 어기면 프론트가 죽는다.**

## Schema-First 프로세스

### Step 1: API 명세서 작성
코드 작성 전 반드시 엔드포인트 명세를 정의:

```markdown
## GET /api/meta/comps
- 설명: 메타 조합 목록
- 응답:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "comp_001",
        "name": "Watcher Kalista",
        "nameKo": "파수꾼 칼리스타",
        "tier": "S",
        "avgPlacement": 3.48,
        "top4Rate": 0.693,
        "winRate": 0.178,
        "pickRate": 0.0014,
        "champions": [...],
        "traits": [...],
        "coreChampions": [...]
      }
    ]
  }
  ```
- 필드명 규칙: camelCase
- 비율 값: 소수점 (0.693 = 69.3%)
- 다국어: nameKo, nameEn 분리
```

### Step 2: 구현
명세서에 정의된 대로 정확히 구현.

### Step 3: cURL 검증
구현 후 실제 요청으로 검증:
```bash
# API 응답 확인
curl -s http://localhost:3000/api/meta/comps | python3 -m json.tool | head -30

# 필드명 검증
curl -s http://localhost:3000/api/meta/comps | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('success'):
    comp = data['data'][0]
    required = ['id', 'name', 'nameKo', 'tier', 'avgPlacement', 'top4Rate', 'winRate', 'pickRate']
    missing = [f for f in required if f not in comp]
    if missing: print(f'❌ Missing fields: {missing}')
    else: print('✅ All fields present')
"

# HTTP 상태코드 확인
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/meta/comps
```

### Step 4: 에러 케이스 검증
```bash
# 404 — 존재하지 않는 리소스
curl -s http://localhost:3000/api/meta/comps/nonexistent

# 400 — 잘못된 요청
curl -s -X POST http://localhost:3000/api/recommend/by-items \
  -H "Content-Type: application/json" \
  -d '{"items": []}'

# 500 — 내부 에러 (일부러 발생시키기)
```

## API 필드명 규칙 — 절대 규칙

| 규칙 | 예시 |
|------|------|
| **camelCase** | `avgPlacement`, `top4Rate` (snake_case 금지) |
| **비율은 소수점** | `0.693` (69.3% 아님) |
| **ID는 string** | `"comp_001"` (number 아님) |
| **다국어 필드 분리** | `name` (영문), `nameKo` (한글) |
| **배열은 복수형** | `champions`, `traits`, `items` |
| **boolean은 is/has 접두사** | `isCore`, `hasItems` |

## 응답 형식 표준

### 성공
```json
{
  "success": true,
  "data": { ... }
}
```

### 에러
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Composition not found"
  }
}
```

### 목록 (페이지네이션)
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "hasNext": true
  }
}
```

## ⚠️ 과거 실수 — 반복 금지
- `thisWeek` vs `week` 필드명 불일치 → 명세서 확인 후 구현
- `coreChampions`를 string 배열로 보냄 → object 배열로 (name, cost, items 포함)
- `.env`에 localhost 하드코딩 → 환경변수로 분리
