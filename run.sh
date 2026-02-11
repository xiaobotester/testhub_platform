#!/bin/bash
set -e

BASE_DIR="/testhub"
cd "$BASE_DIR"

# 创建网络
docker network create testhub-net 2>/dev/null || echo "Network already exists"

# 1. 构建后端镜像
echo "Building backend image..."
docker build -f Dockerfile.backend -t testhub-backend:latest .

# 2. 构建前端镜像
echo "Building frontend image..."
docker build -f Dockerfile.frontend -t testhub-frontend:latest .

# 3. 停止并删除旧容器
docker stop testhub-backend testhub-nginx testhub-selenium-chrome testhub-selenium-firefox 2>/dev/null || true
docker rm testhub-backend testhub-nginx testhub-selenium-chrome testhub-selenium-firefox 2>/dev/null || true

# 3.5. 启动 Selenium Chrome
echo "Starting Selenium Chrome container..."
docker run -d --name testhub-selenium-chrome \
  --restart=always \
  --network testhub-net \
  -p 4444:4444 \
  selenium/standalone-chrome:latest

# 3.6. 启动 Selenium Firefox
echo "Starting Selenium Firefox container..."
docker run -d --name testhub-selenium-firefox \
  --restart=always \
  --network testhub-net \
  -p 4445:4444 \
  selenium/standalone-firefox:latest

# 4. 启动后端
echo "Starting backend container..."
docker run -d --name testhub-backend \
  --restart=always \
  -p 8000:8000 \
  --network testhub-net \
  -v "$BASE_DIR/.env:/app/.env:ro" \
  -v "$BASE_DIR/media:/app/media" \
  -v "$BASE_DIR/logs:/app/logs" \
  -v "$BASE_DIR/static:/app/static" \
  testhub-backend:latest

# 5. 启动前端（nginx）
echo "Starting frontend container..."
docker run -d \
  --name testhub-nginx \
  --restart=always \
  --network testhub-net \
  -p 80:80 \
  -v /testhub/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  -v /testhub/media:/app/media:ro \
  -v /testhub/static:/app/static:ro \
  testhub-frontend:latest

echo "TestHub is running -> http://localhost"