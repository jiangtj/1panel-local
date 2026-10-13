## 产品介绍

**Subconverter** 提供订阅转换服务，支持 Clash、Surge、Quantumult、V2Ray 等多种订阅格式的互相转换。

## 主要功能

- **订阅转换**：支持 Clash、Surge、Quantumult、V2Ray 等多种订阅格式的互相转换。
- **自定义规则**：通过 config 参数引用远程或本地规则文件，可搭配 Clash Rule 等本地规则应用使用。

## 使用说明

1. 订阅转换接口格式：`http://<服务器地址>:<端口>/sub?target=clash&url=<订阅链接>&config=<规则文件地址>`
2. `config` 可指向远程规则文件，或本地规则服务（如 Clash Rule 应用）：`http://<规则服务地址>:<规则网页端口>/config/ACL4SSR_Local_Full.ini`
