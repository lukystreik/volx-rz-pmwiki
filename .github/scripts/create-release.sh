#!/usr/bin/env bash
# Legt pro neuer PmWiki-Version genau ein GitHub-Release an (Tag pmwiki-<version>).
# Wiederholte Builds derselben Version (woechentliche OS-Rebuilds) erzeugen kein weiteres Release.
# Aufruf: create-release.sh <pmwiki> <ubuntu> <php> <nginx> <critical> <high> <medium> <low> <news.md>
# Benoetigt: gh CLI mit GH_TOKEN, Recht contents: write
set -euo pipefail

VERSION="${1:?}"; UBUNTU="${2:?}"; PHP="${3:?}"; NGINX="${4:?}"
CRIT="${5:-0}"; HIGH="${6:-0}"; MED="${7:-0}"; LOW="${8:-0}"; NEWS="${9:-}"
TAG="pmwiki-${VERSION}"

if gh release view "$TAG" >/dev/null 2>&1; then
  echo "Release $TAG existiert bereits - nichts zu tun."
  exit 0
fi

notes=$(mktemp)
{
  echo "Container image for **PmWiki ${VERSION}** on Ubuntu ${UBUNTU} LTS, nginx and PHP-FPM."
  echo
  echo "## Pull"
  echo '```bash'
  echo "docker pull lukystreik/volx-rz-pmwiki:${VERSION}"
  echo "docker pull ghcr.io/lukystreik/volx-rz-pmwiki:${VERSION}"
  echo '```'
  echo "\`latest\` always points to the newest PmWiki release. For reproducible deployments pin a dated tag (\`${VERSION}-YYYYMMDD\`)."
  echo
  echo "## Contents at release time"
  echo "* PmWiki ${VERSION} – [PmWiki change log](https://www.pmwiki.org/wiki/PmWiki/ChangeLog)"
  echo "* Ubuntu ${UBUNTU} LTS · PHP ${PHP} · nginx ${NGINX}"
  echo "* Trivy findings with available fix: CRITICAL ${CRIT} · HIGH ${HIGH} · MEDIUM ${MED} · LOW ${LOW}"
  if [[ -n "$NEWS" && -s "$NEWS" ]]; then
    echo
    echo "## Security news"
    cat "$NEWS"
  fi
  echo
  echo "---"
  echo "This release documents the state of the first build of this PmWiki version. The image is rebuilt weekly for operating-system"
  echo "patches; see the [security policy](https://github.com/${GITHUB_REPOSITORY:-lukystreik/volx-rz-pmwiki}/blob/main/SECURITY.md) for the current status."
} > "$notes"

gh release create "$TAG" --target main --title "PmWiki ${VERSION}" --notes-file "$notes" --latest
rm -f "$notes"
