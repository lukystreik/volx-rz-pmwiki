# pmwiki Dockerfile and build pipeline 

I made a docker container version the pmwiki application based on ubuntu:latest OCI container

* Homepage of the pmwiki source https://www.pmwiki.org/wiki/PmWiki/Download
* Latest Version of pmwiki see here: https://www.pmwiki.org/pub/pmwiki/?C=M;O=D 

* My dockerhub repository for pmwiki: https://hub.docker.com/repository/docker/lukystreik/volx-rz-pmwiki


# pmwiki 2.x.x / Ubuntu latest docker image building
A github action creates an ubuntu latest based docker version of the wiki and pushes it to dockerhub on a regular basis.

special builds for a specific version can be found on dockerhub lukystreik/volx-rz-pmwiki

## Version history

| Version | Date |
| :---- | :-------- |
| 2.3.18 | 15.01.2023 |
| 2.3.17 | 31.12.2022 |
| 2.3.20 | 01.03.2023 |
| 2.3.21 | 06.03.2023 |


## Benefits of the volx-rz-pmwiki
* hardened nginx with security header included
* all current pmwiki and ubuntu security patches included. 
* low servity level on the final image (no critical CVEs)
* Layer sqashing if possible in the CI environment (docker build experimental feature has to be enabled) to reduce the container size and false positive scan results of vulnerabilitiy tools. 

## The github CI pipeline 
###automatic build with github action

automatic build every month with github action script

scripts are located in .github subdir

# Container runtime usage
## how to use it
### docker runtime base environment
You should set the timezone ENV in your deployment (docker-compose or sth. else).

```
TZ=Europe/Berlin 
LANG=C.UTF-8 
```

### run
```
mkdir -p wiki.d
chown 33:33 -R wiki.d
docker-compose -d 
```

### browser
open http://x.x.x.x:33380


### sample docker-compose.yml

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


### convert files from prev. 1.x pmwiki Version from iso-8859-1 to utf-8

```
apt-get update && apt-get install convmv

unset LC_ALL

convmv -f iso-8859-15 -t utf-8 --notest *
```
