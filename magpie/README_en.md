## Introduction

**magpie** is a local model gateway: it speaks the OpenAI, Anthropic and Gemini APIs and translates between them, so any coding agent can use any provider's model. This app runs that gateway and its web UI in Docker for agents on other machines.

## Features

- **Multi-protocol Translation**: The gateway speaks OpenAI Chat/Responses, Anthropic Messages and the Gemini API, and translates between them, including streaming, tool calls and reasoning.
- **One Place for Models**: Manage providers and models from the web UI and assign them to Claude Code, Codex, Gemini CLI, OpenCode and more as provider/model or a routing group.
- **Routing Groups and Quota**: Combine several models or accounts into one routing group, fail over automatically when a quota runs out, and watch balances, tokens and cost on the usage page.
- **Gateway Keys**: Issue a separate gateway key with its own limits for every machine outside the container; requests without an enabled key get 401.
- **Web UI**: Add providers, sign in to subscriptions, configure routing, review usage and manage plugins in the browser; the Docker image runs in gateway mode.

## Usage

1. After installation, read the container logs for the web UI address with its key (`docker logs <container>` prints `http://<host>:<web-port>/?k=<web-key>`)
2. Add API keys or sign in to subscriptions under Providers, then pick a model for each agent
3. Create a gateway key under Gateway → Gateway keys for every machine outside the container, and point the agent's base URL at `http://<host>:<gateway-port>`: OpenAI clients use `/v1`, Anthropic and Gemini clients use the root address

## Data directory

| Directory | Content |
| --- | --- |
| `./config` | Providers, keys, sign-ins, plugins and usage; all magpie state lives here |

Back up `./config` as a whole. The image runs as the nonroot user (uid 65532), so installation changes the directory owner to `65532:65532`.

> The web UI has no HTTPS of its own; put it behind a reverse proxy with TLS or reach it over a VPN or SSH tunnel, and prefer a VPN instead of exposing the gateway port to the internet.
