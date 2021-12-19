#!/bin/bash
. .env
echo "docker build $IMAGENAME"
docker build --squash  -t $IMAGENAME .
echo ""
#docker scan $IMAGENAME
echo ""

echo "docker push $IMAGENAME"
docker push $IMAGENAME

echo ""

