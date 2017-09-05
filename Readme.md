# Docker for PHP
- Running a container will spawn an nginx at 9000 and a xdebug relay at 9001.
- nginx is running from /var/www/html
- Help https://github.com/wsargent/docker-cheat-sheet


### Run 
```
docker run -p 9001:9001 -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy
```

### Cheat Sheet
- build locally `docker build -t bsolut/php .`
- tag `docker tag xxx  bsolut/php`
- `docker run -it --entrypoint "/bin/bash" bsolut/php` 
- `docker push bsolut/php`
