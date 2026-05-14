#!/bin/sh
set -e

echo "⏳ 等待面板数据库初始化并注入账号配置..."

# 通过环境变量设置账号密码（默认 admin / admin）
max_retries="${XUI_INIT_RETRIES:-30}"
retry_interval="${XUI_INIT_INTERVAL:-1}"
attempt=1

while [ "$attempt" -le "$max_retries" ]; do
  if /usr/local/x-ui/x-ui setting -username "${XUI_USERNAME:-admin}" -password "${XUI_PASSWORD:-admin}" >/dev/null 2>&1; then
    echo "✅ 账号密码已注入"
    break
  fi

  sleep "$retry_interval"
  attempt=$((attempt + 1))
done

if [ "$attempt" -gt "$max_retries" ]; then
  echo "⚠️ 面板初始化等待超时，继续启动 3x-ui"
fi

# 启动 3x-ui 主程序
exec /usr/local/x-ui/x-ui
