FROM php:8.1-fpm

ENV TERM=xterm
ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_SERVER_VERSION mysql-8.0
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/composer
ENV COMPOSER_PROCESS_TIMEOUT 600

#TODO - autoclean, clean dev libs - not possible atm as different steps

#Possible values for ext-name:
#bcmath bz2 calendar ctype curl dba dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlrpc xmlwriter xsl zend_test zip

# add profiler
ARG INSTALL_PROFILER=true
ARG CLEAN_BINARIES=true

RUN php -v

COPY mysql-apt-config_0.8.29-1_all.deb /tmp/mysql-apt-config_0.8.29-1_all.deb
COPY onig-6.9.9.tar.gz /tmp/onig-6.9.9.tar.gz

RUN apt-get update && apt-get install -y wget gnupg iputils-ping iproute2 curl \
#RUN
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && apt-get update && apt-get install -y gnupg \
    && apt-get upgrade -y\
    && apt-get install -y \
        debian-archive-keyring \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libzip-dev libbz2-dev \
        libgeoip-dev \
        expect-dev \
        libgmp-dev \
        libmagickwand-dev libmagickcore-dev imagemagick \
        libsodium-dev \
        libhiredis-dev \
        locales \
        python3 \
        git zip unzip \
        redis-server redis-tools \
        procps nano mc dnsutils \
        lsb-release \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys B7B3B788A8D3785C \
    && dpkg -i /tmp/mysql-apt-config_0.8.29-1_all.deb \
        && rm /tmp/mysql-apt-config_0.8.29-1_all.deb \
        && sed -i 's/bookworm/bullseye/' /etc/apt/sources.list.d/mysql.list \
        && curl -fsSL https://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb11u5_amd64.deb -o /tmp/ssl.deb \
        && dpkg -i /tmp/ssl.deb \
        && rm /tmp/ssl.deb \
        && apt-get update && apt-get install -y mysql-community-server \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
#    && echo hi
#RUN echo ho \
    && mkdir -p /tmp/oniguruma \
        && TMP_ORIG_PATH=$(pwd) \
        && cd /tmp/oniguruma \
        && tar xzf /tmp/onig-6.9.9.tar.gz --strip-components=1 \
        && ./configure --prefix=/usr/local \
        && make -j $(nproc) \
        && make install \
        && cd "$TMP_ORIG_PATH" \
        && rm /tmp/onig-6.9.9.tar.gz \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli bcmath mbstring bz2 zip gmp soap intl sodium sysvmsg sysvsem sysvshm ffi posix opcache shmop pcntl sockets exif \
    && apt install libmaxminddb0 libmaxminddb-dev mmdb-bin -y \
    && apt autoremove --purge -y \
    && apt-get upgrade -y\
#RUN
    && EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    curl -s -f -L -o /tmp/composer-setup.php https://getcomposer.org/installer && \
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');") && \
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
        >&2 echo 'ERROR: Invalid installer signature' && \
        rm /tmp/composer-setup.php && \
        exit 1; \
    fi && \
    php /tmp/composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer && \
    rm -rf /tmp/* /var/tmp/* && \
    composer --ansi --version --no-interaction \
#
#RUN
    && cd /tmp && git clone https://github.com/nrk/phpiredis.git \
    && cd phpiredis && phpize && ./configure --enable-phpiredis \
    && make -j $(nproc) && make install && docker-php-ext-enable phpiredis \
    && cd /tmp && rm -rf /tmp/phpiredis \
#RUN
    && cd /tmp && git clone https://github.com/wikimedia/mediawiki-php-excimer.git \
    && cd mediawiki-php-excimer && phpize && ./configure \
    && make -j $(nproc) && make install && docker-php-ext-enable excimer \
    && cd /tmp && rm -rf /tmp/mediawiki-php-excimer \
#
#RUN
    && pecl install uuid && docker-php-ext-enable uuid \
    && pecl install zstd && docker-php-ext-enable zstd \
    && pecl install redis && docker-php-ext-enable redis \
#
#RUN
    && pecl install apcu && docker-php-ext-enable apcu \
 #RUN
    && cd /tmp && git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug && phpize && ./configure \
    && make -j$(nproc) && make install && docker-php-ext-enable xdebug \
    && cd /tmp && rm -rf /tmp/xdebug \
#
#https://github.com/wp-statistics/GeoLite2-City
#RUN
    && curl -sS https://cdn.jsdelivr.net/npm/geolite2-city@1.0.0/GeoLite2-City.mmdb.gz | gunzip  | dd of=/GeoLite2-City.mmdb \
    && pecl install maxminddb && docker-php-ext-enable maxminddb \
    && (echo "<?php \
use MaxMind\Db\Reader; \
\$ipAddress='141.30.225.1';\
\$databaseFile = '/GeoLite2-City.mmdb';\
\$reader = new Reader(\$databaseFile);\
print_r(\$reader->get(\$ipAddress));\
print_r(\$reader->getWithPrefixLen(\$ipAddress));\
\$reader->close();\
     " | php | grep Dresden -cq || (echo "Geo not working" && exit 1)) \
#
#RUN
    && cd /tmp && git clone https://github.com/Imagick/imagick.git \
    && cd imagick && phpize && ./configure \
    && make -j$(nproc) && make install && docker-php-ext-enable imagick \
    && cd /tmp && rm -rf /tmp/imagick \
#
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

#RUN
    && if [ "${INSTALL_PROFILER}" = "true" ]; then \
        # install profiler
        TMP_ORIG_PATH=$(pwd) && \
        # build phpspy
        mkdir -p /tmp/phpspy && \
        cd /tmp/phpspy && \
        git clone https://github.com/adsr/phpspy.git . && \
        make -j $(nproc) && \
        cp ./phpspy /usr/bin/ && \
        chmod +x /usr/bin/phpspy && \
        cd "$TMP_ORIG_PATH" && \
        rm -rf /tmp/*; \
    fi \
    && apt-get remove "*-dev*" binutils cpp libbinutils x11-common  binutils-common libcairo-gobject2 libcairo-script-interpreter2 libcc1-0 cpp-12 -y --purge \
    && if [ "${INSTALL_PROFILER}" = "true" ]; then \
        TMP_ORIG_PATH=$(pwd) && \
        cd /usr/bin/ && rm -f mysql_embedded myisam* mysqlslap mysqladmin mysqlpump && \
        rm -f /usr/sbin/mysqld-debug && \
        cd "$TMP_ORIG_PATH" && \
        echo "binaries cleaned"; \
    fi \
    && echo "DONE"

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=18 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install nodejs -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY *.sh /

RUN npm install pm2 -g

RUN echo "de_DE.UTF-8 UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15\nen_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

VOLUME /var/lib/redis

EXPOSE 9000 6379

ADD zzz-bsolut-fpm.conf /usr/local/etc/php-fpm.d/
ADD bsolut-php.ini /usr/local/etc/php/conf.d/
ADD bsolut-xdebug.ini /usr/local/etc/php/conf.d/
ADD mysql-tmpfs.cnf /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf
RUN chmod go-w /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf && chown mysql /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf

ENTRYPOINT [ "/run.sh" ]

#check APC caching and potentially other things
COPY tests.php /
RUN php -d apc.enable_cli=1 /tests.php || exit 1
RUN php -m
RUN php -v
