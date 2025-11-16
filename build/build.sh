#!/usr/bin/env bash
set -euo pipefail

# .env für IMAGENAME etc. laden
if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

if [[ -z "${IMAGENAME:-}" ]]; then
  echo "ERROR: IMAGENAME ist nicht gesetzt (in .env oder Environment)."
  exit 1
fi

STAMP=$(date '+%Y%m%d%H%M')

echo "Ermittle aktuelle PmWiki-Version ..."
PMWIKI_VERSION=$(wget --quiet http://www.pmwiki.org/pub/pmwiki/ -O- 2>/dev/null \
  | grep 'pmwiki-' \
  | egrep -v 'zip|patch|md5|latest' \
  | sed -e 's/.*pmwiki-//' -e 's/<\/a.*//' -e 's/.tgz.*//' \
  | sort -V \
  | tail -1)

if [[ -z "$PMWIKI_VERSION" ]]; then
  echo "WARN: Konnte PmWiki-Version nicht ermitteln, verwende 'latest'."
  PMWIKI_VERSION="latest"
fi

echo "Verwende PmWiki-Version: $PMWIKI_VERSION"

IMG_FULL="$IMAGENAME"
IMG_BASE="${IMAGENAME%%:*}"

echo "docker build $IMG_FULL (tagge zusätzlich $IMG_BASE:$PMWIKI_VERSION)"
DOCKER_BUILDKIT=1 docker build --squash \
  -t "$IMG_FULL" \
  -t "$IMG_BASE:$PMWIKI_VERSION" \
  .

echo
echo "Trivy-Scan läuft ..."
trivy "$IMG_FULL" > "trivy-scanresult-$STAMP.txt"
echo "Trivy-Report: trivy-scanresult-$STAMP.txt"
echo

echo "docker push $IMG_FULL"
docker push "$IMG_FULL"

echo "docker push $IMG_BASE:$PMWIKI_VERSION"
docker push "$IMG_BASE:$PMWIKI_VERSION"

# falls du docker pushrm wirklich benutzt (Plugin), lass es drin; sonst raus damit
if command -v docker-pushrm >/dev/null 2>&1; then
  docker pushrm "$IMG_FULL" || true
fi

echo "Fertig."

