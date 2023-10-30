TAG="bsolut/php:php81"
build:
	docker build . --pull -t ${TAG}

build-debug:
	docker --debug build . --pull -t ${TAG}

push:
	docker push ${TAG}

enter:
	docker run --rm -it --entrypoint /bin/bash ${TAG}

version:
	docker run --rm --entrypoint /bin/bash ${TAG} -c "php -v"

modules:
	docker run --rm --entrypoint /bin/bash ${TAG} -c "php -m"

