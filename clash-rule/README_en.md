## Introduction

**Clash Rule** hosts ACL4SSR rule files through nginx and serves them locally, so subscription converters such as subconverter can reference local rules instead of GitHub.

## Features

- **Local Rule Hosting**: nginx serves the ACL4SSR rule files stored in the app data directory on a fixed port.
- **Automatic Rule Updates**: The ACL4SSR repository is cloned on first install and synced daily by a built-in scheduled updater service.

## Data Directories

| Directory | Content |
| --- | --- |
| `./data/acl4ssr` | ACL4SSR rule repository, cloned automatically during installation |
| `./data/acl4ssr/Clash` | Rule directory mounted into the nginx container as the web root |

Both live under the 1Panel app installation directory (for example `/opt/1panel/apps/clash-rule/clash-rule`); back up `./data` as a whole.

## Usage

1. The rule web port serves the files under the `Clash` directory of the ACL4SSR repository, for example `http://<rule host>:<rule web port>/config/ACL4SSR_Local_Full.ini`.
2. When pairing with a subscription converter (such as the Subconverter app), point the config parameter to the local rule file: `http://<subconverter address>/sub?target=clash&url=<subscription url>&config=http://<rule host>:<rule web port>/config/ACL4SSR_Local_Full.ini`.
3. The rule host is configured in the install form. A plain IP/hostname generates `http://<rule host>:<rule web port>`; a full `http(s)://` URL is used as the rule service address as-is (the rule web port is ignored).

## Automatic Rule Updates

The app ships a `rule-updater` container that runs busybox crond and syncs the ACL4SSR repository every day at 03:00, regenerating `ACL4SSR_Local_Full.ini`. It also syncs once on startup. Change the schedule through the container environment variable `CRON_SCHEDULE` (standard crontab expression).

A 1Panel scheduled task can be used instead (optional, both can coexist): create a **Shell script** task that runs once a day with the following content:

```bash
bash "$(find /opt/1panel/apps -maxdepth 6 -type f -path '*clash-rule*' -name update-rule.sh | head -n1)"
```

It runs `scripts/update-rule.sh` inside the app directory.
