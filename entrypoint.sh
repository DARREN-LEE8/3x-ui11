#!/bin/sh
set -e

echo "⏳ 等待面板数据库初始化..."
sleep 5

# 通过环境变量设置账号密码（默认 admin / admin）
/usr/local/x-ui/x-ui setting -username "${XUI_USERNAME:-admin}" -password "${XUI_PASSWORD:-admin}" >/dev/null 2>&1 || true

echo "✅ 账号密码已注入: ${XUI_USERNAME:-admin} / ${XUI_PASSWORD:-admin}"

# 启动 3x-ui 主程序
exec /usr/local/x-ui/x-ui
