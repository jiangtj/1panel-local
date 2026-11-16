## 产品介绍

**Octop** 是腾讯云开源的自托管 AI 助手，面向个人、家庭与小团队，提供多用户、多 Agent 协作，内置长期记忆、知识库与多渠道接入，数据保存在本机。

**扫码加入交流群**

<img alt="扫码加入交流群" src="https://resource.fit2cloud.com/1panel/img/wechat.png" width="150" height="150">

本应用基于 [1Panel 官方应用商店中的 Octop 应用](https://github.com/1Panel-dev/appstore/tree/dev/apps/octop) 配置。容器使用国内镜像 `ghcr.nju.edu.cn/tencentcloud/octop:full`（包含 Web 桌面），并带有 Watchcow 与 Watchtower 自动更新标签。

## 主要功能

- **多用户多 Agent**：一个实例内创建多个用户与 Agent，内置专家库与专家市场，按场景切换专业角色。
- **可迁移长期记忆**：基于 Octop Memory 的分层记忆与全文检索，记忆随工作区一同迁移。
- **多渠道接入**：支持飞书、钉钉、QQ、微信、企业微信以及 HTTP/SSE/WebSocket API 与 Agent 对话。
- **知识库与插件**：基于文档的 RAG 知识库、第三方插件，以及 OAuth + MCP 的 Connector 扩展体系。
- **本地优先**：单进程部署，Web 控制台、CLI、IM 与定时任务共享本机数据目录，默认 SQLite，可选 PostgreSQL。
