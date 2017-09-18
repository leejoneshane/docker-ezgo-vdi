FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1
ENV TZ=Asia/Taipei

RUN apt-get update \
    && apt-get install -y sudo vim-tiny wget git apt-transport-https ca-certificates \
    && useradd -s /bin/bash ezgo \
    && usermod -G sudo ezgo \
    && wget --no-check-certificate -O - https://ezgo.goodhorse.idv.tw/apt/ezgo/ezgo.gpg.key | apt-key add - \
    && echo "deb https://ezgo.goodhorse.idv.tw/apt/ezgo/ testing main" > /etc/apt/sources.list.d/ezgo.list \
    && apt-get update \ 
    && apt-get install -y \
        nginx net-tools \
        kubuntu-desktop \       
        qtqr gimp tuxpaint inkscape vlc filezilla winff audacity \
        about-ezgo libbz2-1.0:i386 adobeair ezgo-accessories ezgo-artwork ezgo-atayal ezgo-chem ezgo-common ezgo-doc \
        ezgo-ecare ezgo-education ezgo-games ezgo-graphics ezgo-gsyan ezgo-kde5 ezgo-menu ezgo-misc ezgo-misc-7zip \
        ezgo-misc-arduino-rules ezgo-misc-audacity ezgo-misc-decompress ezgo-misc-desktop-files \
        ezgo-misc-furiusisomount ezgo-misc-inkscape ezgo-misc-installer sun-java6-jre sun-java5-jre icedtea-java7-jre \
        openjdk-6-jre jkiwi ezgo-misc-jkiwi ezgo-misc-kdenlive \
        ezgo-misc-klavaro ezgo-misc-ksnapshot ezgo-misc-ktuberling ezgo-misc-qtqr ezgo-misc-recover \
        ezgo-misc-tuxpaint ezgo-misc-winff ezgo-multimedia ezgo-network ezgo-npa ezgo-office ezgo-phet \
        ezgo-s4a libxt6:i386 libnspr4-0d:i386 libgtk2.0-0:i386 libstdc++6:i386 libnss3-1d:i386 libnss-mdns:i386 \
        libxml2:i386 libxslt1.1:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libgnome-keyring0:i386 \
        ezgo-scratch2 ezgo-tasks ezgo-unity ezgo-usgs ezgo-wordtest libreoffice \
        transformer-community ubiquity-slideshow-ezgo \
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
    && cd /root \
    && wget https://www.xmind.net/xmind/downloads/xmind-8-update4-linux.zip \
    && unzip xmind-8-update4-linux.zip \
    && /root/xmind-8-update4-linux/setup.sh \
    && wget -O adobe-air.sh http://drive.noobslab.com/data/apps/AdobeAir/adobe-air.sh \
    && chmod +x adobe-air.sh \
    && ./adobe-air.sh \
    && wget -O scratch2.air https://scratch.mit.edu/scratchr2/static/sa/Scratch-456.0.4.air \
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
