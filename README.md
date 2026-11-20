# 1panel-local
1panel 的一些自定义的应用

- **[Clash Rule](./clash-rule/README.md)**：ACL4SSR 本地规则网页服务，供 Clash / mihomo 客户端拉取分流规则。
- **[Subconverter](./subconverter/README.md)**：订阅转换服务，把各类代理订阅转换为 Clash 等客户端可用的配置。
- **[Fast Note Sync](./fns/README.md)**：自托管的 Obsidian 笔记库同步服务，提供网页管理后台、历史版本、回收站、分享链接与 REST API / MCP。
- **[Magpie](./magpie/README.md)**：本地模型网关，同时支持 OpenAI、Anthropic 与 Gemini API 并互相转换，让任意编码 Agent 使用任意厂商的模型。
- **[Octop](./octop/README.md)**：腾讯云开源的自托管 AI 助手，支持多用户、多 Agent、长期记忆、知识库和多渠道接入。
- **[Cloudflare Mesh](./cloudflare-mesh/README.md)**：把服务器接入 Cloudflare 的网状网络，并可作为转发网关为其他设备提供出网能力。
- **[EasyTier Web](./easytier-web/README.md)**：EasyTier 自建 Web 控制台，可集中管理节点并通过 UDP 向 easytier-core 下发配置。
- **[EasyTier Shared](./easytier-shared/README.md)**：EasyTier 公共共享节点，为无公网 IP 的节点提供中继与发现，可开关转发并配置网络名白名单。

## 一键部署

本仓库在国内外各托管了一份，内容一致，可按网络情况任选其一。国内推荐 CNB：

```bash
curl -fsSL https://cnb.cool/jiangtj/1panel-local/-/git/raw/master/install.sh | sudo bash
```

GitHub：

```bash
curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh | sudo bash
```

脚本默认先尝试国内仓库 `https://cnb.cool/jiangtj/1panel-local`，不可达时自动回退到 GitHub。下载归档包、解压后，脚本会把各应用目录移动到 `/opt/1panel/resource/apps/local`。完成后打开 1Panel「应用商店 → 本地应用」，点击**更新应用列表**，即可在列表中找到这些应用并安装。

## 先下载后运行

如果希望先查看脚本内容再执行：

```bash
# 国内（CNB）
curl -fsSL https://cnb.cool/jiangtj/1panel-local/-/git/raw/master/install.sh -o install.sh
# 或 GitHub
curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh -o install.sh

sudo bash install.sh
```

脚本支持用环境变量覆盖默认行为：

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `SOURCE` | 代码来源：`auto` 先 CNB 后 GitHub，或指定 `cnb` / `github` | `auto` |
| `BRANCH` | 下载的分支 | `master` |
| `DEST_DIR` | 目标本地应用目录 | `/opt/1panel/resource/apps/local` |

例如部署到自定义目录，或强制只从 GitHub 获取：

```bash
DEST_DIR=/opt/1panel/resource/apps/local sudo -E bash install.sh
SOURCE=github sudo -E bash install.sh
```

一行命令时同样可以传变量（注意 sudo 需要用 `env` 传递）：

```bash
curl -fsSL https://cnb.cool/jiangtj/1panel-local/-/git/raw/master/install.sh | sudo env SOURCE=github bash
```

## 手动部署

不使用脚本时，也可自行下载仓库归档，把其中的应用目录（`clash-rule`、`cloudflare-mesh`、`easytier-shared`、`easytier-web`、`fns`、`magpie`、`octop`、`subconverter`）复制到 `/opt/1panel/resource/apps/local` 下，再按上面的方式更新应用列表。

国内归档包地址：`https://cnb.cool/jiangtj/1panel-local/-/git/archive/master.zip`（解压后没有顶层目录）；GitHub 归档包地址：`https://github.com/jiangtj/1panel-local/archive/refs/heads/master.zip`（解压后为 `1panel-local-master/` 目录）。