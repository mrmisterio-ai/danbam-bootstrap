#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🌰 단밤 AI 개발팀 — 원클릭 설치 스크립트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# 사용법: 빈 Ubuntu EC2에서
#   curl -sL https://raw.githubusercontent.com/mrmisterio-ai/danbam-bootstrap/main/install.sh | bash
#
# 또는:
#   wget -qO- https://raw.githubusercontent.com/mrmisterio-ai/danbam-bootstrap/main/install.sh | bash
#
set -e

# stdin을 터미널에 연결 (curl | bash 에서도 사용자 입력 가능하게)
if [ ! -t 0 ]; then
    exec < /dev/tty
fi

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://github.com/mrmisterio-ai/danbam-bootstrap.git"
INSTALL_DIR="$HOME/danbam-bootstrap"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
clear
echo ""
echo -e "${BOLD}🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}   단밤 AI 개발팀 — 원클릭 설치${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  AI 에이전트 4명으로 구성된 개발팀을 설치합니다."
echo -e "  🔥 매니저 (Opus) + 💪 백엔드 + ✨ 프론트 + 🎨 디자이너"
echo ""
echo -e "${YELLOW}  소요 시간: 약 5~10분${NC}"
echo ""

# 확인
read -p "  설치를 시작할까요? (Y/n): " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "  취소되었습니다."
    exit 0
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: 시스템 패키지 설치
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${CYAN}[1/7] 시스템 패키지 설치${NC}"

sudo apt-get update -qq > /dev/null 2>&1
sudo apt-get install -y -qq curl wget git jq ca-certificates gnupg > /dev/null 2>&1
echo -e "  ${GREEN}✅ 기본 패키지 설치 완료${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: Docker 설치
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${CYAN}[2/7] Docker 설치${NC}"

if command -v docker &> /dev/null; then
    echo -e "  ${GREEN}✅ Docker 이미 설치됨 ($(docker --version | cut -d' ' -f3 | tr -d ','))${NC}"
else
    # Docker 공식 설치
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq > /dev/null 2>&1
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
    
    # 현재 유저를 docker 그룹에 추가
    sudo usermod -aG docker $USER
    echo -e "  ${GREEN}✅ Docker 설치 완료${NC}"
    echo -e "  ${YELLOW}⚠️  docker 그룹 적용을 위해 newgrp docker 실행${NC}"
    # 현재 세션에 적용
    sg docker -c "echo '  docker 그룹 적용됨'" 2>/dev/null || true
fi

# Docker Compose 확인
if docker compose version &> /dev/null; then
    echo -e "  ${GREEN}✅ Docker Compose 사용 가능${NC}"
else
    echo -e "  ${RED}❌ Docker Compose 없음 — 설치 확인 필요${NC}"
    exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: 리포지토리 다운로드
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${CYAN}[3/7] 단밤 부트스트랩 다운로드${NC}"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "  ${YELLOW}기존 설치 발견 — 업데이트 중...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main -q 2>/dev/null || true
else
    git clone -q "$REPO_URL" "$INSTALL_DIR" 2>/dev/null
    cd "$INSTALL_DIR"
fi
echo -e "  ${GREEN}✅ 다운로드 완료 ($INSTALL_DIR)${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: 프로젝트 정보 입력
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${CYAN}[4/7] 프로젝트 정보${NC}"
echo ""

read -p "  팀 이름 (기본: 단밤): " INPUT_TEAM_NAME
TEAM_NAME=${INPUT_TEAM_NAME:-단밤}

read -p "  프로젝트명 (기본: 새 프로젝트): " INPUT_PROJECT_NAME
PROJECT_NAME=${INPUT_PROJECT_NAME:-새 프로젝트}

echo ""
echo -e "  📋 팀: ${BOLD}$TEAM_NAME${NC}"
echo -e "  📋 프로젝트: ${BOLD}$PROJECT_NAME${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 5: 토큰 입력
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${CYAN}[5/7] 인증 토큰 입력${NC}"
echo ""
echo -e "  Claude 인증이 필요합니다. 두 가지 방법 중 선택하세요:"
echo ""
echo -e "  ${BOLD}1)${NC} Claude Max 구독 (OAuth cookie)"
echo -e "     → claude.ai 로그인 → DevTools → Cookies → sessionKey 복사"
echo ""
echo -e "  ${BOLD}2)${NC} Anthropic API 키"
echo -e "     → console.anthropic.com/settings/keys"
echo ""

read -p "  방법 선택 (1 또는 2): " AUTH_METHOD
AUTH_METHOD=${AUTH_METHOD:-1}

if [ "$AUTH_METHOD" = "1" ]; then
    echo ""
    read -p "  Claude sessionKey (sk-ant-sid01-...): " ANTHROPIC_COOKIE
    if [ -z "$ANTHROPIC_COOKIE" ]; then
        echo -e "  ${RED}❌ sessionKey가 필요합니다.${NC}"
        exit 1
    fi
    ANTHROPIC_API_KEY=""
else
    echo ""
    read -p "  Anthropic API 키 (sk-ant-api03-...): " ANTHROPIC_API_KEY
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "  ${RED}❌ API 키가 필요합니다.${NC}"
        exit 1
    fi
    ANTHROPIC_COOKIE=""
fi
echo -e "  ${GREEN}✅ Claude 인증 설정 완료${NC}"

# 선택 토큰들
echo ""
echo -e "  ${BOLD}선택 사항${NC} (Enter로 건너뛰기)"
echo ""

read -p "  Discord 봇 토큰 (없으면 Enter): " DISCORD_BOT_TOKEN
if [ -n "$DISCORD_BOT_TOKEN" ]; then
    read -p "  Discord 사용자 ID: " DISCORD_USER_ID
    read -p "  Discord 서버(Guild) ID: " DISCORD_GUILD_ID
fi

read -p "  Figma 토큰 (없으면 Enter): " FIGMA_TOKEN
read -p "  GitHub 토큰 (없으면 Enter): " GITHUB_TOKEN
read -p "  Brave Search API 키 (없으면 Enter): " BRAVE_API_KEY

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 6: .env 파일 생성
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${CYAN}[6/7] 설정 파일 생성${NC}"

cat > "$INSTALL_DIR/.env" << ENVEOF
# 자동 생성됨 — $(date)
TEAM_NAME=$TEAM_NAME
PROJECT_NAME=$PROJECT_NAME
ANTHROPIC_COOKIE=$ANTHROPIC_COOKIE
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN
DISCORD_USER_ID=${DISCORD_USER_ID:-}
DISCORD_GUILD_ID=${DISCORD_GUILD_ID:-}
FIGMA_TOKEN=$FIGMA_TOKEN
GITHUB_TOKEN=$GITHUB_TOKEN
BRAVE_API_KEY=$BRAVE_API_KEY
ENVEOF

chmod 600 "$INSTALL_DIR/.env"
echo -e "  ${GREEN}✅ .env 생성 완료 (권한: 600)${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 7: Docker 빌드 & 실행
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${CYAN}[7/7] Docker 빌드 & 실행${NC}"
echo -e "  ${YELLOW}⏳ 첫 빌드는 3~5분 소요됩니다...${NC}"
echo ""

cd "$INSTALL_DIR"

# docker 그룹 권한으로 실행
if groups | grep -q docker; then
    docker compose up -d --build 2>&1 | tail -5
else
    sudo docker compose up -d --build 2>&1 | tail -5
fi

# 시작 대기
echo ""
echo -e "  ${YELLOW}⏳ 게이트웨이 시작 대기 중...${NC}"
sleep 10

# 헬스체크
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' danbam-team 2>/dev/null || echo "not_found")

if [ "$CONTAINER_STATUS" = "running" ]; then
    echo -e "  ${GREEN}✅ 컨테이너 실행 중!${NC}"
else
    echo -e "  ${YELLOW}⚠️  컨테이너 상태: $CONTAINER_STATUS${NC}"
    echo -e "  ${YELLOW}    로그 확인: docker logs danbam-team${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 완료!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${BOLD}🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}   설치 완료!${NC}"
echo ""
echo -e "  팀: ${BOLD}$TEAM_NAME${NC}"
echo -e "  프로젝트: ${BOLD}$PROJECT_NAME${NC}"
echo ""
echo -e "  📡 게이트웨이: ${BLUE}http://localhost:18789${NC}"
[ -n "$DISCORD_BOT_TOKEN" ] && echo -e "  💬 Discord: 봇 연결됨"
echo ""
echo -e "  ${BOLD}유용한 명령어:${NC}"
echo -e "  로그 확인:    ${CYAN}docker logs -f danbam-team${NC}"
echo -e "  재시작:       ${CYAN}cd $INSTALL_DIR && docker compose restart${NC}"
echo -e "  중지:         ${CYAN}cd $INSTALL_DIR && docker compose down${NC}"
echo -e "  CLI 접속:     ${CYAN}docker exec -it danbam-team openclaw chat manager${NC}"
echo -e "  설정 변경:    ${CYAN}vi $INSTALL_DIR/.env${NC}"
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
