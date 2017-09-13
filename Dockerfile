FROM bsolut/php

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xfonts-base \
        xfonts-75dpi \
        xserver-common \
        fontconfig \
        unoconv \
    && DEBIAN_FRONTEND=noninteractive apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN curl -SLO "http://ftp.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb" \
    && DEBIAN_FRONTEND=noninteractive dpkg -i libpng12-0_1.2.50-2+deb8u3_amd64.deb \
    && rm libpng12-0_1.2.50-2+deb8u3_amd64.deb

RUN curl -SLO "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb" \
    && DEBIAN_FRONTEND=noninteractive  dpkg -i wkhtmltox-0.12.2.1_linux-jessie-amd64.deb \
    && rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

COPY *.sh /
RUN chmod u+rwx /*.sh

ENV QT_QPA_PLATFORM=offscreen

RUN mkdir -p /var/www/.cache/dconf && chmod a+rwx /var/www/.cache/dconf

ENTRYPOINT [ "/run2.sh" ]