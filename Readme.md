# Docker for PHP - with pdf gen
- Running a container will spawn php at 9000
- php is running from /var/www/html
- running unoconv
- Help https://github.com/wsargent/docker-cheat-sheet


### Run 
```
docker run -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy
```

### Cheat Sheet
- build locally `docker build -t bsolut/php .`
- tag `docker tag xxx  bsolut/php`
- `docker run -it --entrypoint "/bin/bash" bsolut/php` 
- `docker push bsolut/php`
