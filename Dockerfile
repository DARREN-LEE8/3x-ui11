# 使用官方最新版镜像
FROM ghcr.io/mhsanaei/3x-ui:latest

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 替换默认启动入口
ENTRYPOINT ["/entrypoint.sh"]
