# Security Policy

## Supported versions

Unterstützt wird jeweils nur die **aktuelle PmWiki-Release** im Image-Tag `latest`
(und der gleichnamige Versions-Tag). Ältere Tags bleiben auf Docker Hub liegen,
bekommen aber keine Updates mehr – bitte auf `latest` wechseln.

Der folgende Block wird von der GitHub Action nach jedem erfolgreichen Build automatisch
aktualisiert (siehe `.github/workflows/build.yml`). Nicht von Hand ändern.

<!-- security-status:start -->
| | |
| :---- | :---- |
| Unterstützte PmWiki-Version | **2.7.8** (Tags `latest`, `2.7.8`) |
| Basis-Betriebssystem | Ubuntu 26.04 LTS |
| PHP | 8.5.4 |
| nginx | 1.28.3 (Ubuntu) |
| Letzter Build / Scan | 26.10.2026 00:32 UTC |
| Trivy-Funde (mit verfügbarem Fix) | CRITICAL: 0 · HIGH: 4 · MEDIUM: 9 · LOW: 1 |
<!-- security-status:end -->

## Wie aktuell bleibt das Image?

* Die Action prüft **täglich** auf eine neue PmWiki-Release und baut dann sofort.
* **Montags** wird immer neu gebaut, damit Ubuntu-, nginx- und PHP-Sicherheitsupdates ankommen.
* Vor dem Push wird das Image mit [Trivy](https://trivy.dev) gescannt. Behebbare
  CRITICAL-Funde verhindern die Veröffentlichung.

## Reporting a vulnerability

Bitte **keine** öffentlichen Issues für Sicherheitslücken. Nutze stattdessen
[GitHub Private Vulnerability Reporting](https://github.com/lukystreik/volx-rz-pmwiki/security/advisories/new)
dieses Repositories. Schwachstellen in PmWiki selbst bitte zusätzlich an das
[PmWiki-Projekt](https://www.pmwiki.org/wiki/PmWiki/Security) melden.

## Contribution / Support

Contributors welcome – siehe `AGENTS.md` für den technischen Aufbau.
