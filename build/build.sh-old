#!/bin/bash
#to get latest Version Nr. from svn repo run:
#svn ls svn://pmwiki.org/pmwiki/tags|egrep pmwiki-|sort -V|tail -1|sed -e 's/\///'
#commandline hack for version Nr.
#wget --quiet http://www.pmwiki.org/pub/pmwiki/ -O- 2>/dev/null |grep pmwiki-|egrep -v 'zip|patch|md5|latest'|sed -e 's/.*pmwiki-//' -e 's/<\/a.*//' -e 's/.tgz.*//'|sort -V|tail -1
source .env
stamp=$(date '+%Y%m%d%H%M')
version=$(wget --quiet http://www.pmwiki.org/pub/pmwiki/ -O- 2>/dev/null |grep pmwiki-|egrep -v 'zip|patch|md5|latest'|sed -e 's/.*pmwiki-//' -e 's/<\/a.*//' -e 's/.tgz.*//'|sort -V|tail -1)
echo "docker build $IMAGENAME"
docker build --squash  -t $IMAGENAME .
echo ""
#docker scan $IMAGENAME
trivy $IMAGENAME > trivy-scanresult-$stamp.txt
echo ""

IMGBASE=$(echo $IMAGENAME|sed -e 's/:.*//')
docker tag $IMAGENAME $IMGBASE:$version
echo "docker push $IMAGENAME"
docker push $IMAGENAME
echo "docker push $IMGBASE:$version"
docker push $IMGBASE:$version
docker pushrm $IMAGENAME


echo ""

