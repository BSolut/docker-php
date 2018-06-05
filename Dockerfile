FROM php:7.0-apache

RUN a2enmod rewrite expires

RUN echo deb http://httpredir.debian.org/debian stable main contrib >/etc/apt/sources.list \
    && echo deb http://security.debian.org/ stable/updates main contrib >>/etc/apt/sources.list \
    && apt-get update && apt-get install -my wget gnupg \
    && curl -sL https://d2buw04m05mirl.cloudfront.net/setup_8.x | sed "s/deb.nodesource.com/d2buw04m05mirl.cloudfront.net/" | sed "s/\(deb\(-src\)\? http\)s/\1/" | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        debian-archive-keyring \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libgeoip-dev \
        python \
        locales \
        expect-dev \
        geoip-bin geoip-database-contrib \
        nodejs \
        libgmp-dev \
        git \
        supervisor \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli bcmath mbstring zip gmp \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pecl install apcu apcu_bc-beta && docker-php-ext-enable apcu  && docker-php-ext-enable apc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install geoip-beta && docker-php-ext-enable geoip \
    && echo "<?php var_dump(geoip_record_by_name('141.30.225.1')); " | php  | grep Dresden -cq || (echo "Geo not working" && exit 1) \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD npm-exp.sh /npm-exp.sh
RUN npm set registry https://npm.bsolut.com \
    && npm config set always-auth true \
    && /npm-exp.sh "npm login " docker insecure docker@bsolut.com \
    && npm install less

RUN echo -e "de_DE.UTF-8 UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15\nen_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD auth-key /
RUN \
  chmod 600 /auth-key &&\
  echo "IdentityFile /auth-key" >> /etc/ssh/ssh_config && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD apache.conf /etc/supervisor/conf.d/apache.conf

EXPOSE 80 8080 3000

CMD ["/usr/bin/supervisord", "-n"]


