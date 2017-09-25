FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV SCRATCH_VERSION 456.0.4
ENV TZ Asia/Taipei
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /root/chrome.deb
ADD https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb /root/crd.deb
ADD servers.conf /etc/supervisor/conf.d/servers.conf

RUN apt-get update \
    && apt-get install -y sudo vim-tiny wget git apt-transport-https ca-certificates pulseaudio python-psutil locales \
    && addgroup chrome-remote-desktop \
    && useradd -m -s /bin/bash -G chrome-remote-desktop,pulse-access ezgo \
    && echo "ezgo:ezgo" | chpasswd \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && wget --no-check-certificate -O - https://ezgo.goodhorse.idv.tw/apt/ezgo/ezgo.gpg.key | apt-key add - \
    && echo "deb https://ezgo.goodhorse.idv.tw/apt/ezgo/ ezgo13 main" > /etc/apt/sources.list.d/ezgo.list \
    && dpkg --add-architecture i386 \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen "zh_TW.UTF-8" \
    && dpkg-reconfigure locales \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y \
        net-tools openssh-server python-pip python-dev build-essential mesa-utils x11vnc xvfb xrdp supervisor \
        lubuntu-desktop lubuntu-default-settings libglib2.0-bin libappindicator1 gconf-service libgconf-2-4 \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox firefox-locale-zh-hant libreoffice libreoffice-l10n-zh-tw \
	msttcorefonts ttf-ubuntu-font-family fonts-wqy-microhei icedtea-netx icedtea-plugin \
        qtqr gimp tuxpaint inkscape vlc filezilla winff audacity p7zip wine \
#    && cd /root \
#    && wget --no-check-certificate https://www.xmind.net/xmind/downloads/xmind-8-update4-linux.zip \
#    && unzip xmind-8-update4-linux.zip \
#    && /root/xmind-8-update4-linux/setup.sh \
#    && wget -O adobe-air.sh http://drive.noobslab.com/data/apps/AdobeAir/adobe-air.sh \
#    && chmod +x adobe-air.sh \
#    && ./adobe-air.sh \
#    && wget -O scratch2.air "https://scratch.mit.edu/scratchr2/static/sa/Scratch-$SCRATCH_VERSION.air" \
    && apt-get install -y \
        about-ezgo ezgo-menu ezgo-kde ezgo-artwork ezgo-games \
        ezgo-accessories ezgo-atayal ezgo-chem ezgo-common \
        ezgo-ecare ezgo-education ezgo-graphics ezgo-gsyan ezgo-phet ezgo-s4a \
        ezgo-misc-7zip ezgo-misc-arduino-rules ezgo-misc-audacity ezgo-misc-decompress ezgo-misc-desktop-files \
        ezgo-misc-furiusisomount ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive \
        ezgo-misc-klavaro ezgo-misc-ksnapshot ezgo-misc-ktuberling ezgo-misc-qtqr ezgo-misc-recover \
        ezgo-misc-tuxpaint ezgo-misc-winff ezgo-multimedia ezgo-network ezgo-npa ezgo-office \
        ezgo-tasks ezgo-unity ezgo-usgs ezgo-wordtest transformer-community ubiquity-slideshow-ezgo \
        fcitx fcitx-chewing fcitx-libs-qt5 fcitx-table-array30-big fcitx-table-cangjie3 \
        fcitx-tools fcitx-m17n ezgo-misc-fcitx-dayi3 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && cd /root \
    && dpkg -i ./chrome.deb && dpkg -i ./crd.deb && rm -f chrome.deb crd.deb \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cd /usr/lib/noVNC/utils \
    && git clone https://github.com/novnc/websockify \
    && xrdp-keygen xrdp auto \
    && mkdir -p /home/ezgo/.config/chrome-remote-desktop \
    && echo startkde >> /home/ezgo/.xsession \
    && chown -R ezgo:ezgo /home/ezgo/.config

ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW.utf-8
ENV LC_ALL zh_TW.UTF-8
ENV DISPLAY :1
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
