FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW
ENV DISPLAY :1

COPY plasmarc /etc/skel/.config/plasmarc
COPY servers.conf /etc/supervisor/conf.d/servers.conf
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop

RUN apt-get update \
    && echo "6\n73" | apt-get install -yq tzdata \
    && apt-get install -yq sudo gnupg2 wget git vim gdebi libglib2.0-bin software-properties-common openjdk-11-jdk python3-psutil \
    && echo "1" | apt-get install -yq kde-plasma-desktop \
    && apt-get install -yq pulseaudio locales x11vnc xvfb xrdp supervisor fonts-liberation libappindicator3-1 \
                           libdbusmenu-gtk3-4 libindicator3-7 xbase-clients python-psutil language-pack-kde-zh-hant \
    && wget -q https://free.nchc.org.tw/ezgo-core/ezgo.gpg.key -O- | sudo apt-key add - \
    && echo "deb http://free.nchc.org.tw/ezgo-core testing main" | tee /etc/apt/sources.list.d/ezgo.list \
    && echo "\n" | add-apt-repository ppa:libreoffice/ppa \
    && apt-get update \
    && apt-get install -yq about-ezgo ezgo-accessories ezgo-artwork ezgo-menu ezgo-kde5 ezgo-phet ezgo-usgs ezgo-npa ezgo-chem \
                           ezgo-gsyan ezgo-wordtest firefox ezgo-games ezgo-common ezgo-education ezgo-graphics ezgo-unity \
                           ezgo-network ezgo-office audacity ezgo-multimedia libreoffice \
                           ezgo-misc-arduino-rules ezgo-misc-decompress ezgo-misc-desktop-files \
                           ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive ezgo-misc-klavaro ezgo-misc-ktuberling \
                           ezgo-misc-qtqr ezgo-misc-winff ezgo-misc-7zip ezgo-misc-audacity ezgo-misc-tuxpaint \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -G sudo,pulse-access ezgo \
    && echo "ezgo:ezgo" | chpasswd \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen "zh_TW.UTF-8" \
    && ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone \
    && sed -i 's/LANG=\(.*\)/LANG=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/LANGUAGE=\(.*\)/LANGUAGE=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/defaultWallpaperTheme=.*/defaultWallpaperTheme=ezgo/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperWidth=.*/defaultWallpaperWidth=1920/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperHeight=.*/defaultWallpaperHeight=1080/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && echo "run_im fcitx" > /etc/skel/.xinputrc \
    && cd /root \
    && wget https://github.com/scratux/scratux/releases/download/1.4.1/scratux_1.4.1_amd64.deb \
    && dpkg -i scratux_1.4.1_amd64.deb \
#    && wget https://www.xmind.net/xmind/downloads/XMind-2020-for-Linux-amd-64bit-10.2.1-202008051959.deb \
#    && dpkg -i XMind-2020-for-Linux-amd-64bit-10.2.1-202008051959.deb \
    && wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i ./chrome.deb && rm -f chrome.deb \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cp /usr/lib/noVNC/vnc.html /usr/lib/noVNC/index.html \
    && cd /usr/lib/noVNC/utils \
    && git clone https://github.com/novnc/websockify \
    && xrdp-keygen xrdp auto \
    && echo startkde >> /home/ezgo/.xsession \
    && echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && chown -R ezgo:ezgo /home/ezgo
    
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
