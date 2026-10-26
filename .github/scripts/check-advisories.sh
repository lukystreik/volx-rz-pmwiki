#!/usr/bin/env bash
# Prueft, ob die in .github/watched-cves.txt gelisteten CVEs im Image behoben sind
# (Erwaehnung im Paket-Changelog eines installierten Pakets) und schreibt eine Markdown-Zeile je CVE.
# Aufruf: check-advisories.sh <image> [watchlist]
set -euo pipefail

IMAGE="${1:?image fehlt}"
LIST="${2:-.github/watched-cves.txt}"

while IFS='|' read -r id desc; do
  id=$(echo "$id" | xargs)
  [[ -z "$id" || "$id" == \#* ]] && continue
  desc=$(echo "${desc:-}" | xargs)
  pkg=$(docker run --rm --entrypoint bash "$IMAGE" -c \
    "for f in /usr/share/doc/*/changelog*.gz; do zgrep -q '$id' \"\$f\" 2>/dev/null && { p=\${f#/usr/share/doc/}; p=\${p%%/*}; echo \$p \$(dpkg-query -W -f='\${Version}' \$p); break; }; done" || true)
  if [[ -n "$pkg" ]]; then
    echo "* ✅ **$id** – $desc. **Addressed** in this image (\`$pkg\`)."
  else
    echo "* ⚠️ **$id** – $desc. **Not yet addressed** in the current Ubuntu packages; the image is rebuilt daily and will pick up the fix as soon as it is released."
  fi
done < "$LIST"
