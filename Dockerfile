FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1
ENV TZ=Asia/Taipei

RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo vim-tiny wget git apt-transport-https \
    && useradd -s /bin/bash ezgo \
    && usermod -G sudo ezgo \
    && wget --no-check-certificate -O - http://ezgo.goodhorse.idv.tw/apt/ezgo/ezgo.gpg.key | apt-key add - \
    && echo "deb http://ezgo.goodhorse.idv.tw/apt/ezgo/ ezgo13 main" > /etc/apt/sources.list.d/ezgo.list \
    && apt-get update \ 
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        nginx net-tools \
        kubuntu-desktop \
        qtqr gimp tuxpaint inkscape vlc filezilla winff audacity \
        about-ezgo adobeair ezgo-accessories ezgo-artwork ezgo-atayal ezgo-chem ezgo-common ezgo-doc ezgo-ecare \
        ezgo-education ezgo-games ezgo-graphics ezgo-gsyan ezgo-kde5 ezgo-menu ezgo-misc ezgo-misc-7zip \
        ezgo-misc-arduino-rules ezgo-misc-audacity ezgo-misc-decompress ezgo-misc-desktop-files \
        ezgo-misc-furiusisomount ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-jkiwi ezgo-misc-kdenlive \
        ezgo-misc-klavaro ezgo-misc-ksnapshot ezgo-misc-ktuberling ezgo-misc-qtqr ezgo-misc-recover \
        ezgo-misc-tuxpaint ezgo-misc-winff ezgo-multimedia ezgo-network ezgo-npa ezgo-office ezgo-phet \
        ezgo-s4a ezgo-scratch2 ezgo-tasks ezgo-unity ezgo-usgs ezgo-wordtest oxobasisr6* oxoffice6* \
        transformer-community ubiquity-slideshow-ezgo xmind \
        fcitx fcitx-chewing fcitx-frontend-all fcitx-libs-qt5 fcitx-table-array30-big fcitx-table-cangjie3 \
        fcitx-tools fcitx-m17n ezgo-misc-fcitx-dayi3 \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        x11vnc xvfb dbus-x11 x11-utils \
        supervisor \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_TW -c -f UTF-8 -A /usr/share/locale/locale.alias zh_TW.UTF-8 \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
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
