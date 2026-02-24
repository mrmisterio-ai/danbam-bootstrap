# TOOLS.md - Local Notes

## 대시보드 서버
- IP: YOUR_SERVER_IP
- PM2 프로세스: danbam-api
- 포트: 3000

## 데이터 파일 경로
- projects: /home/ubuntu/projects/backend/data/projects.json
- todos: /home/ubuntu/projects/backend/data/todos.json
- research: /home/ubuntu/projects/backend/data/research.json
- logs: /home/ubuntu/projects/backend/data/logs.json

## 리서치 HTML 디렉토리
- /home/ubuntu/projects/backend/public/research/

## 빌드 & 배포 명령
```bash
cd /home/ubuntu/projects/frontend && npx vite build
cp -r dist/* /home/ubuntu/projects/backend/public/
pm2 restart danbam-api
```

## GitHub
- backend: your-org/backend
- frontend: your-org/frontend
- manager-docs: your-org/manager-docs
