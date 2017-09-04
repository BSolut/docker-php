FROM bsolut/php

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xfonts-base \
        xfonts-75dpi \
        xserver-common \
        fontconfig \
        unoconv \
    && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -SLO "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb" \
    && dpkg -i wkhtmltox-0.12.2.1_linux-jessie-amd64.deb \
    && rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

COPY *.sh /
RUN chmod u+rwx /*.sh

ENTRYPOINT [ "/run2.sh" ]