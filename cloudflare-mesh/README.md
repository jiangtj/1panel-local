## 产品介绍

**Cloudflare Mesh** 节点把本机接入 Cloudflare 的 Mesh 网状网络。本应用以 Docker 方式运行官方节点镜像，并额外提供节点运行所需的网络能力：`NET_ADMIN` / `NET_RAW` 权限、`/dev/net/tun` 设备，以及 IPv4/IPv6 转发 sysctl；同时开启源地址 NAT（`SRCNAT_ENABLED=true`），使该节点可作为网关，让其他设备经由本服务器访问网状网络。

## 主要功能

- **加入 Mesh 网络**：使用节点令牌（`MESH_NODE_TOKEN`）自动注册并保持长连接，容器重启后无需重新配置。
- **网关转发**：开启源地址 NAT 与 `net.ipv4.ip_forward` / `net.ipv6.conf.*.forwarding`，让局域网内其他主机或 1Panel 上的其他容器把本节点当作出口。
- **TUN 设备直通**：挂载宿主机 `/dev/net/tun`，由容器自行建立虚拟网卡。
- **数据持久化**：节点状态写在 `./data`，重装或升级应用不会丢失。

## 使用说明

1. 在 Cloudflare 控制台 **Zero Trust → Networks → Mesh** 中创建或选中节点，取得该节点的令牌。
2. 安装本应用，把令牌填入「Mesh 节点令牌」。
3. 安装完成后查看容器日志，确认节点已连接；`cap_add`、`devices`、`sysctls` 已由 compose 自动配置，无需手工加参数。
4. 若要让其他机器经本节点出网，把它们的网关/DNS 指向本服务器地址，并确保服务器防火墙放行转发流量。

## 环境要求

| 项目 | 说明 |
| --- | --- |
| TUN 设备 | 宿主机需存在 `/dev/net/tun`（`ls /dev/net/tun`），否则容器启动会失败 |
| 内核模块 | 需要 `tun` 模块；IPv6 转发依赖 `ipv6` 未被禁用 |
| 权限 | 应用已声明 `NET_ADMIN`、`NET_RAW`，无需 `privileged` |
| 端口 | 本应用不映射任何端口，全部流量经由 TUN 设备出入 |

## 数据目录

| 目录 | 内容 |
| --- | --- |
| `./data` | 映射到容器 `/var/lib/cloudflare-warp`，保存节点注册状态与配置 |

备份时整体备份 `./data` 即可。

> 节点令牌等同于该节点身份，请勿提交到仓库或截图外传；一旦泄露，请在 Cloudflare 控制台重置并更新本应用的环境变量。
