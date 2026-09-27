#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/tech-learn"
BACKEND_SERVICE="zero-to-tech-backend"
DOMAIN="xn--btvt3a.online"

cd "$APP_DIR"

echo "==> [1/5] 检查工作区"
if [ -n "$(git status --porcelain)" ]; then
    echo "ERROR: 有未提交的改动，请先处理"
    git status --short
    exit 1
fi

BEFORE=$(git rev-parse HEAD)

echo "==> [2/5] 拉取最新代码"
git pull --rebase

AFTER=$(git rev-parse HEAD)

if [ "$BEFORE" = "$AFTER" ]; then
    echo "没有新提交，退出"
    exit 0
fi

CHANGED=$(git diff --name-only "$BEFORE" "$AFTER")
echo "变更文件："
echo "$CHANGED"

echo "==> [3/5] 构建前端"
if echo "$CHANGED" | grep -qE '^(app/|components/|public/|data/|package|next\.config|\.env)'; then
    npm run build
else
    echo "前端无变化，跳过构建"
fi

echo "==> [4/5] 重启后端"
if echo "$CHANGED" | grep -qE '^backend/'; then
    sudo systemctl restart "$BACKEND_SERVICE"
    sleep 2
else
    echo "后端无变化，跳过重启"
fi

echo "==> [5/5] 健康检查"
curl -sf "http://127.0.0.1:8000/api/profile" > /dev/null || { echo "后端健康检查失败"; exit 1; }
curl -sfk "https://127.0.0.1/api/profile" -H "Host: $DOMAIN" > /dev/null || { echo "反代健康检查失败"; exit 1; }
curl -sfk "https://127.0.0.1/" -H "Host: $DOMAIN" > /dev/null || { echo "前端健康检查失败"; exit 1; }

echo "部署完成 ✅"
