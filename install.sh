#!/bin/bash
#
# 1panel-local 一键部署脚本
#
# 从 GitHub 下载本仓库的归档包，解压后把其中的各个本地应用目录
# 移动到 1Panel 的本地应用目录（默认 /opt/1panel/resource/apps/local）。
#
# 直接运行（需要 root 权限写入 /opt）：
#   curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh | sudo bash
#
# 可覆盖的环境变量：
#   BRANCH    下载的分支，默认 master
#   DEST_DIR  目标本地应用目录，默认 /opt/1panel/resource/apps/local
#
set -euo pipefail

REPO="jiangtj/1panel-local"
BRANCH="${BRANCH:-master}"
DEST_DIR="${DEST_DIR:-/opt/1panel/resource/apps/local}"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.zip"

log() { printf '==> %s\n' "$*"; }
err() { printf '错误：%s\n' "$*" >&2; }

# 1. 写入 /opt 需要 root 权限
if [ "$(id -u)" -ne 0 ]; then
    err "请使用 root 用户运行（例如：curl -fsSL <脚本地址> | sudo bash）"
    exit 1
fi

# 2. 准备临时目录，退出时自动清理
command -v mktemp >/dev/null 2>&1 || { err "未找到 mktemp"; exit 1; }
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 3. 下载归档包
download() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$out" "$url"
    else
        err "未找到 curl 或 wget，请先安装其中之一"
        return 1
    fi
}

# 4. 解压归档包
extract_zip() {
    local zip="$1" dest="$2"
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "$zip" -d "$dest"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m zipfile -e "$zip" "$dest"
    elif command -v busybox >/dev/null 2>&1; then
        busybox unzip -q "$zip" -d "$dest"
    else
        err "未找到 unzip / python3 / busybox，无法解压归档"
        return 1
    fi
}

log "下载归档包：$ZIP_URL"
download "$ZIP_URL" "$TMP_DIR/repo.zip"

log "解压归档包"
extract_zip "$TMP_DIR/repo.zip" "$TMP_DIR"

# 归档解压后得到形如 1panel-local-master 的顶层目录
SRC_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
[ -n "$SRC_DIR" ] || { err "解压后未找到仓库目录"; exit 1; }

mkdir -p "$DEST_DIR"

# 5. 逐个部署应用：含 data.yml 的顶层目录即一个本地应用
found=0
for app_dir in "$SRC_DIR"/*; do
    [ -d "$app_dir" ] || continue
    [ -f "$app_dir/data.yml" ] || continue
    app="$(basename "$app_dir")"
    log "部署应用：$app -> $DEST_DIR/$app"
    rm -rf "${DEST_DIR:?}/$app"
    cp -a "$app_dir" "$DEST_DIR/$app"
    found=$((found + 1))
done

if [ "$found" -eq 0 ]; then
    err "未在归档中找到任何应用目录"
    exit 1
fi

log "完成，共部署 $found 个应用"
cat <<EOF

下一步：
  1. 打开 1Panel「应用商店 → 本地应用」，点击「更新应用列表」
  2. 在列表中找到目标应用（如 Clash Rule、Subconverter、Fast Note Sync、magpie）直接安装
EOF