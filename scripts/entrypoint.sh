#!/bin/bash
set -e

echo ""
echo "🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   단밤 AI 개발팀 부트스트랩 v2.0 (ChatGPT)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. 환경변수 검증
# ============================================

# 필수: OPENAI_API_KEY
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ 오류: OPENAI_API_KEY가 필요합니다."
    echo ""
    echo "  OpenAI API 키를 발급받으세요:"
    echo "    https://platform.openai.com/api-keys"
    echo ""
    echo "  사용법:"
    echo "    docker run -e OPENAI_API_KEY='sk-proj-...' ..."
    echo ""
    exit 1
fi

echo "[1/4] 환경변수 확인"
echo "  ✅ OpenAI API 키: 설정됨"
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
# 2. OpenClaw 설정 생성
# ============================================
echo "[2/4] OpenClaw 설정 생성"

# 템플릿에서 설정 생성
TEMPLATE=/home/ubuntu/.openclaw/openclaw.template.json
OUTPUT=/home/ubuntu/.openclaw/openclaw.json

# jq로 템플릿 치환
DISCORD_ENABLED="false"
if [ -n "$DISCORD_BOT_TOKEN" ]; then
    DISCORD_ENABLED="true"
fi

cat "$TEMPLATE" | jq \
    --arg openai_key "$OPENAI_API_KEY" \
    --arg discord_token "${DISCORD_BOT_TOKEN:-}" \
    --arg discord_user "${DISCORD_USER_ID:-}" \
    --arg discord_guild "${DISCORD_GUILD_ID:-}" \
    --arg brave_key "${BRAVE_API_KEY:-}" \
    --argjson discord_enabled "$DISCORD_ENABLED" \
    '
    .env.OPENAI_API_KEY = $openai_key |
    .env.DISCORD_BOT_TOKEN = $discord_token |
    .env.BRAVE_API_KEY = $brave_key |
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

echo "  ✅ openclaw.json 생성 완료"
echo ""

# ============================================
# 3. SOUL 템플릿 치환
# ============================================
echo "[3/4] 팀 캐릭터 생성"

WORKSPACES="/home/ubuntu/openclaw-workspaces"

for agent_dir in manager server-dev frontend-dev uiux-designer researcher design-critic; do
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
# 4. 서비스 시작
# ============================================
echo "[4/4] 서비스 시작"

# GitHub 인증 (토큰 있으면)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null && \
        echo "  ✅ GitHub 인증 완료" || \
        echo "  ⚠️  GitHub 인증 실패 (gh CLI 없거나 토큰 문제)"
fi

# OpenClaw 게이트웨이 시작
echo "  🚀 OpenClaw 게이트웨이 시작 중..."
export OPENAI_API_KEY
[ -n "$DISCORD_BOT_TOKEN" ] && export DISCORD_BOT_TOKEN
[ -n "$BRAVE_API_KEY" ] && export BRAVE_API_KEY

echo ""
echo "🌰 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   팀 \"${TEAM_NAME:-단밤}\" 준비 완료!"
echo ""
echo "   📡 게이트웨이: http://localhost:18789"
[ -n "$DISCORD_BOT_TOKEN" ] && echo "   💬 Discord: 봇 연결됨"
echo ""
echo "   에이전트 6명:"
echo "     🔥 매니저 (GPT-4o)"
echo "     💪 백엔드 개발자 (GPT-4o-mini)"
echo "     ✨ 프론트엔드 개발자 (GPT-4o-mini)"
echo "     🎨 UI/UX 디자이너 (GPT-4o-mini)"
echo "     🔍 리서처 (GPT-4o-mini)"
echo "     🎯 디자인 크리틱 (GPT-4o-mini)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# OpenClaw을 포그라운드로 실행 (컨테이너 메인 프로세스)
exec node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789
