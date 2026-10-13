# 1panel-local
1panel 的一些自定义的应用

包含应用：Clash Rule、Subconverter、Fast Note Sync、magpie。

## 一键部署

在服务器终端运行下面这行命令，即可把本仓库的全部应用安装到 1Panel 的本地应用目录：

```bash
curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh | sudo bash
```

脚本会下载本仓库的归档包、解压，并把各应用目录移动到 `/opt/1panel/resource/apps/local`。完成后打开 1Panel「应用商店 → 本地应用」，点击**更新应用列表**，即可在列表中找到这些应用并安装。

## 先下载后运行

如果希望先查看脚本内容再执行：

```bash
curl -fsSL https://raw.githubusercontent.com/jiangtj/1panel-local/master/install.sh -o install.sh
sudo bash install.sh
```

脚本支持用环境变量覆盖默认行为：

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| `BRANCH` | 下载的分支 | `master` |
| `DEST_DIR` | 目标本地应用目录 | `/opt/1panel/resource/apps/local` |

例如部署到自定义目录：

```bash
DEST_DIR=/opt/1panel/resource/apps/local sudo -E bash install.sh
```

## 手动部署

不使用脚本时，也可自行下载仓库归档，把其中的应用目录（`clash-rule`、`fns`、`magpie`、`subconverter`）复制到 `/opt/1panel/resource/apps/local` 下，再按上面的方式更新应用列表。