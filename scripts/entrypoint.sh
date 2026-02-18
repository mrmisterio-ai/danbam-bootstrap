#!/bin/bash
set -e

echo ""
echo "🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   단밤 AI 개발팀 부트스트랩 v1.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. 환경변수 검증
# ============================================

# 필수: ANTHROPIC_COOKIE (Claude Max 구독 OAuth)
if [ -z "$ANTHROPIC_COOKIE" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 오류: ANTHROPIC_COOKIE 또는 ANTHROPIC_API_KEY가 필요합니다."
    echo ""
    echo "  방법 1) Claude Max 구독자 (OAuth 프록시):"
    echo "    docker run -e ANTHROPIC_COOKIE='sessionKey=sk-ant-xxx...' ..."
    echo ""
    echo "  방법 2) Anthropic API 키:"
    echo "    docker run -e ANTHROPIC_API_KEY='sk-ant-api03-xxx...' ..."
    echo ""
    exit 1
fi

echo "[1/5] 환경변수 확인"
echo "  ✅ Claude 인증: $([ -n "$ANTHROPIC_COOKIE" ] && echo 'OAuth (Max 구독)' || echo 'API 키')"
echo "  $([ -n "$DISCORD_BOT_TOKEN" ] && echo '✅' || echo '⬜') Discord 봇: $([ -n "$DISCORD_BOT_TOKEN" ] && echo '설정됨' || echo '미설정 (나중에 가능)')"
echo "  $([ -n "$DISCORD_USER_ID" ] && echo '✅' || echo '⬜') Discord 사용자 ID: $([ -n "$DISCORD_USER_ID" ] && echo "$DISCORD_USER_ID" || echo '미설정')"
echo "  $([ -n "$DISCORD_GUILD_ID" ] && echo '✅' || echo '⬜') Discord 서버 ID: $([ -n "$DISCORD_GUILD_ID" ] && echo "$DISCORD_GUILD_ID" || echo '미설정')"
echo "  $([ -n "$FIGMA_TOKEN" ] && echo '✅' || echo '⬜') Figma 토큰: $([ -n "$FIGMA_TOKEN" ] && echo '설정됨' || echo '미설정')"
echo "  $([ -n "$GITHUB_TOKEN" ] && echo '✅' || echo '⬜') GitHub 토큰: $([ -n "$GITHUB_TOKEN" ] && echo '설정됨' || echo '미설정')"
echo "  $([ -n "$BRAVE_API_KEY" ] && echo '✅' || echo '⬜') Brave Search: $([ -n "$BRAVE_API_KEY" ] && echo '설정됨' || echo '미설정')"
echo "  📋 팀 이름: ${TEAM_NAME:-단밤}"
echo "  📋 프로젝트: ${PROJECT_NAME:-새 프로젝트}"
echo ""

# ============================================
# 2. cli-proxy-api 설정 (OAuth 모드일 때만)
# ============================================
echo "[2/5] Claude 프록시 설정"

if [ -n "$ANTHROPIC_COOKIE" ]; then
    # OAuth 프록시 모드
    cp /home/ubuntu/cli-proxy-api/config.template.yaml /home/ubuntu/cli-proxy-api/config.yaml
    
    # claude-user.json 생성 (OAuth 인증)
    cat > /home/ubuntu/.cli-proxy-api/claude-user.json << CEOF
{
  "cookie": "$ANTHROPIC_COOKIE"
}
CEOF
    
    PROXY_API_KEY="sk-proxy-local-00000000000000000000000000000000000000000000"
    PROXY_BASE_URL="http://localhost:3456/v1"
    USE_PROXY=true
    echo "  ✅ cli-proxy-api 설정 완료 (OAuth 모드)"
else
    # 직접 API 키 모드 — 프록시 불필요
    PROXY_API_KEY="$ANTHROPIC_API_KEY"
    PROXY_BASE_URL="https://api.anthropic.com/v1"
    USE_PROXY=false
    echo "  ✅ Anthropic API 직접 연결 모드"
fi
echo ""

# ============================================
# 3. OpenClaw 설정 생성
# ============================================
echo "[3/5] OpenClaw 설정 생성"

# 템플릿에서 설정 생성
TEMPLATE=/home/ubuntu/.openclaw/openclaw.template.json
OUTPUT=/home/ubuntu/.openclaw/openclaw.json

# jq로 템플릿 치환
DISCORD_ENABLED="false"
if [ -n "$DISCORD_BOT_TOKEN" ]; then
    DISCORD_ENABLED="true"
fi

cat "$TEMPLATE" | jq \
    --arg proxy_key "$PROXY_API_KEY" \
    --arg proxy_url "${PROXY_BASE_URL%/v1}" \
    --arg openai_key "$PROXY_API_KEY" \
    --arg openai_url "$PROXY_BASE_URL" \
    --arg discord_token "${DISCORD_BOT_TOKEN:-}" \
    --arg discord_user "${DISCORD_USER_ID:-}" \
    --arg discord_guild "${DISCORD_GUILD_ID:-}" \
    --arg brave_key "${BRAVE_API_KEY:-}" \
    --argjson discord_enabled "$DISCORD_ENABLED" \
    '
    .env.OPENAI_API_KEY = $openai_key |
    .env.OPENAI_BASE_URL = $openai_url |
    .env.DISCORD_BOT_TOKEN = $discord_token |
    .env.BRAVE_API_KEY = $brave_key |
    .models.providers."claude-proxy".baseUrl = $proxy_url |
    .models.providers."claude-proxy".apiKey = $proxy_key |
    .models.providers."claude-proxy".api = $proxy_key |
    .channels.discord.enabled = $discord_enabled |
    .channels.discord.token = $discord_token |
    (if $discord_user != "" then
        .channels.discord.allowFrom = [$discord_user] |
        (if $discord_guild != "" then
            .channels.discord.guilds[$discord_guild] = {
                "requireMention": true,
                "users": [$discord_user]
            }
        else . end)
    else . end)
    ' > "$OUTPUT"

# API 직접 연결 모드면 provider 이름 변경
if [ "$USE_PROXY" = "false" ]; then
    # claude-proxy를 anthropic으로 변경하는 건 복잡하므로, 
    # proxy 이름은 유지하되 URL만 Anthropic으로 설정 (위에서 이미 함)
    echo "  ℹ️  API 직접 연결: provider 이름은 'claude-proxy'로 유지 (URL만 변경)"
fi

echo "  ✅ openclaw.json 생성 완료"
echo ""

# ============================================
# 4. SOUL 템플릿 치환
# ============================================
echo "[4/5] 팀 캐릭터 생성"

WORKSPACES="/home/ubuntu/openclaw-workspaces"

for agent_dir in manager server-dev frontend-dev uiux-designer; do
    for tpl_file in "$WORKSPACES/$agent_dir"/*.template.md; do
        [ -f "$tpl_file" ] || continue
        target="${tpl_file%.template.md}.md"
        sed \
            -e "s/{{TEAM_NAME}}/${TEAM_NAME:-단밤}/g" \
            -e "s/{{PROJECT_NAME}}/${PROJECT_NAME:-새 프로젝트}/g" \
            "$tpl_file" > "$target"
    done
done

echo "  ✅ SOUL.md 생성 (팀: ${TEAM_NAME:-단밤}, 프로젝트: ${PROJECT_NAME:-새 프로젝트})"
echo ""

# ============================================
# 5. 서비스 시작
# ============================================
echo "[5/5] 서비스 시작"

# cli-proxy-api 시작 (OAuth 모드일 때만)
if [ "$USE_PROXY" = "true" ]; then
    cd /home/ubuntu/cli-proxy-api
    ./cli-proxy-api -config config.yaml &
    PROXY_PID=$!
    sleep 2
    
    # 프록시 헬스체크
    if curl -s http://localhost:3456 > /dev/null 2>&1; then
        echo "  ✅ cli-proxy-api 시작 (PID: $PROXY_PID)"
    else
        echo "  ⚠️  cli-proxy-api 시작했지만 응답 없음 — 로그 확인 필요"
    fi
fi

# GitHub 인증 (토큰 있으면)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null && \
        echo "  ✅ GitHub 인증 완료" || \
        echo "  ⚠️  GitHub 인증 실패 (gh CLI 없거나 토큰 문제)"
fi

# OpenClaw 게이트웨이 시작
echo "  🚀 OpenClaw 게이트웨이 시작 중..."
export OPENAI_API_KEY="$PROXY_API_KEY"
export OPENAI_BASE_URL="$PROXY_BASE_URL"
[ -n "$DISCORD_BOT_TOKEN" ] && export DISCORD_BOT_TOKEN
[ -n "$BRAVE_API_KEY" ] && export BRAVE_API_KEY

echo ""
echo "🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   팀 \"${TEAM_NAME:-단밤}\" 준비 완료!"
echo ""
echo "   📡 게이트웨이: http://localhost:18789"
[ -n "$DISCORD_BOT_TOKEN" ] && echo "   💬 Discord: 봇 연결됨"
echo ""
echo "   에이전트 4명:"
echo "     🔥 매니저 (Opus 4.6)"
echo "     💪 백엔드 개발자 (Sonnet 4.5)"
echo "     ✨ 프론트엔드 개발자 (Sonnet 4.5)"
echo "     🎨 UI/UX 디자이너 (Sonnet 4.5)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# OpenClaw을 포그라운드로 실행 (컨테이너 메인 프로세스)
exec node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789
