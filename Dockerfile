FROM ubuntu:24.04

LABEL maintainer="mrmisterio-ai"
LABEL description="단밤 AI 개발팀 - OpenClaw 멀티에이전트 팀 부트스트랩"

# 환경변수 기본값
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/ubuntu
ENV NODE_VERSION=22
ENV TEAM_NAME="단밤"
ENV PROJECT_NAME="새 프로젝트"

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    sudo \
    vim \
    jq \
    python3 \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 설치
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# PM2 + OpenClaw 전역 설치
RUN npm install -g pm2 openclaw@latest

# ubuntu 유저 생성
RUN useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu
WORKDIR /home/ubuntu

# cli-proxy-api 디렉토리 구조
RUN mkdir -p /home/ubuntu/cli-proxy-api \
    /home/ubuntu/.cli-proxy-api \
    /home/ubuntu/.openclaw \
    /home/ubuntu/openclaw-workspaces/manager/skills \
    /home/ubuntu/openclaw-workspaces/manager/memory \
    /home/ubuntu/openclaw-workspaces/server-dev/skills \
    /home/ubuntu/openclaw-workspaces/frontend-dev/skills \
    /home/ubuntu/openclaw-workspaces/uiux-designer/skills \
    /home/ubuntu/projects

# cli-proxy-api 바이너리 복사
COPY --chown=ubuntu:ubuntu cli-proxy-api/cli-proxy-api /home/ubuntu/cli-proxy-api/cli-proxy-api
COPY --chown=ubuntu:ubuntu cli-proxy-api/config.template.yaml /home/ubuntu/cli-proxy-api/config.template.yaml
RUN chmod +x /home/ubuntu/cli-proxy-api/cli-proxy-api

# OpenClaw 설정 템플릿
COPY --chown=ubuntu:ubuntu config/openclaw.template.json /home/ubuntu/.openclaw/openclaw.template.json

# 워크스페이스 복사 (스킬 + 템플릿)
COPY --chown=ubuntu:ubuntu workspaces/ /home/ubuntu/openclaw-workspaces/

# 설치 스크립트
COPY --chown=ubuntu:ubuntu scripts/entrypoint.sh /home/ubuntu/entrypoint.sh
COPY --chown=ubuntu:ubuntu scripts/setup.sh /home/ubuntu/setup.sh
RUN chmod +x /home/ubuntu/entrypoint.sh /home/ubuntu/setup.sh

# 포트
EXPOSE 18789 3456

ENTRYPOINT ["/home/ubuntu/entrypoint.sh"]
