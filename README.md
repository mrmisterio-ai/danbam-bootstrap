# 🌰 단밤 AI 개발팀 부트스트랩

AI 에이전트 4명으로 구성된 개발팀을 Docker 한 방으로 셋업합니다.

## 팀 구성

| 역할 | 모델 | 담당 |
|------|------|------|
| 🔥 매니저 | Opus 4.6 | 기획, 태스크 분배, QA |
| 💪 백엔드 개발자 | Sonnet 4.5 | API, DB, 서버 |
| ✨ 프론트엔드 개발자 | Sonnet 4.5 | UI, 컴포넌트, 빌드 |
| 🎨 UI/UX 디자이너 | Sonnet 4.5 | 디자인, 프로토타입 |

## 빠른 시작 (원클릭)

빈 Ubuntu EC2 인스턴스에서 이것만 실행하세요:

```bash
curl -sL https://raw.githubusercontent.com/mrmisterio-ai/danbam-bootstrap/main/install.sh | bash
```

스크립트가 자동으로:
1. 시스템 패키지 설치 (curl, git, jq...)
2. Docker + Docker Compose 설치
3. 리포지토리 다운로드
4. 프로젝트 정보 입력 (팀 이름, 프로젝트명)
5. 인증 토큰 입력 (Claude, Discord, Figma 등)
6. `.env` 파일 생성
7. Docker 빌드 & 실행

### 수동 설치

```bash
git clone https://github.com/mrmisterio-ai/danbam-bootstrap.git
cd danbam-bootstrap
cp .env.example .env
vi .env  # 토큰 입력
docker compose up -d --build
```

### 접속
```bash
# 로그 확인
docker logs -f danbam-team

# CLI로 매니저와 대화
docker exec -it danbam-team openclaw chat manager
```

## 환경변수

### 필수 (둘 중 하나)
| 변수 | 설명 |
|------|------|
| `ANTHROPIC_COOKIE` | Claude Max 구독자용 OAuth cookie |
| `ANTHROPIC_API_KEY` | Anthropic API 키 |

### 프로젝트 정보
| 변수 | 기본값 | 설명 |
|------|--------|------|
| `TEAM_NAME` | 단밤 | 팀 이름 |
| `PROJECT_NAME` | 새 프로젝트 | 프로젝트명 |

### 선택
| 변수 | 설명 |
|------|------|
| `DISCORD_BOT_TOKEN` | Discord 봇 토큰 |
| `DISCORD_USER_ID` | 허용할 Discord 사용자 ID |
| `DISCORD_GUILD_ID` | Discord 서버 ID |
| `FIGMA_TOKEN` | Figma API 토큰 |
| `GITHUB_TOKEN` | GitHub Personal Access Token |
| `BRAVE_API_KEY` | Brave Search API 키 |

## Discord 봇 설정 (수동)

Docker로 자동화되지 않는 부분입니다:

1. [Discord Developer Portal](https://discord.com/developers/applications) 접속
2. **New Application** → 이름 입력
3. **Bot** → **Reset Token** → 토큰 복사 → `.env`에 입력
4. **Bot** → **MESSAGE CONTENT INTENT** ✅ 활성화
5. **OAuth2** → **URL Generator** → `bot` + `applications.commands` 체크
6. 권한: Send Messages, Read Message History, Add Reactions
7. 생성된 URL로 서버에 봇 초대

## 포함된 스킬 (23개)

### 매니저 (6개)
- task-decomposition — WBS 분해, AC 정의
- qa-review — 결과물 검수
- design-pipeline — 디자인 에셋 파이프라인
- nano-banana — Google AI 이미지 생성
- diagram-generator — Mermaid.js 다이어그램
- delegation — 위임 체크리스트

### 백엔드 개발자 (6개)
- api-contract — Schema-First API 설계
- self-test — TDD + 자동 검증
- data-integrity — 데이터 무결성
- infra-ops — 인프라/배포
- dev-standards — 개발 표준
- mcp-builder — MCP 서버 구축

### 프론트엔드 개발자 (6개)
- self-debug — Self-Debug 루프
- visual-verify — 시각적 검증
- expo-rn — Expo/React Native
- code-quality — 코드 품질
- dev-standards — 개발 표준
- frontend-design — 프론트엔드 디자인 구현

### UI/UX 디자이너 (5개)
- frontend-design — HTML/CSS 프로토타입
- design-system — 디자인 토큰/컴포넌트
- vision-critique — 이미지+HTML 피드백 루프
- post-processing — 이미지 후처리
- canvas-design — 캔버스 디자인

## 구조

```
danbam-bootstrap/
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── config/
│   └── openclaw.template.json    # OpenClaw 설정 템플릿
├── scripts/
│   └── entrypoint.sh             # 컨테이너 시작 스크립트
├── cli-proxy-api/
│   ├── cli-proxy-api             # OAuth 프록시 바이너리
│   └── config.template.yaml
└── workspaces/
    ├── manager/
    │   ├── SOUL.template.md
    │   ├── AGENTS.md
    │   └── skills/ (6개)
    ├── server-dev/
    │   ├── SOUL.template.md
    │   └── skills/ (6개)
    ├── frontend-dev/
    │   ├── SOUL.template.md
    │   └── skills/ (6개)
    └── uiux-designer/
        ├── SOUL.template.md
        └── skills/ (5개)
```

## 데이터 영속성

Docker volume으로 다음이 보존됩니다:
- `danbam-projects` — 프로젝트 코드
- `danbam-memory` — 매니저 메모리
- `danbam-sessions` — 세션 기록

## CLI-Proxy-API

Claude Max 구독자용 OAuth 프록시입니다.
Anthropic API 키를 직접 사용하는 경우 이 프록시는 시작되지 않습니다.

### 인증 방법
1. [claude.ai](https://claude.ai) 로그인
2. Chrome DevTools → Application → Cookies
3. `sessionKey` 값 복사
4. `.env`의 `ANTHROPIC_COOKIE`에 설정

## 라이선스

Private — 내부 사용 전용
