---
name: self-test
description: |
  자체 테스트 및 디버깅 스킬.
  TDD(Red→Green→Refactor) + Zero Script QA (로그 기반 검증).
  모든 API 구현 후 반드시 자체 검증을 거칠 것.
---

# Self-Test — 테스트 및 디버깅

## 핵심 원칙
**서버가 죽으면 단밤이 죽는다. 테스트 없이 커밋하지 않는다.**

## TDD 프로세스

### 1. 테스트 먼저 작성 (Red)
```javascript
// __tests__/meta.test.js
const { describe, it, expect } = require('@jest/globals');

describe('GET /api/meta/comps', () => {
  it('should return success with comp list', async () => {
    const res = await fetch('http://localhost:3000/api/meta/comps');
    const data = await res.json();
    
    expect(res.status).toBe(200);
    expect(data.success).toBe(true);
    expect(Array.isArray(data.data)).toBe(true);
    expect(data.data.length).toBeGreaterThan(0);
  });

  it('each comp should have required fields', async () => {
    const res = await fetch('http://localhost:3000/api/meta/comps');
    const { data } = await res.json();
    const comp = data[0];
    
    expect(comp).toHaveProperty('id');
    expect(comp).toHaveProperty('name');
    expect(comp).toHaveProperty('tier');
    expect(comp).toHaveProperty('avgPlacement');
    expect(typeof comp.avgPlacement).toBe('number');
  });
});
```

### 2. 구현 (Green)
테스트가 통과할 때까지 구현.

### 3. 리팩토링
테스트가 통과한 상태에서 코드 정리.

## Zero Script QA — 로그 기반 검증

테스트 코드 없이도 **구조화 로그**로 API 동작을 검증.

### 구조화 로그 포맷
```javascript
// 모든 API 요청에 로그 추가
app.addHook('onRequest', (request, reply, done) => {
  const log = {
    timestamp: new Date().toISOString(),
    method: request.method,
    url: request.url,
    requestId: request.id,
    ip: request.ip,
  };
  request.log.info(log);
  done();
});

// 응답 로그
app.addHook('onResponse', (request, reply, done) => {
  const log = {
    timestamp: new Date().toISOString(),
    method: request.method,
    url: request.url,
    requestId: request.id,
    statusCode: reply.statusCode,
    responseTimeMs: reply.elapsedTime,
  };
  request.log.info(log);
  done();
});
```

### 에러 로그
```javascript
app.setErrorHandler((error, request, reply) => {
  const log = {
    timestamp: new Date().toISOString(),
    level: 'ERROR',
    requestId: request.id,
    method: request.method,
    url: request.url,
    error: error.message,
    stack: error.stack,
  };
  request.log.error(log);
  reply.status(500).send({ success: false, error: { code: 'INTERNAL', message: 'Internal Server Error' } });
});
```

## cURL 자동 검증 스크립트

작업 완료 후 반드시 실행:
```bash
#!/bin/bash
# API 자동 검증

BASE="http://localhost:3000"
PASS=0
FAIL=0

check() {
  local desc="$1" url="$2" expected_status="$3"
  actual=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$actual" == "$expected_status" ]; then
    echo "✅ $desc (HTTP $actual)"
    ((PASS++))
  else
    echo "❌ $desc (Expected $expected_status, got $actual)"
    ((FAIL++))
  fi
}

check "Meta comps list" "$BASE/api/meta/comps" "200"
check "Comp detail" "$BASE/api/meta/comps/comp_001" "200"
check "Champions list" "$BASE/api/champions" "200"
check "Recommend by items" "$BASE/api/recommend/by-items" "400"  # POST 필요

echo ""
echo "Results: $PASS passed, $FAIL failed"
```

## 디버깅 루프 (에러 발생 시)

```
1. PM2 로그 확인: pm2 logs tft-agent-api --lines 50
2. 에러 패턴 분석
3. 코드 수정
4. PM2 재시작: pm2 restart tft-agent-api
5. cURL 재검증
6. 최대 3회 반복 → 실패 시 매니저 보고
```

## ⚠️ 절대 규칙
- 서버가 크래시하는 코드 커밋 금지 (try/catch 필수)
- unhandledRejection 핸들러 반드시 등록
- PM2 재시작 후 `pm2 status`로 online 확인
