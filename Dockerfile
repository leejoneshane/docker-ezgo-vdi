FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW
ENV DISPLAY :1

COPY plasmarc /etc/skel/.config/plasmarc
COPY servers.conf /etc/supervisor/conf.d/servers.conf
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop
COPY scratch-desktop_1.2.1_amd64.deb /tmp/scratch-desktop_1.2.1_amd64.deb
COPY scratch-desktop.desktop /usr/share/applications/scratch-desktop.desktop
COPY xmind-installer.sh /tmp/xmind-installer.sh
COPY install-xmind.sh /usr/share/applications/install-xmind.sh

RUN apt-get update && apt-get install -y sudo gnupg2 libglib2.0-bin wget git vim gdebi \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4CD565B5 \
    && echo "deb http://free.nchc.org.tw/ezgo-core testing main" | tee /etc/apt/sources.list.d/ezgo.list \
    && add-apt-repository -y ppa:libreoffice/ppa \
    && apt-get update \
    && apt-get install -yq kde-plasma-desktop pulseaudio locales x11vnc xvfb xrdp supervisor fonts-liberation libappindicator3-1 \
                           libdbusmenu-gtk3-4 libindicator3-7 xbase-clients python-psutil language-pack-kde-zh-hant \
    && apt-get install -yq about-ezgo ezgo-accessories ezgo-artwork ezgo-menu ezgo-kde5 ezgo-phet ezgo-usgs ezgo-npa ezgo-chem \
                           ezgo-gsyan ezgo-wordtest firefox ezgo-games ezgo-common ezgo-doc ezgo-education ezgo-graphics \
                           ezgo-network ezgo-office ezgo-unity libreoffice audacity \
    && apt-get install -yq ezgo-misc-arduino-rules ezgo-misc-decompress ezgo-misc-desktop-files ezgo-misc-furiusisomount \
                           ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive ezgo-misc-klavaro ezgo-misc-ktuberling \
                           ezgo-misc-qtqr ezgo-misc-winff ezgo-misc-7zip ezgo-misc-audacity ezgo-misc-tuxpaint \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup chrome-remote-desktop \
    && useradd -m -s /bin/bash -G sudo,chrome-remote-desktop,pulse-access ezgo \
    && echo "ezgo:ezgo" | chpasswd \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen "zh_TW.UTF-8" \
    && dpkg-reconfigure locales \
    && ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone \
    && sed -i 's/LANG=\(.*\)/LANG=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/LANGUAGE=\(.*\)/LANGUAGE=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/defaultWallpaperTheme=.*/defaultWallpaperTheme=ezgo/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperWidth=.*/defaultWallpaperWidth=1920/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperHeight=.*/defaultWallpaperHeight=1080/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && echo "run_im fcitx" > /etc/skel/.xinputrc \
    && cd /root \
    && wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && wget -O crd.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
    && dpkg -i ./chrome.deb && dpkg -i ./crd.deb && rm -f chrome.deb crd.deb \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cp /usr/lib/noVNC/vnc.html /usr/lib/noVNC/index.html \
    && cd /usr/lib/noVNC/utils \
    && git clone https://github.com/novnc/websockify \
    && xrdp-keygen xrdp auto \
    && mkdir -p /home/ezgo/.config/chrome-remote-desktop \
    && echo startkde >> /home/ezgo/.xsession \
    && chown -R ezgo:ezgo /home/ezgo \
    && echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config \
    && gdebi /tmp/scratch-desktop_1.2.1_amd64.deb \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && update-alternatives --set x-www-browser /usr/bin/firefox
    
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
