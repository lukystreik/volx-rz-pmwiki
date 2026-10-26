# volx-rz-pmwiki – PmWiki as a hardened, always-current container

[![build-pmwiki-image](https://github.com/lukystreik/volx-rz-pmwiki/actions/workflows/build.yml/badge.svg)](https://github.com/lukystreik/volx-rz-pmwiki/actions/workflows/build.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/lukystreik/volx-rz-pmwiki)](https://hub.docker.com/r/lukystreik/volx-rz-pmwiki)

A ready-to-run [PmWiki](https://www.pmwiki.org/) image on **Ubuntu 26.04 LTS**, **nginx** and **PHP-FPM**
(multi-arch: `linux/amd64`, `linux/arm64`). PmWiki itself does not ship an official container, and
nobody else keeps a current one on Docker Hub – so this project does: it rebuilds automatically for every new
PmWiki release and every week for operating-system security patches.

## Latest build

<!-- last-build:start -->
| | |
| :---- | :---- |
| Last build | 26.10.2026 00:32 UTC |
| PmWiki version | 2.7.8 |
| Image | `lukystreik/volx-rz-pmwiki:2.7.8` |
| PmWiki tarball SHA-256 | `2c159a64c7323d32ea000395c374ffa7d53a7c352b3bb6aa04a62005dd8c1ee1` |
| Workflow run | [Run](https://github.com/lukystreik/volx-rz-pmwiki/actions/runs/40248909490) |
<!-- last-build:end -->

Security details (base OS, PHP, nginx, scan results): see [SECURITY.md](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/SECURITY.md).

## Why this image

* **Always current** – new PmWiki release detected daily and built right away; a full rebuild every Monday picks up Ubuntu, nginx and PHP patches.
* **Scanned before publishing** – every image is checked with [Trivy](https://trivy.dev); fixable CRITICAL findings block the release.
* **Verified download** – PmWiki is fetched over HTTPS for an exact version and checked against a SHA-256 computed in the pipeline.
* **Hardened nginx** – server tokens removed, HSTS, CSP, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`.
* **Works behind a reverse proxy** – real client IP from `X-Forwarded-For` (nginx realip module), so access logs and PmWiki see the visitor instead of the proxy.
* **Proper container behaviour** – `tini` as PID 1, graceful shutdown, container exits if nginx or PHP-FPM dies (so restart policies work), logs on stdout/stderr, healthcheck included.
* **PHP version independent** – the PHP version comes from Ubuntu (currently 8.5); paths such as the FPM socket and `/etc/php/current` are stable across upgrades.

## Quick start

```yaml
# compose.yaml
services:
  pmwiki:
    image: lukystreik/volx-rz-pmwiki:latest
    restart: unless-stopped
    environment:
      TZ: Europe/Berlin
    volumes:
      - ./data/wiki.d:/var/www/html/wiki.d
      - ./data/local:/var/www/html/local
      - ./data/cookbook:/var/www/html/cookbook
      - ./data/pub:/var/www/html/pub
      - ./data/uploads:/var/www/html/uploads
    ports:
      - "33380:80"
```

```bash
mkdir -p data/{wiki.d,local,cookbook,pub,uploads}
sudo chown -R 33:33 data        # www-data inside the container
docker compose up -d
```

Open <http://localhost:33380>. PmWiki is configured through `local/config.php` in your `local` volume
(see the [PmWiki documentation](https://www.pmwiki.org/wiki/PmWiki/Documentation)).

### Volumes

| Path in container | Purpose |
| :---- | :---- |
| `/var/www/html/wiki.d` | Wiki pages (**back this up**) |
| `/var/www/html/local` | `config.php` and local customisations |
| `/var/www/html/cookbook` | Installed PmWiki extensions |
| `/var/www/html/pub` | Public assets (skins, CSS, JS) |
| `/var/www/html/uploads` | File attachments |

You can additionally bind-mount `favicon.ico`, `robots.txt`, `sitemap.xml` into `/var/www/html/`, a custom
nginx site to `/etc/nginx/sites-enabled/default`, or a custom `php.ini` to `/etc/php/current/fpm/php.ini`.

### Behind a reverse proxy

The image trusts `X-Forwarded-For` from private networks (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`),
see [build/nginx-realip.conf](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/build/nginx-realip.conf). If your proxy lives elsewhere, mount your own
file over `/etc/nginx/conf.d/nginx-realip.conf` with additional `set_real_ip_from` lines.
Terminate TLS at the proxy and set `$ScriptUrl` in `local/config.php` to your public HTTPS URL.

## Image tags

| Tag | Meaning |
| :---- | :---- |
| `latest` | Newest build, always the current PmWiki release |
| `2.7.8` | Newest build for that PmWiki release |
| `2.7.8-20261026` | Immutable build of that release on that day (pin this for reproducible deployments) |

## Upgrading from the old (Ubuntu 20.04 / PHP 7.4) images

* The FPM socket is now `/run/php/php-fpm.sock`. A compatibility symlink for `php7.4-fpm.sock` is created, but update custom nginx sites.
* Mount a custom `php.ini` to `/etc/php/current/fpm/php.ini` instead of `/etc/php/7.4/fpm/php.ini`.
* Review your cookbook recipes and `local/` code for PHP 8 compatibility (PHP 7.4 → 8.5 removes and changes several behaviours) before switching.
* cron, rsyslog and various debugging tools are no longer part of the image.

## How it is built

* [`build/Dockerfile`](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/build/Dockerfile) – takes `PMWIKI_VERSION` (required) and `PMWIKI_SHA256` (optional) as build arguments.
* [`.github/workflows/build.yml`](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/.github/workflows/build.yml) – the single pipeline: detect release → build → Trivy scan → multi-arch push → update this README and SECURITY.md. Runs daily, always on Mondays, on changes to `build/`, and on manual dispatch.
* [`.github/scripts/`](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/.github/scripts) – release detection and documentation updates.
* Local build: `cd build && make build` (needs Docker and network access). `make scan` runs Trivy, `make run` starts a local container.

The repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are required for publishing. This README is also synced to the Docker Hub repository overview after each build.

## Migrating content from PmWiki 1.x (ISO-8859-1)

```bash
apt-get update && apt-get install convmv
unset LC_ALL
convmv -f iso-8859-15 -t utf-8 --notest *
```

## Version history

| Version | Date |
| :---- | :-------- |
| 2.7.8 | 26.10.2026 |
| 2.5.9 | 05.04.2026 |
| 2.5.2 | 14.09.2025 |
| 2.3.38 | 03.11.2024 |
| 2.3.37 | 21.08.2024 |
| 2.3.36 | 07.08.2024 |
| 2.3.35 | 07.07.2024 |
| 2.3.34 | 27.05.2024 |
| 2.3.33 | 21.04.2024 |
| 2.3.32 | 23.03.2024 |
| 2.3.31 | 23.02.2024 |
| 2.3.30 | 22.01.2024 |
| 2.3.27 | 23.10.2023 |
| 2.3.26 | 28.09.2023 |
| 2.3.25 | 28.07.2023 |
| 2.3.18 | 15.01.2023 |
| 2.3.17 | 31.12.2022 |
| 2.3.20 | 01.03.2023 |
| 2.3.21 | 06.03.2023 |
| 2.3.22 | 06.04.2023 |
| 2.3.23 | 02.05.2023 |
| 2.3.24 | 06.06.2023 |

## Contributing

Issues and pull requests are welcome. Changes to the build are tested by the pipeline on every pull request (build and scan, no publish).
Maintainers and AI agents: read [AGENTS.md](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/AGENTS.md) first.

## Links

* PmWiki: <https://www.pmwiki.org/wiki/PmWiki/Download>
* Docker Hub: <https://hub.docker.com/r/lukystreik/volx-rz-pmwiki>
* Security policy: [SECURITY.md](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/SECURITY.md)
