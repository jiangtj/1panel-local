# Fast Note Sync

[Fast Note Sync Service](https://github.com/haierkeys/fast-note-sync-service)（简称 FNS）是自托管的 Obsidian 笔记库同步服务端，配合 Obsidian 插件 **Fast Note Sync** 使用，支持多端实时同步、附件同步、历史版本、回收站、分享链接，以及 REST API / MCP。本应用按 1Panel 本地应用规范包装上游官方镜像

- 官网 / 源码：https://github.com/haierkeys/fast-note-sync-service
- 客户端插件：https://github.com/haierkeys/obsidian-fast-note-sync

## 版本说明

- 本目录只有 `latest/` 一个版本目录，`docker-compose.yml` 固定使用上游浮动镜像标签 `haierkeys/fast-note-sync-service:latest`

## 安装

1. 把本应用目录（`fns`）放到 1Panel 本地应用目录 `/opt/1panel/resource/apps/local/` 下
2. 在 1Panel「应用商店 → 本地应用」点击**更新应用列表**，找到 Fast Note Sync 直接安装
3. 安装表单填写网页端口


## 首次使用

1. 浏览器打开 `http://<服务器地址>:<网页端口>`，首次访问需要**注册账号，第一个注册的用户即管理员**
2. 立刻在设置里把 **用户注册功能关闭**（对应 `config/config.yaml` 的 `user.register-is-enable: false`），个人使用不建议开放注册
3. 在网页后台的笔记库页面点击“一键导入 Obsidian”或复制授权配置，填入 Obsidian 插件即可开始同步

配置项位于 `config/config.yaml`（容器内 `/fast-note-sync/config/config.yaml`），修改后重启容器生效。Web GUI 中可修改的项对应该文件，两者等价

## 反向代理

FNS 不内置 TLS，公网使用请在 1Panel「网站」中创建反向代理网站，将域名整体代理到 `http://127.0.0.1:<网页端口>`，再为网站申请证书并开启 HTTPS

WebSocket 同步接口是 `/api/user/sync`，反向代理必须放行 WebSocket 升级；同时不要漏掉 `/api` 路径

## 数据与备份

| 目录 | 内容 |
| --- | --- |
| `./config` | `config.yaml`，含令牌加密密钥 |
| `./storage` | 笔记数据库、附件、历史版本、回收站、日志 |

两个目录都必须一起备份——只备份 `storage` 会丢失密钥，恢复后已有 Token 全部失效。目录位于 1Panel 的安装目录（版本目录）下
