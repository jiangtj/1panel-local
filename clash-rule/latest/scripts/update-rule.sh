#!/bin/bash
#
# 拉取/更新 ACL4SSR 规则，并生成本地规则配置。
#
# 逻辑来源（原 clash-subconverter 组合包脚本）：
#   在 ACL4SSR 仓库目录中 git pull；
#   将 Clash/config/ACL4SSR_Online_Full.ini 复制为 ACL4SSR_Local_Full.ini；
#   把规则中的 raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash 替换为本地规则网页地址。
#
# 1Panel 打包改动：仓库目录为应用安装目录下的 data/acl4ssr，
# 该目录同时通过 ./data/acl4ssr/Clash 挂载给 nginx 容器提供规则文件。
#
# 用法：
#   安装初始化：由 scripts/init.sh 自动调用（首次会克隆仓库）。
#   每日更新：在 1Panel「计划任务」中新建 Shell 脚本任务，每天执行本脚本。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"

REPO_URL="https://github.com/ACL4SSR/ACL4SSR.git"
REPO_DIR="$APP_DIR/data/acl4ssr"
WEB_ROOT="$REPO_DIR/Clash"

# 规则文件的对外访问地址，取 1Panel 安装表单中的「规则服务地址」与「规则网页端口」；
# 纯 IP/域名时拼接规则网页端口，含 http(s):// 时直接作为规则服务地址；
# 也可在执行前 export RULE_HOST / RULE_PORT 覆盖。
RULE_HOST="${RULE_HOST:-}"
RULE_PORT="${RULE_PORT:-}"
if [ -f "$APP_DIR/.env" ]; then
    if [ -z "$RULE_HOST" ]; then
        RULE_HOST="$(sed -n 's/^RULE_HOST=//p' "$APP_DIR/.env" | head -n1)"
    fi
    if [ -z "$RULE_PORT" ]; then
        RULE_PORT="$(sed -n 's/^PANEL_APP_PORT_HTTP=//p' "$APP_DIR/.env" | head -n1)"
    fi
fi
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

# 1. 首次克隆，之后仅拉取更新
if [ -d "$REPO_DIR/.git" ]; then
    echo "更新 ACL4SSR 规则仓库：$REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only
else
    echo "首次拉取 ACL4SSR 规则仓库到：$REPO_DIR"
    rm -rf "$REPO_DIR"
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

# 2. 生成本地规则配置
SOURCE_INI="$WEB_ROOT/config/ACL4SSR_Online_Full.ini"
TARGET_INI="$WEB_ROOT/config/ACL4SSR_Local_Full.ini"
if [ ! -f "$SOURCE_INI" ]; then
    echo "未找到 $SOURCE_INI，ACL4SSR 仓库目录结构可能已调整" >&2
    exit 1
fi
cp -f "$SOURCE_INI" "$TARGET_INI"
sed -i "s#https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash#${RULE_BASE}#ig" "$TARGET_INI"
echo "已生成 $TARGET_INI（规则地址：$RULE_BASE）"
