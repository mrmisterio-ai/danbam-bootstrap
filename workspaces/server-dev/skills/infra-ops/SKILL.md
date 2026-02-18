---
name: infra-ops
description: |
  인프라 및 운영 스킬.
  PM2, 환경변수, 서버 모니터링, 배포 검증.
  "내 컴퓨터에선 되는데 서버에선 안 돼요"를 방지.
---

# Infra Ops — 인프라 및 운영

## 서버 정보

### TFT Agent 백엔드
- IP: `3.38.240.35`
- SSH: `ssh ubuntu@3.38.240.35`
- PM2 프로세스: `tft-agent-api`
- 포트: 3000
- 프레임워크: Fastify
- 디렉토리: `/home/ubuntu/tft-agent-backend/`

### 대시보드 백엔드
- IP: `3.37.8.223`
- PM2 프로세스: `danbam-api`
- 포트: 3000
- 프레임워크: Express v5
- 디렉토리: `/home/ubuntu/projects/backend/`

## PM2 운영

### 기본 명령어
```bash
pm2 status                          # 전체 상태
pm2 logs tft-agent-api --lines 50   # 최근 로그
pm2 restart tft-agent-api           # 재시작
pm2 restart tft-agent-api --update-env  # 환경변수 갱신 후 재시작
pm2 monit                           # 실시간 모니터링
```

### 배포 후 검증
```bash
# 1. 재시작
pm2 restart tft-agent-api --update-env

# 2. 상태 확인 (online인지)
sleep 3 && pm2 status

# 3. 헬스체크
curl -s http://localhost:3000/api/health

# 4. 주요 API 확인
curl -s http://localhost:3000/api/meta/comps | head -1
```

### 크래시 대응
```bash
# PM2 로그에서 에러 확인
pm2 logs tft-agent-api --lines 100 --err

# 재시작 횟수 확인 (↺ 컬럼)
pm2 status

# 재시작 횟수가 급증하면 → 코드 문제
# 수정 후 재배포
```

## 환경변수 관리

### .env 파일 규칙
```bash
# ✅ 올바른 방법
PORT=3000
HOST=0.0.0.0
RIOT_API_KEY=RGAPI-xxxxx
NODE_ENV=production

# ❌ 절대 금지
# HOST=localhost            ← 외부 접근 불가
# RIOT_API_KEY=하드코딩     ← 코드에 직접 넣지 말 것
```

### 환경변수 확인
```bash
# 서버에서 현재 환경변수 확인
cat /home/ubuntu/tft-agent-backend/.env

# PM2에 반영된 환경변수 확인
pm2 env tft-agent-api | grep -E "PORT|HOST|NODE_ENV|RIOT"
```

## 배포 체크리스트

### 코드 배포 시
- [ ] 로컬에서 `node src/server.js` 실행 → 에러 없이 시작하는가?
- [ ] cURL로 주요 API 테스트 통과하는가?
- [ ] `.env` 파일이 서버에 있는가?
- [ ] PM2 재시작 후 `online` 상태인가?
- [ ] PM2 로그에 에러 없는가?
- [ ] 외부에서 접근 가능한가? (0.0.0.0 바인딩)

### DB/데이터 변경 시
- [ ] 기존 데이터 백업했는가?
- [ ] 마이그레이션 스크립트가 있는가?
- [ ] 롤백 계획이 있는가?
- [ ] 프론트엔드에 영향 있으면 매니저에게 보고했는가?

## 보안 규칙

### 절대 하지 말 것
- ❌ API 키를 코드에 하드코딩
- ❌ 에러 스택트레이스를 클라이언트에 노출
- ❌ CORS를 `*`로 설정 (프로덕션)
- ❌ rate limiting 없이 배포
- ❌ SQL/NoSQL Injection 가능한 쿼리

### 반드시 할 것
- ✅ 모든 비밀 정보는 `.env`에서 관리
- ✅ 에러 핸들러에서 클라이언트에는 일반 메시지만 전송
- ✅ 입력 값 검증 (data-integrity 스킬 참조)
- ✅ unhandledRejection, uncaughtException 핸들러 등록
