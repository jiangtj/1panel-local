## Introduction

**Octop** is an open-source, self-hosted AI assistant from Tencent Cloud for individuals, families, and small teams, with multi-user and multi-agent collaboration, long-term memory, knowledge bases, and multi-channel access, keeping data on your own machine.

Two versions are provided: `full` (complete build with remote desktop control, OCR, and local embedding) and `latest` (standard build with a smaller image size).

This app is based on the [Octop app in the official 1Panel App Store](https://github.com/1Panel-dev/appstore/tree/dev/apps/octop). It uses domestic mirrors: `ghcr.nju.edu.cn/tencentcloud/octop:full` for the `full` version and `ghcr.nju.edu.cn/tencentcloud/octop:latest` for the `latest` version, both with Watchcow and Watchtower auto-update labels.

## Features

- **Multi-user, multi-agent**: Create multiple users and agents in one instance, with a built-in expert library and expert market for switching roles by scenario.
- **Migratable long-term memory**: Tiered memory and full-text retrieval powered by Octop Memory; memory moves together with the workspace.
- **Multi-channel access**: Chat with agents via Feishu, DingTalk, QQ, WeChat, WeCom, and HTTP/SSE/WebSocket APIs.
- **Knowledge bases and plugins**: Document-based RAG knowledge bases, third-party plugins, and an OAuth + MCP connector ecosystem.
- **Local-first**: Single-process deployment where the web console, CLI, IM channels, and scheduled tasks share a local data directory, with SQLite by default and optional PostgreSQL.
