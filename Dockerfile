FROM php:5.6-apache

RUN a2enmod rewrite expires

# install the PHP extensions we need, also nodejs for sshapi
RUN     echo deb http://httpredir.debian.org/debian stable main contrib >>/etc/apt/sources.list \
    && echo deb http://security.debian.org/ stable/updates main contrib >>/etc/apt/sources.list \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libpng12-dev libjpeg-dev locales supervisor git\
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl python-software-properties expect-dev \
    && curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && DEBIAN_FRONTEND=noninteractive  apt-get -y install nodejs \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli opcache \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=0'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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


