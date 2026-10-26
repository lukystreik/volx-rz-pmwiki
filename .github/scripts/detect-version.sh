#!/usr/bin/env bash
# Ermittelt die aktuelle PmWiki-Release aus pmwiki-latest.tgz (das Verzeichnislisting
# von pmwiki.org ist nicht mehr verlässlich erreichbar) und gibt aus:
#   PMWIKI_VERSION=2.x.y
#   PMWIKI_SHA256=<sha256 des Tarballs>
# Die Ausgabe ist direkt für $GITHUB_OUTPUT, $GITHUB_ENV oder `eval` geeignet.
set -euo pipefail

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

curl -fsSL --retry 3 -o "$tmp" https://www.pmwiki.org/pub/pmwiki/pmwiki-latest.tgz

list=$(tar -tzf "$tmp")
top=${list%%/*}
version=${top#pmwiki-}

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Version konnte nicht ermittelt werden (Top-Level-Verzeichnis: '$top')" >&2
  exit 1
fi

if command -v sha256sum >/dev/null; then
  sha=$(sha256sum "$tmp" | cut -d' ' -f1)
else
  sha=$(shasum -a 256 "$tmp" | cut -d' ' -f1)
fi

echo "PMWIKI_VERSION=$version"
echo "PMWIKI_SHA256=$sha"
