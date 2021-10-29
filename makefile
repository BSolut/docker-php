TAG="bsolut/php:php74-small"
build:
	docker build . --pull -t ${TAG}

push:
	docker push ${TAG}

enter:
	docker run --rm -it --entrypoint /bin/bash ${TAG}

version:
	docker run --rm --entrypoint /bin/bash ${TAG} -c "php -v"

modules:
	docker run --rm --entrypoint /bin/bash ${TAG} -c "php -m"

