#!/usr/bin/env bash
# Aktualisiert den automatisch gepflegten Block in SECURITY.md nach einem Build.
# Aufruf: update-security.sh <pmwiki> <ubuntu> <php> <nginx> <critical> <high> <medium> <low>
set -euo pipefail

VERSION="${1:?}"; UBUNTU="${2:?}"; PHP="${3:?}"; NGINX="${4:?}"
CRIT="${5:-0}"; HIGH="${6:-0}"; MED="${7:-0}"; LOW="${8:-0}"
FILE="${SECURITY_FILE:-SECURITY.md}"

block="| | |
| :---- | :---- |
| Unterstützte PmWiki-Version | **${VERSION}** (Tags \`latest\`, \`${VERSION}\`) |
| Basis-Betriebssystem | Ubuntu ${UBUNTU} LTS |
| PHP | ${PHP} |
| nginx | ${NGINX} |
| Letzter Build / Scan | $(date -u '+%d.%m.%Y %H:%M') UTC |
| Trivy-Funde (mit verfügbarem Fix) | CRITICAL: ${CRIT} · HIGH: ${HIGH} · MEDIUM: ${MED} · LOW: ${LOW} |"

tmp=$(mktemp)
BLOCK="$block" awk '
  /<!-- security-status:start -->/ { print; print ENVIRON["BLOCK"]; skip=1; next }
  /<!-- security-status:end -->/   { skip=0 }
  !skip { print }
' "$FILE" > "$tmp"
mv "$tmp" "$FILE"
