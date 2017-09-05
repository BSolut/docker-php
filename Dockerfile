FROM php:7.0-fpm

ENV TERM=xterm

RUN echo deb http://httpredir.debian.org/debian stable main contrib >/etc/apt/sources.list \
    && echo deb http://security.debian.org/ stable/updates main contrib >>/etc/apt/sources.list \
    && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
    && curl -sS https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        debian-archive-keyring \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libgeoip-dev \
        python \
        locales \
        geoip-bin geoip-database-contrib \
        nodejs \
        libgmp-dev \
        git\
        newrelic-php5 \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli bcmath mbstring zip gmp \
    && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pecl install apcu apcu_bc-beta && docker-php-ext-enable apcu  && docker-php-ext-enable apc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install geoip-beta && docker-php-ext-enable geoip \
    && echo "<?php var_dump(geoip_record_by_name('141.30.225.1')); " | php  | grep Dresden -cq || (echo "Geo not working" && exit 1) \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo -e "de_DE.UTF-8 UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15\nen_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8


RUN mv /usr/local/etc/php/conf.d/docker-php-ext-apc.ini /usr/local/etc/php/conf.d/zz-docker-php-ext-apc.ini

EXPOSE 9000

ADD zzz-bsolut-fpm.conf /usr/local/etc/php-fpm.d/
ADD bsolut-php.ini /usr/local/etc/php/conf.d/


ADD auth-key /
RUN \
  chmod 600 /auth-key && \  
  echo "IdentityFile /auth-key" >> /etc/ssh/ssh_config && \  
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ENTRYPOINT [ "/run.sh" ]

