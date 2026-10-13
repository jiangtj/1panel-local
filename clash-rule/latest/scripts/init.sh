#!/bin/bash

# 手动脚本（拆分自 clash-subconverter 组合包）：
# - 组合包 compose 将 ACL4SSR 的 Clash 目录挂载给 nginx，容器启动前该目录必须已有规则文件
# - https://github.com/ACL4SSR/ACL4SSR/tree/master/Clash/config（规则文件来源，安装时需拉取）

# 安装容器启动前，拉取 ACL4SSR 规则并生成本地规则配置（与 scripts/update-rule.sh 使用同一套逻辑）
bash "$(dirname "$0")/update-rule.sh"
