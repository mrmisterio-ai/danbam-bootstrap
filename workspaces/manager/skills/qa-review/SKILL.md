---
name: qa-review
description: |
  서브에이전트 결과물 검수(QA) 스킬.
  AC(인수 조건) 기반 자동/수동 검증 → Pass/Fail 판정 → 재작업 또는 승인.
  "맹목적으로 믿지 않는다"가 핵심.
---

# QA Review — 검수 및 피드백

## 핵심 원칙
**서브에이전트가 "완료"라고 해도 직접 확인한다.**
에이전트는 거짓말을 안 하지만, 실수는 한다.

## 검수 프로세스

### 1. 서브에이전트 결과 수신
spawn 완료 후 보고를 받으면:
- 어떤 파일이 변경됐는지 확인
- 커밋 해시 확인
- 에이전트가 보고한 "완료 사항" 목록 확인

### 2. AC 체크 (자동 검증)

#### 백엔드 AC 체크
```bash
# a) 서버 정상 실행 확인
ssh ubuntu@[서버IP] "pm2 status [프로세스명]"

# b) API 응답 확인
curl -s http://[서버IP]:3000/api/[엔드포인트] | python3 -c "
import sys, json
data = json.load(sys.stdin)
print('✅ success' if data.get('success') else '❌ failed')
print(f'  data type: {type(data.get(\"data\")).__name__}')
if isinstance(data.get('data'), list):
    print(f'  count: {len(data[\"data\"])}')
"

# c) 에러 케이스 확인
curl -s -X POST http://[서버IP]:3000/api/[엔드포인트] \
  -H "Content-Type: application/json" \
  -d '{}' | python3 -c "
import sys, json
data = json.load(sys.stdin)
status = '✅' if not data.get('success') else '❌ (에러여야 하는데 성공)'
print(f'{status} error handling')
"

# d) 필드명 검증 (API 계약 대조)
curl -s http://[서버IP]:3000/api/[엔드포인트] | python3 -c "
import sys, json
data = json.load(sys.stdin)
expected = ['id', 'name', 'tier']  # AC에 정의된 필드
item = data['data'][0] if isinstance(data.get('data'), list) else data.get('data', {})
missing = [f for f in expected if f not in item]
extra = [f for f in item if f not in expected]
if missing: print(f'❌ Missing: {missing}')
if extra: print(f'⚠️ Extra: {extra}')
if not missing: print('✅ All required fields present')
"
```

#### 프론트엔드 AC 체크
```bash
# a) 빌드 성공 확인
ssh ubuntu@[서버IP] "cd [프로젝트경로] && npm run build 2>&1 | tail -3"

# b) TypeScript 에러 확인
ssh ubuntu@[서버IP] "cd [프로젝트경로] && npx tsc --noEmit 2>&1 | tail -5"

# c) 웹 접근 확인
curl -s -o /dev/null -w "%{http_code}" http://[서버IP]:3000/app/

# d) 스크린샷 검증 (Playwright)
# → browser 도구로 스크린샷 촬영 후 디자인 시안과 비교
```

#### 디자인 AC 체크
```bash
# a) HTML 페이지 접근 확인
curl -s -o /dev/null -w "%{http_code}" http://[서버IP]:3000/design/v4/[페이지].html

# b) browser 도구로 스크린샷 → Gemini Vision 평가
# → vision-critique 스킬 참조
```

### 3. 판정

#### ✅ Pass
모든 AC 통과 → 사장님에게 보고

#### ❌ Fail
하나라도 실패 → **구체적 피드백과 함께 재작업 지시**

재작업 지시 템플릿:
```markdown
## 재작업 요청

### 실패 항목
- AC2: 빈 items 배열 시 200 반환됨 (400이어야 함)
- AC4: TypeScript 빌드 에러 3건

### 구체적 수정 사항
1. `recommend.controller.ts` L25: items 배열 길이 검증 추가
2. `comp.interface.ts` L12: `tier` 필드 타입 `string`으로 변경

### 참고
- 원래 AC: [원본 인수 조건 다시 첨부]
- 기존 보고서: [에이전트가 보고한 내용 참조]
```

### 4. 최종 보고

사장님에게 보고할 때:
```markdown
## [기능명] 검수 완료

### 결과: ✅ Pass / ❌ Fail (재작업 N회)

### AC 체크 결과
- [x] AC1: API 200 반환 ✅
- [x] AC2: 에러 핸들링 ✅
- [ ] AC3: 빌드 에러 ❌ → 수정 완료 후 재검증 ✅
- [x] AC4: 디자인 일치 ✅

### 변경 파일
- `src/recommend/recommend.controller.ts` (신규)
- `src/recommend/recommend.service.ts` (신규)

### 남은 작업
- 없음 / [추가 필요 사항]
```

## 검수 레벨 (상황별)

| 레벨 | 언제 | 검증 범위 |
|------|------|----------|
| **L1: Quick** | 단순 수정, 타이포 | PM2 status + 1개 cURL |
| **L2: Standard** | 기능 추가 | 모든 AC cURL + 빌드 확인 |
| **L3: Full** | 마이그레이션, 대규모 변경 | L2 + 스크린샷 + 기존 기능 회귀 테스트 |

## 🚨 배포 체크리스트 (rsync/scp 전 필수)

### 서버 고유 파일 보호 목록
서버에만 존재하는 파일들. 로컬 코드 동기화 시 절대 삭제/덮어쓰기 금지:
- `src/spa-fallback.controller.ts` — SPA fallback (/app/* → index.html)
- `src/health/` — Health check endpoint
- `src/main.ts` — Swagger, static serving, CORS 설정 포함 (로컬과 다름)

### 배포 전 확인
1. **diff 먼저**: `ssh 서버 "ls src/"` vs 로컬 `ls src/` 비교 — 서버에만 있는 파일 확인
2. **rsync exclude**: 서버 고유 파일은 `--exclude` 처리
3. **npm install**: 패키지 추가/삭제 있으면 서버에서도 실행

### 배포 후 smoke test (필수, 생략 금지)
```bash
# 최소 3개 URL 200 확인
curl -s -o /dev/null -w "%{http_code}" http://[서버IP]:3000/app/
curl -s -o /dev/null -w "%{http_code}" http://[서버IP]:3000/api/health
curl -s -o /dev/null -w "%{http_code}" http://[서버IP]:3000/api/docs
```
404 하나라도 나오면 배포 실패 — 즉시 롤백 또는 수정.

## ⚠️ 이서의 실수 기록 — 반복 금지
- 승권이가 "완료"라고 해서 그냥 사장님한테 보고 → 필드명 틀려서 프론트 깨짐
- 빌드 확인 안 하고 배포 → 화이트 스크린
- 디자인 검수 없이 "현이 완료" 보고 → 사장님 피드백 5건
- **rsync로 서버 코드 덮어쓰면서 SPA fallback/Health/Swagger/Static serving 삭제** → 사장님이 404 에러 발견 (2026-02-18)
