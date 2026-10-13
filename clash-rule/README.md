## 产品介绍

**Clash Rule** 通过 nginx 托管 ACL4SSR 规则文件并提供本地规则下载服务，配合 subconverter 等订阅转换服务使用，不再依赖 GitHub。

## 主要功能

- **本地规则托管**：nginx 托管应用数据目录中的 ACL4SSR 规则文件，规则随应用一起部署，按固定端口对外提供。
- **规则自动更新**：首次安装自动拉取 ACL4SSR 仓库，内置定时更新服务每天自动同步规则并重新生成本地规则配置。

## 数据目录

| 目录 | 内容 |
| --- | --- |
| `./data/acl4ssr` | ACL4SSR 规则仓库，安装时自动克隆 |
| `./data/acl4ssr/Clash` | 挂载给 nginx 容器的规则目录，即规则网页根目录 |

目录位于 1Panel 的应用安装目录（如 `/opt/1panel/apps/clash-rule/clash-rule`）下，备份时整体备份 `./data` 即可。

## 使用说明

1. 规则网页端口直接提供 ACL4SSR 仓库 `Clash` 目录下的文件，例如 `http://<规则服务地址>:<规则网页端口>/config/ACL4SSR_Local_Full.ini`
2. 搭配 subconverter 类订阅转换服务（如 Subconverter 应用）时，将 config 参数指向本地规则文件：`http://<订阅转换服务地址>/sub?target=clash&url=<订阅链接>&config=http://<规则服务地址>:<规则网页端口>/config/ACL4SSR_Local_Full.ini`
3. 「规则服务地址」在安装表单中填写：填纯 IP/域名时，生成的规则文件会写入 `http://<规则服务地址>:<规则网页端口>`；填完整 `http(s)://` 地址时，该地址直接作为规则服务地址（忽略规则网页端口）

## 规则自动更新

应用自带 `rule-updater` 容器，内部使用 busybox crond，每天 03:00 自动拉取 ACL4SSR 仓库并重新生成 `ACL4SSR_Local_Full.ini`，容器启动时也会先同步一次，无需额外配置。如需调整执行时间，可修改该容器的环境变量 `CRON_SCHEDULE`（标准 crontab 表达式）。

也可以改用 1Panel 计划任务（可选，与内置服务不冲突）：新建 **Shell 脚本** 任务，执行周期设为每天一次，脚本内容：

```bash
bash "$(find /opt/1panel/apps -maxdepth 6 -type f -path '*clash-rule*' -name update-rule.sh | head -n1)"
```

它会在应用目录中执行 `scripts/update-rule.sh`。
