#!/usr/bin/env bash
# Ersetzt den Block zwischen <!-- news:start --> und <!-- news:end --> in README.md und SECURITY.md.
# Aufruf: update-news.sh <news.md>
set -euo pipefail

NEWS_FILE="${1:?news-Datei fehlt}"
for f in README.md SECURITY.md; do
  tmp=$(mktemp)
  BLOCK="$(cat "$NEWS_FILE")" awk '
    /<!-- news:start -->/ { print; print ENVIRON["BLOCK"]; skip=1; next }
    /<!-- news:end -->/   { skip=0 }
    !skip { print }
  ' "$f" > "$tmp"
  mv "$tmp" "$f"
done
