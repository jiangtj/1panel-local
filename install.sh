#!/bin/bash
#
# 1panel-local 一键部署脚本
#
# 下载本仓库的归档包，解压后把其中的各个本地应用目录
# 移动到 1Panel 的本地应用目录（默认 /opt/1panel/resource/apps/local）。
#
# 支持两个代码来源，默认优先使用国内仓库（CNB），失败时自动回退 GitHub：
#   国内（CNB）：https://cnb.cool/jiangtj/1panel-local
#   GitHub：     https://github.com/jiangtj/1panel-local
#
# 直接运行（需要 root 权限写入 /opt），国内推荐：
#   curl -fsSL https://cnb.cool/jiangtj/1panel-local/-/git/raw/master/install.sh | sudo bash
#
# 或从 GitHub 获取：
#   curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh | sudo bash
#
# 可覆盖的环境变量：
#   SOURCE    代码来源：auto（默认，先 CNB 再 GitHub）/ cnb / github
#   BRANCH    下载的分支，默认 master
#   DEST_DIR  目标本地应用目录，默认 /opt/1panel/resource/apps/local
#
set -euo pipefail

REPO="${REPO:-jiangtj/1panel-local}"
SOURCE="${SOURCE:-auto}"
BRANCH="${BRANCH:-master}"
DEST_DIR="${DEST_DIR:-/opt/1panel/resource/apps/local}"

log() { printf '==> %s\n' "$*"; }
err() { printf '错误：%s\n' "$*" >&2; }

# 各来源的归档包地址
archive_url() {
    case "$1" in
        cnb)    printf 'https://cnb.cool/%s/-/git/archive/%s.zip\n' "$REPO" "$BRANCH" ;;
        github) printf 'https://github.com/%s/archive/refs/heads/%s.zip\n' "$REPO" "$BRANCH" ;;
        *)      return 1 ;;
    esac
}

# 1. 写入 /opt 需要 root 权限
if [ "$(id -u)" -ne 0 ]; then
    err "请使用 root 用户运行（例如：curl -fsSL <脚本地址> | sudo bash）"
    exit 1
fi

# 2. 确定来源顺序
case "$SOURCE" in
    auto|"") MIRRORS="cnb github" ;;
    cnb)     MIRRORS="cnb" ;;
    github)  MIRRORS="github" ;;
    *)       err "SOURCE 仅支持 auto / cnb / github，当前为：$SOURCE"; exit 1 ;;
esac

# 3. 准备临时目录，退出时自动清理
command -v mktemp >/dev/null 2>&1 || { err "未找到 mktemp"; exit 1; }
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 4. 下载归档包
download() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --connect-timeout 15 --retry 2 "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$out" --timeout=15 --tries=2 "$url"
    else
        err "未找到 curl 或 wget，请先安装其中之一"
        return 1
    fi
}

# 5. 解压归档包
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

# 6. 定位仓库根目录（即直接包含各应用目录的那一层）
#    CNB 归档解压后没有顶层目录，应用目录直接位于解压根目录；
#    GitHub 归档解压后形如 1panel-local-master/ 的单层目录。
find_repo_root() {
    local dir="$1" sub app
    for sub in "$dir"/*/; do
        [ -f "${sub}data.yml" ] && { printf '%s\n' "$dir"; return 0; }
    done
    for sub in "$dir"/*/; do
        for app in "${sub}"*/; do
            [ -f "${app}data.yml" ] && { printf '%s\n' "${sub%/}"; return 0; }
        done
    done
    return 1
}

SRC_DIR=""
for mirror in $MIRRORS; do
    url="$(archive_url "$mirror")" || continue
    work="$TMP_DIR/$mirror"
    rm -rf "$work"
    mkdir -p "$work"

    log "从 $mirror 下载归档包：$url"
    if ! download "$url" "$work/repo.zip"; then
        err "$mirror 下载失败"
        rm -rf "$work"
        continue
    fi

    if ! extract_zip "$work/repo.zip" "$work"; then
        rm -rf "$work"
        continue
    fi

    rm -f "$work/repo.zip"
    if SRC_DIR="$(find_repo_root "$work")"; then
        log "已从 $mirror 获取仓库内容"
        break
    fi

    err "$mirror 归档中未找到应用目录"
    SRC_DIR=""
    rm -rf "$work"
done

if [ -z "$SRC_DIR" ] || [ ! -d "$SRC_DIR" ]; then
    err "下载或解压失败，请检查网络后重试（可用 SOURCE=github 指定来源）"
    exit 1
fi

mkdir -p "$DEST_DIR"

# 7. 逐个部署应用：含 data.yml 的顶层目录即一个本地应用
found=0
for app_dir in "$SRC_DIR"/*/; do
    app_dir="${app_dir%/}"
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
  2. 在列表中找到目标应用（如 Clash Rule、Subconverter、Fast Note Sync、magpie、Cloudflare Mesh、EasyTier Web）直接安装
EOF
