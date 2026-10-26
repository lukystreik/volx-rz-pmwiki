# Security Policy

## Security news

<!-- news:start -->
* ✅ **CVE-2026-109618** – PHP: out-of-memory handling can lead to remote code execution. **Addressed** in this image (`php8.5-cli 8.5.4-0ubuntu1.5`).
* ✅ **CVE-2026-109619** – PHP: stale request-memory state can lead to remote code execution. **Addressed** in this image (`php8.5-cli 8.5.4-0ubuntu1.5`).
<!-- news:end -->

## Supported versions

Only the **current PmWiki release** is supported, published as the image tag `latest` (and the matching
version tag). Older tags stay on Docker Hub / GHCR but receive no further updates – please switch to `latest`.

The block below is updated automatically by the GitHub Action after every successful build
(see `.github/workflows/build.yml`). Do not edit it by hand.

<!-- security-status:start -->
| | |
| :---- | :---- |
| Supported PmWiki version | **2.7.8** (Tags `latest`, `2.7.8`) |
| Base operating system | Ubuntu 26.04 LTS |
| PHP | 8.5.4 |
| nginx | 1.28.3 |
| Last build / scan | 26.10.2026 00:55 UTC |
| Trivy findings (with available fix) | CRITICAL: 0 · HIGH: 4 · MEDIUM: 9 · LOW: 1 |
<!-- security-status:end -->

## How current does the image stay?

* The pipeline checks **daily** for a new PmWiki release and builds immediately when there is one.
* It **always rebuilds on Mondays** so that Ubuntu, nginx and PHP security updates arrive.
* Before publishing, the image is scanned with [Trivy](https://trivy.dev). Fixable CRITICAL findings block the release.
* Selected high-profile CVEs are tracked in `.github/watched-cves.txt`; their status is verified against the
  freshly built image and shown in the news section above.

## Reporting a vulnerability

Please do **not** open public issues for security problems. Use
[GitHub Private Vulnerability Reporting](https://github.com/lukystreik/volx-rz-pmwiki/security/advisories/new)
of this repository. Vulnerabilities in PmWiki itself should additionally be reported to the
[PmWiki project](https://www.pmwiki.org/wiki/PmWiki/Security).

## Contribution / Support

Contributors welcome – see [AGENTS.md](https://github.com/lukystreik/volx-rz-pmwiki/blob/main/AGENTS.md) for the technical layout.
