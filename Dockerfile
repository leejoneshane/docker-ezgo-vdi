FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Taipei
ENV DISPLAY :1
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /root/chrome.deb
ADD https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb /root/crd.deb
ADD servers.conf /etc/supervisor/conf.d/servers.conf
   
RUN apt-get update \
    && apt-get install -y sudo vim-tiny wget git apt-transport-https ca-certificates pulseaudio fluxbox net-tools locales \
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
        openssh-server python-pip python-dev build-essential mesa-utils x11vnc xvfb xrdp supervisor \
        lubuntu-desktop lubuntu-default-settings libappindicator1 \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
#    && wget https://www.xmind.net/xmind/downloads/xmind-8-update4-linux.zip \
#    && unzip xmind-8-update4-linux.zip \
#    && /root/xmind-8-update4-linux/setup.sh \
#    && wget -O adobe-air.sh http://drive.noobslab.com/data/apps/AdobeAir/adobe-air.sh \
#    && chmod +x adobe-air.sh \
#    && ./adobe-air.sh \
#    && wget -O scratch2.air https://scratch.mit.edu/scratchr2/static/sa/Scratch-456.0.4.air \
    && apt-get install -y \
        ezgo-menu ezgo-lxde ezgo-artwork \
#        qtqr gimp tuxpaint inkscape vlc filezilla winff audacity firefox libreoffice \
#        libbz2-1.0:i386 adobeair ezgo-accessories ezgo-atayal ezgo-chem ezgo-common ezgo-doc \
#        ezgo-ecare ezgo-education ezgo-games ezgo-graphics ezgo-gsyan ezgo-misc ezgo-misc-7zip \
#        ezgo-misc-arduino-rules ezgo-misc-audacity ezgo-misc-decompress ezgo-misc-desktop-files \
#        ezgo-misc-furiusisomount ezgo-misc-inkscape ezgo-misc-installer icedtea-netx-common icedtea-netx default-jdk \
#        oracle-java8-installer jkiwi ezgo-misc-jkiwi ezgo-misc-kdenlive \
#        ezgo-misc-klavaro ezgo-misc-ksnapshot ezgo-misc-ktuberling ezgo-misc-qtqr ezgo-misc-recover \
#        ezgo-misc-tuxpaint ezgo-misc-winff ezgo-multimedia ezgo-network ezgo-npa ezgo-office ezgo-phet ezgo-s4a \
#        ezgo-tasks ezgo-unity ezgo-usgs ezgo-wordtest \
#        transformer-community ubiquity-slideshow-ezgo \
#        fcitx fcitx-chewing fcitx-frontend-all fcitx-libs-qt5 fcitx-table-array30-big fcitx-table-cangjie3 \
#        fcitx-tools fcitx-m17n ezgo-misc-fcitx-dayi3 \
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
	&& mkdir -p /home/ezgo/.fluxbox \
	&& echo ' \n\
		session.screen0.toolbar.visible:        false\n\
		session.screen0.fullMaximization:       true\n\
		session.screen0.maxDisableResize:       true\n\
		session.screen0.maxDisableMove: true\n\
		session.screen0.defaultDeco:    NONE\n\
	' >> /home/ezgo/.fluxbox/init \
	&& chown -R ezgo:ezgo /home/ezgo/.config /home/ezgo/.fluxbox /usr/log/supervisor

USER ezgo
EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
