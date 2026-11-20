## Introduction

**EasyTier Shared** is an EasyTier shared node (public relay server). It does not join any virtual network itself; it only relays traffic and helps node discovery for other networks, so nodes without a public IP can still form a network. This app runs `easytier-core` in Docker and exposes the two forms described in the official "host a public server" guide as switchable options.

This app is available in two channels: `latest` (upstream stable release) and `unstable` (rolling build).

## Features

- **Data relay switch**: with relaying on, traffic is relayed for the virtual networks allowed by the whitelist (a public shared node); with relaying off, the node only helps other nodes establish P2P links and relays no payload.
- **Relay whitelist**: filters by network name (`--network-name`) wildcards such as `home* office-*`; `*` or an empty value relays every network.
- **TCP and UDP listeners**: one host port maps to both `11010/tcp` and `11010/udp` in the container.
- **Built for long runs**: the `nofile` limit is raised to 65536 so a busy public node does not run out of file descriptors, and the image's `easytier-cli` health check is kept.

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| Listen port | `31010` | Host TCP + UDP port mapped to container port `11010`. Other nodes connect with `udp://<server-ip>:<port>` or `tcp://<server-ip>:<port>`; open both TCP and UDP in the firewall |
| Data relay | On | On relays traffic for whitelisted networks; off only helps nodes build P2P links |
| Relay whitelist | `*` | Only used when relaying is on; space-separated network name wildcards, `*` or empty means every network |

How the options map to the command that actually runs:

| Data relay | Whitelist | Command |
| --- | --- | --- |
| On | `*` | `easytier-core --relay-network-whitelist "*"` (same as the official "plain public server", i.e. no arguments) |
| On | `home* office` | `easytier-core --relay-network-whitelist "home* office"` |
| Off | ignored | `easytier-core --relay-network-whitelist --relay-all-peer-rpc` |

## Usage

1. Install the app, choose whether to enable data relaying and fill in the whitelist.
2. Open the listen port for **both TCP and UDP** in the cloud security group and the host firewall.
3. Point other nodes at this one, for example `udp://<public-ip>:31010` or `tcp://<public-ip>:31010`; in the web console this goes into the peer address field.

## Notes

- A shared node needs no network name or secret. Adding `--network-name` / `--network-secret` with private mode turns it into a node serving only that single network.
- Public nodes get scanned a lot, so the log fills with `wait handshake timeout` entries; use fail2ban as described in the official guide if needed.
- Only `11010` (TCP/UDP) is mapped. The default listeners also include `11011` (wg/ws) and `11012` (wss); add extra port mappings in the compose file if clients should connect over WebSocket.
- Relaying happens at the application layer and does not rely on kernel forwarding, so `NET_ADMIN`, `/dev/net/tun` and forwarding sysctls are not used.
