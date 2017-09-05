FROM bsolut/php:slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xfonts-base \
        xfonts-75dpi \
        xserver-common \
        fontconfig \
        wkhtmltopdf \
        unoconv \
    && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY *.sh /
RUN chmod u+rwx /*.sh

ENV QT_QPA_PLATFORM=offscreen

ENTRYPOINT [ "/run2.sh" ]