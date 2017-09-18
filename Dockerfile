FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1
ENV TZ=Asia/Taipei
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /root/chrome.deb
ADD https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb /root/crd.deb
ADD servers.conf /etc/supervisor/conf.d/servers.conf
   
RUN apt-get update \
    && apt-get install -y sudo vim-tiny wget git apt-transport-https ca-certificates \
	&& addgroup chrome-remote-desktop \
	&& useradd -m -s /bin/bash -G sudo,chrome-remote-desktop,pulse-access ezgo \
    && wget --no-check-certificate -O - https://ezgo.goodhorse.idv.tw/apt/ezgo/ezgo.gpg.key | apt-key add - \
    && echo "deb https://ezgo.goodhorse.idv.tw/apt/ezgo/ ezgo13 main" > /etc/apt/sources.list.d/ezgo.list \
    && dpkg --add-architecture i386 \
    && apt-get update \ 
    && apt-get install -y \
        openssh-server python-pip python-dev build-essential mesa-utils x11vnc xvfb xrdp supervisor \
        pulseaudio fluxbox \
        kubuntu-desktop \
#        qtqr gimp tuxpaint inkscape vlc filezilla winff audacity \
#        about-ezgo libbz2-1.0:i386 adobeair ezgo-accessories ezgo-artwork ezgo-atayal ezgo-chem ezgo-common ezgo-doc \
#        ezgo-ecare ezgo-education ezgo-games ezgo-graphics ezgo-gsyan ezgo-kde5 ezgo-menu ezgo-misc ezgo-misc-7zip \
#        ezgo-misc-arduino-rules ezgo-misc-audacity ezgo-misc-decompress ezgo-misc-desktop-files \
#        ezgo-misc-furiusisomount ezgo-misc-inkscape ezgo-misc-installer icedtea-netx-common icedtea-netx default-jdk \
#        oracle-java8-installer jkiwi ezgo-misc-jkiwi ezgo-misc-kdenlive \
#        ezgo-misc-klavaro ezgo-misc-ksnapshot ezgo-misc-ktuberling ezgo-misc-qtqr ezgo-misc-recover \
#        ezgo-misc-tuxpaint ezgo-misc-winff ezgo-multimedia ezgo-network ezgo-npa ezgo-office ezgo-phet ezgo-s4a \
#        libxt6:i386 libnspr4-0d:i386 libgtk2.0-0:i386 libstdc++6:i386 libnss3-1d:i386 libnss-mdns:i386 libnss-mdns libxml2:i386 libxslt1.1:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 \
#        ezgo-scratch2 ezgo-tasks ezgo-unity ezgo-usgs ezgo-wordtest libreoffice \
#        transformer-community ubiquity-slideshow-ezgo \
#        fcitx fcitx-chewing fcitx-frontend-all fcitx-libs-qt5 fcitx-table-array30-big fcitx-table-cangjie3 \
#        fcitx-tools fcitx-m17n ezgo-misc-fcitx-dayi3 \
#        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && cd /root \
    && dpkg -i ./chrome.deb && dpkg -i ./crd.deb && rm -f chrome.deb crd.deb \
#    && wget https://www.xmind.net/xmind/downloads/xmind-8-update4-linux.zip \
#    && unzip xmind-8-update4-linux.zip \
#    && /root/xmind-8-update4-linux/setup.sh \
#    && wget -O adobe-air.sh http://drive.noobslab.com/data/apps/AdobeAir/adobe-air.sh \
#    && chmod +x adobe-air.sh \
#    && ./adobe-air.sh \
#    && wget -O scratch2.air https://scratch.mit.edu/scratchr2/static/sa/Scratch-456.0.4.air \
    && localedef -i zh_TW -c -f UTF-8 -A /usr/share/locale/locale.alias zh_TW.UTF-8 \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && xrdp-keygen xrdp auto \
	&& mkdir -p /home/chrome/.config/chrome-remote-desktop \
	&& mkdir -p /home/chrome/.fluxbox \
	&& echo ' \n\
		session.screen0.toolbar.visible:        false\n\
		session.screen0.fullMaximization:       true\n\
		session.screen0.maxDisableResize:       true\n\
		session.screen0.maxDisableMove: true\n\
		session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init \
	&& chown -R ezgo:ezgo /home/ezgo/.config /home/ezgo/.fluxbox
    
WORKDIR /root
EXPOSE 80 3389 5900
CMD ["supervisord -n"]
