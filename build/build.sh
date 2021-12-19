#!/bin/bash
. .env
stamp=$(date '+%Y%m%d%H%M')
echo "docker build $IMAGENAME"
docker build --squash  -t $IMAGENAME .
echo ""
#docker scan $IMAGENAME
trivy $IMAGENAME > trivy-scanresult-$stamp.txt
echo ""

echo "docker push $IMAGENAME"
docker push $IMAGENAME
docker pushrm $IMAGENAME


echo ""

