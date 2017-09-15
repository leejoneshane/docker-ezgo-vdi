FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated wget git nginx \
        kubuntu-desktop \
        supervisor \
        sudo vim-tiny \
        net-tools \
        x11vnc xvfb \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        dbus-x11 x11-utils \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_TW -c -f UTF-8 -A /usr/share/locale/locale.alias zh_TW.UTF-8 \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cd /bin \
    && wget https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    && chmod +x /bin/tini
    
ADD default.conf /etc/nginx/sites-enabled/default
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root
EXPOSE 80 5900
ENTRYPOINT ["/startup.sh"]
