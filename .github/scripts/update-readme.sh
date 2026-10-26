#!/usr/bin/env bash
# Aktualisiert README.md nach einem erfolgreichen Image-Build:
#  - Block zwischen <!-- last-build:start --> und <!-- last-build:end -->
#  - neue Zeile in der Versionstabelle (falls die Version dort noch fehlt)
#
# Aufruf: update-readme.sh <pmwiki-version> <tarball-sha256> <run-url>
set -euo pipefail

VERSION="${1:?pmwiki version fehlt}"
DIGEST="${2:-n/a}"
RUN_URL="${3:-}"
README="${README:-README.md}"

BUILD_DATE=$(date -u '+%d.%m.%Y')
BUILD_TIME=$(date -u '+%H:%M')

block="| | |
| :---- | :---- |
| Last build | ${BUILD_DATE} ${BUILD_TIME} UTC |
| PmWiki version | ${VERSION} |
| Image | \`lukystreik/volx-rz-pmwiki:${VERSION}\` |
| PmWiki tarball SHA-256 | \`${DIGEST}\` |
| Workflow run | ${RUN_URL:+[Run]($RUN_URL)} |"

tmp=$(mktemp)
BLOCK="$block" awk '
  /<!-- last-build:start -->/ { print; print ENVIRON["BLOCK"]; skip=1; next }
  /<!-- last-build:end -->/   { skip=0 }
  !skip { print }
' "$README" > "$tmp"
mv "$tmp" "$README"

# Versionstabelle: neue Zeile direkt unter dem Tabellenkopf, falls noch nicht vorhanden
if ! grep -q "^| ${VERSION} |" "$README"; then
  tmp=$(mktemp)
  awk -v row="| ${VERSION} | ${BUILD_DATE} |" '
    { print }
    /^\| :---- \| :-+ \|$/ && !done && prev ~ /^\| Version \| Date \|$/ { print row; done=1 }
    { prev=$0 }
  ' "$README" > "$tmp"
  mv "$tmp" "$README"
fi
