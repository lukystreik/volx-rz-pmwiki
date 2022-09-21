# pmwiki 2.2.x / Ubuntu 20.04
an ubuntu 20.04LTS based self made docker Version of pmwiki. Latest Version of pmwiki see here: https://www.pmwiki.org/pub/pmwiki/?C=M;O=D 

all security patches included. All layers are squashed, to reduce size and false positive scan results of vulnerabilitiy tools.

## Base Environment

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


# convert files from prev. pmwiki Version from iso-8859-1 to utf-8

```
apt-get update && apt-get install convmv

unset LC_ALL

convmv -f iso-8859-15 -t utf-8 --notest *
```
