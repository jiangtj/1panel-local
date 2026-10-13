#!/bin/sh
#
# 容器内定时更新服务（rule-updater）入口脚本。
#
# 逻辑与宿主机 scripts/update-rule.sh 一致：拉取 ACL4SSR 仓库，
# 并重新生成 Clash/config/ACL4SSR_Local_Full.ini。
#
# 用法：
#   /scripts/update-rule-cron.sh install   安装 busybox cron 任务、先同步一次并常驻
#   /scripts/update-rule-cron.sh update    只执行一次更新
#
# 可通过环境变量 CRON_SCHEDULE 覆盖执行周期（默认每天 03:00）。
set -eu

REPO_DIR="/data/acl4ssr"
WEB_ROOT="$REPO_DIR/Clash"
REPO_URL="https://github.com/ACL4SSR/ACL4SSR.git"
SELF="/scripts/update-rule-cron.sh"
CRON_FILE="/etc/crontabs/root"
CRON_SCHEDULE="${CRON_SCHEDULE:-0 3 * * *}"

RULE_HOST="${RULE_HOST:-}"
case "$RULE_HOST" in
    http://*|https://*)
        # 已含 http(s)://，直接作为规则服务地址
        RULE_BASE="$RULE_HOST"
        ;;
    *)
        # 纯 IP/域名，按原逻辑拼接端口
        RULE_PORT="${RULE_PORT:-20666}"
        RULE_BASE="http://${RULE_HOST}:${RULE_PORT}"
        ;;
esac

update_rules() {
    if [ -d "$REPO_DIR/.git" ]; then
        echo "[rule-updater] 更新 ACL4SSR 规则仓库"
        git -C "$REPO_DIR" pull --ff-only
    else
        echo "[rule-updater] 首次拉取 ACL4SSR 规则仓库"
        rm -rf "$REPO_DIR"
        git clone --depth 1 "$REPO_URL" "$REPO_DIR"
    fi

    SOURCE_INI="$WEB_ROOT/config/ACL4SSR_Online_Full.ini"
    TARGET_INI="$WEB_ROOT/config/ACL4SSR_Local_Full.ini"
    if [ ! -f "$SOURCE_INI" ]; then
        echo "[rule-updater] 未找到 $SOURCE_INI，ACL4SSR 仓库目录结构可能已调整" >&2
        return 1
    fi
    cp -f "$SOURCE_INI" "$TARGET_INI"
    sed -i "s#https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash#${RULE_BASE}#ig" "$TARGET_INI"
    echo "[rule-updater] 已生成 $TARGET_INI（规则地址：$RULE_BASE）"
}

install_cron() {
    if [ -f /etc/alpine-release ]; then
        apk add --no-cache git >/dev/null
    else
        echo "[rule-updater] 非 Alpine 环境，请确认镜像内已安装 git" >&2
    fi

    mkdir -p /etc/crontabs
    grep -v "$SELF" "$CRON_FILE" 2>/dev/null > /tmp/cron.root || true
    echo "$CRON_SCHEDULE $SELF update >> /proc/1/fd/1 2>&1" >> /tmp/cron.root
    mv /tmp/cron.root "$CRON_FILE"
    chmod 600 "$CRON_FILE"

    # 启动时先同步一次，避免规则目录为空
    update_rules || true

    echo "[rule-updater] 定时任务已生效：$CRON_SCHEDULE（每天同步 ACL4SSR 规则）"
    exec crond -f -l 8
}

case "${1:-}" in
    install)
        install_cron
        ;;
    update)
        update_rules
        ;;
    *)
        echo "用法：$0 {install|update}" >&2
        exit 1
        ;;
esac
