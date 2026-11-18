## Overview

A **Cloudflare Mesh** node joins this server to a Cloudflare Mesh network. This app runs the official node image in Docker and supplies everything the node needs: `NET_ADMIN` / `NET_RAW` capabilities, the `/dev/net/tun` device and the IPv4/IPv6 forwarding sysctls. Source NAT (`SRCNAT_ENABLED=true`) is enabled, so the node can also act as a gateway that lets other devices reach the mesh through this server.

## Features

- **Join the mesh**: registers with the node token (`MESH_NODE_TOKEN`) and keeps the connection alive across restarts.
- **Gateway forwarding**: source NAT plus `net.ipv4.ip_forward` / `net.ipv6.conf.*.forwarding` let other hosts on the LAN, or other containers on 1Panel, use this node as their exit.
- **TUN passthrough**: the host `/dev/net/tun` is mapped into the container so it can create its own virtual interface.
- **Persistent state**: node state lives in `./data`, so reinstalling or upgrading the app keeps the registration.

## Usage

1. In the Cloudflare dashboard open **Zero Trust → Networks → Mesh**, create or select the node and copy its node token.
2. Install this app and paste the token into "Mesh node token".
3. After installation, check the container log to confirm the node connected. `cap_add`, `devices` and `sysctls` are set by the compose file, no extra flags needed.
4. To route other machines through this node, point their gateway/DNS at this server and make sure the firewall allows forwarded traffic.

## Requirements

| Item | Notes |
| --- | --- |
| TUN device | `/dev/net/tun` must exist on the host (`ls /dev/net/tun`), otherwise the container fails to start |
| Kernel | the `tun` module is required; IPv6 forwarding needs IPv6 to be enabled |
| Privileges | `NET_ADMIN` and `NET_RAW` are declared; `privileged` is not needed |
| Ports | no ports are published, all traffic goes through the TUN device |

## Data directory

| Directory | Contents |
| --- | --- |
| `./data` | mounted at `/var/lib/cloudflare-warp`, holds the node registration and configuration |

Back up the whole `./data` directory to preserve the node.

> The node token is the identity of the node. Do not commit it or share it in screenshots; if it leaks, rotate it in the Cloudflare dashboard and update the app's environment variable.
