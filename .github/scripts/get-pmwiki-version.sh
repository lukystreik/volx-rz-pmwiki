export VERSION=$(wget --quiet http://www.pmwiki.org/pub/pmwiki/ -O- 2>/dev/null |grep pmwiki-|egrep -v 'zip|patch|md5|latest'|sed -e 's/.*pmwiki-//' -e 's/<\/a.*//' -e 's/.tgz.*//'|sort -V|tail -1)
