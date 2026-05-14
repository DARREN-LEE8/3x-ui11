#!/bin/sh
set -e

echo "⏳ 等待面板数据库初始化并注入账号配置..."

# 通过环境变量设置账号密码（默认 admin / admin）
username="${XUI_USERNAME:-admin}"
password="${XUI_PASSWORD:-admin}"

if [ -z "${XUI_USERNAME:-}" ] || [ -z "${XUI_PASSWORD:-}" ]; then
  echo "⚠️ 未提供 XUI_USERNAME 或 XUI_PASSWORD，使用默认凭据"
fi

max_retries="${XUI_INIT_RETRIES:-30}"
retry_interval="${XUI_INIT_INTERVAL:-1}"
attempt=1

while [ "$attempt" -le "$max_retries" ]; do
  if /usr/local/x-ui/x-ui setting -username "$username" -password "$password" >/dev/null 2>&1; then
    echo "✅ 账号密码已注入"
    break
  fi

  sleep "$retry_interval"
  attempt=$((attempt + 1))
done

if [ "$attempt" -gt "$max_retries" ]; then
  echo "❌ 面板初始化等待超时，账号密码注入失败，终止启动"
  exit 1
fi

# 启动 3x-ui 主程序
exec /usr/local/x-ui/x-ui
