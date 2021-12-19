# pmwiki
docker pmwiki


# run
```
mkdir -p wiki.d
chown 33:33 -R wiki.d
docker-compose -d 
```

# browser
open http://x.x.x.x:33380


#convertierung iso-8859-1 nach utf-8

convmv
'''
apt-get update && apt-get install convmv

unset LC_ALL

convmv -f iso-8859-15 -t utf-8 --notest *
'''
