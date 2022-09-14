# pmwiki Dockerfile and build pipeline 

to dockerize the pmwiki application in an ubuntu:latest OCI container

Homepage of the wiki vendor https://www.pmwiki.org/wiki/PmWiki/Download

dockerhub repository for pmwiki: https://hub.docker.com/repository/docker/lukystreik/volx-rz-pmwiki


# pmwiki 2.x.x / Ubuntu latest
generate an ubuntu latest based self made docker Version of pmwiki. Latest Version of pmwiki see here: https://www.pmwiki.org/pub/pmwiki/?C=M;O=D 

all current security patches included. 
Layer sqashing as possible to reduce size and false positive scan results of vulnerabilitiy tools. If you want to squash on docker build, you have to enable the experimental feature of docker in your build environment


## automatic build with github action

automatic build every month with github action script

scripts are located in .github subdir

## docker runtime base environment

```
TZ=Europe/Berlin 
LANG=C.UTF-8 
```

# run
```
mkdir -p wiki.d
chown 33:33 -R wiki.d
docker-compose -d 
```

# browser
open http://x.x.x.x:33380


# sample docker-compose.yml

```
version: '3'

services:
  pmwiki:
    image: lukystreik/volx-rz-pmwiki:latest
    volumes:
      - "./wikibasedir/wiki.d:/var/www/html/wiki.d"
      - "./wikibasedir/cookbook:/var/www/html/cookbook"
      - "./wikibasedir/pub:/var/www/html/pub"
      - "./wikibasedir/local:/var/www/html/local"
      - "./wikibasedir/uploads:/var/www/html/uploads"
    ports:
      - "33380:80"  # expose 33380
```


# convert files from prev. 1.x pmwiki Version from iso-8859-1 to utf-8

```
apt-get update && apt-get install convmv

unset LC_ALL

convmv -f iso-8859-15 -t utf-8 --notest *
```
