# AGENTS.md – guide for AI agents and maintainers

This repo builds and publishes a public PmWiki container image (`lukystreik/volx-rz-pmwiki` on Docker Hub).
Read this file before changing anything. Keep it up to date when you change the setup (see "Change log of the setup").

## Goal and invariants

1. The image must always contain the **current PmWiki release** and **current OS patches** – the pipeline rebuilds daily (on a new release) and every Monday (OS patches).
2. The image works **behind a reverse proxy** and exposes the real client IP (`X-Forwarded-For` → nginx realip).
3. Nothing secret, host-specific or wiki-content related belongs in this repo. The production deployment (compose file, haproxy, wiki data) lives in a separate private repo.
4. `README.md` and `SECURITY.md` contain **auto-generated blocks** (see below). Never edit between those markers by hand.

## Layout

| Path | Purpose |
| :---- | :---- |
| `build/Dockerfile` | Ubuntu 26.04, nginx-extras, distro PHP-FPM, PmWiki. Build args `PMWIKI_VERSION` (required), `PMWIKI_SHA256` (optional) |
| `build/docker-entrypoint.sh` | Runs php-fpm + nginx under `tini`; container exits if either dies |
| `build/nginx-site-default.conf` | Site config, security headers, PmWiki rewrite, FastCGI to `/run/php/php-fpm.sock` |
| `build/nginx-realip.conf` | Trusted proxy ranges and `real_ip_header` |
| `build/{wiki.d,local,cookbook,pub,uploads}/.gitkeep` | Intentionally empty base directories of the wiki: orientation for users where mounts go. Keep them |
| `build/Makefile`, `build/.env` | Local build/scan/run helpers |
| `build/docker-compose.yml`, `build/start_pmwiki.sh` | Example/operations helpers for a single-host deployment |
| `.github/workflows/build.yml` | The only pipeline |
| `.github/scripts/detect-version.sh` | Latest PmWiki version + tarball SHA-256 (used by CI and Makefile) |
| `.github/scripts/update-readme.sh` | Fills `<!-- last-build:* -->` in README.md and adds the version-history row |
| `.github/watched-cves.txt` | CVEs shown in the "Security news" line; add new high-profile CVEs here, remove old ones |
| `.github/scripts/check-advisories.sh`, `update-news.sh` | Verify watched CVEs against the built image (package changelogs) and fill `<!-- news:* -->` in README/SECURITY |
| `.github/scripts/create-release.sh` | One GitHub release per PmWiki version with image tags, versions, Trivy summary, news |
| `.github/scripts/update-security.sh` | Fills `<!-- security-status:* -->` in SECURITY.md |

## Pipeline (`build.yml`)

1. `detect-version.sh` downloads `pmwiki-latest.tgz` and derives the version from the tarball's top-level directory.
   (The directory listing on pmwiki.org returns 404 today, so scraping it no longer works – do not reintroduce it.)
2. Decide: on `schedule`, build only if the version tag is missing on Docker Hub **or** it is Monday. Push/dispatch/PR always build.
3. Build amd64 locally → Trivy scan (`ignore-unfixed`, JSON) → fail on any fixable CRITICAL → multi-arch build/push (`latest`, `X.Y.Z`, `X.Y.Z-YYYYMMDD`).
4. Push to Docker Hub and GHCR only from `main` and never for pull requests.
5. Separate `keepalive` job (schedule only) re-enables the workflow daily – GitHub otherwise disables schedules after 60 days without repo activity.
6. README.md is synced to the Docker Hub overview (peter-evans/dockerhub-description, needs a PAT with Read/Write/Delete scope; step is non-fatal). Therefore README links must be absolute URLs.
7. `create-release.sh` creates one GitHub release `pmwiki-X.Y.Z` per new PmWiki version (not for weekly OS rebuilds; skipped if the tag exists).
8. Update README.md/SECURITY.md and push a `docs: … [skip ci]` commit from `github-actions[bot]`.

GHCR: the first push creates a *private* package – set it to public once (GitHub profile → Packages → volx-rz-pmwiki → Package settings → Change visibility).

Required repo setup: secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`; Actions workflow permissions "Read and write"; if `main` is protected, allow the bot to push; enable "Private vulnerability reporting" (linked from SECURITY.md).

## Local verification checklist

```bash
.github/scripts/detect-version.sh                      # prints PMWIKI_VERSION / PMWIKI_SHA256
cd build && make build                                  # or docker build --build-arg PMWIKI_VERSION=…
docker run -d --name t -p 18088:80 <image>
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18088/            # 200
# real IP: put <?php echo $_SERVER['REMOTE_ADDR']; into a file and call it with -H 'X-Forwarded-For: 203.0.113.9'
docker stop t                                           # must return in < 1 s (tini + trap)
```

## Gotchas

* PHP version comes from Ubuntu. Never hardcode it: use `/run/php/php-fpm.sock`, `/etc/php/current`, `/etc/php/current-version`.
* A compatibility symlink `php7.4-fpm.sock` exists for old site configs – remove it once nobody mounts them.
* `local/`, `cookbook/` etc. are volumes; empty bind mounts hide the bundled files – that is intended.
* Compose healthcheck in production overrides the Dockerfile one; keep `wget` in the image.
* On macOS `awk -v` cannot take multi-line values; the scripts use `ENVIRON` – keep it that way.
* Editing the markers' names breaks the update scripts.

## Change log of the setup

| Date | Change |
| :---- | :---- |
| 2026-10-26 | Rebuilt on Ubuntu 26.04 / PHP 8.5 (was 20.04 / 7.4, both EOL). Version-agnostic PHP paths, `tini` + signal-safe entrypoint, `real_ip_recursive`. |
| 2026-10-26 | Replaced three workflows by `build.yml`; version detection from the tarball (pmwiki.org listing gone); Trivy gate; scheduled rebuilds; build args with SHA-256 check. |
| 2026-10-26 | README rewritten for external users; README/SECURITY blocks auto-updated by the pipeline; removed unused `build.sh`, `build.sh-old`, `nginx.conf`, `build/wiki.d`, `build/README.md`. |
| 2026-10-26 | Publish to GHCR in addition to Docker Hub; SECURITY.md in English; watched-CVE news line (CVE-2026-109618/109619 fixed via Ubuntu `php8.5 8.5.4-0ubuntu1.5`). |
| 2026-10-26 | GitHub releases: one `pmwiki-X.Y.Z` release per new PmWiki version, created by the pipeline. |
