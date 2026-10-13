## Introduction

**Subconverter** provides a subscription conversion service supporting conversion between Clash, Surge, Quantumult, V2Ray and more.

## Features

- **Subscription Conversion**: Supports conversion between Clash, Surge, Quantumult, V2Ray and more.
- **Custom Rules**: Reference remote or local rule files through the config parameter, pairing well with local rule apps such as Clash Rule.

## Usage

1. Conversion endpoint: `http://<server>:<port>/sub?target=clash&url=<subscription url>&config=<rule file url>`
2. `config` can point to a remote rule file or a local rule service (such as the Clash Rule app): `http://<rule host>:<rule web port>/config/ACL4SSR_Local_Full.ini`
