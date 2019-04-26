FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Taipei

COPY plasmarc /etc/skel/.config/plasmarc
COPY servers.conf /etc/supervisor/conf.d/servers.conf
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop

RUN apt-get update && apt-get install -y gnupg2 libglib2.0-bin wget git \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4CD565B5 \
    && echo "deb http://free.nchc.org.tw/ezgo-core testing main" | tee /etc/apt/sources.list.d/ezgo.list \
    && mkdir -p /usr/share/locale-langpack/zh_TW/LC_MESSAGES \
    && apt-get update \
    && apt-get install -yq plasma-desktop pulseaudio locales x11vnc xvfb xrdp supervisor fonts-liberation libappindicator3-1 \
               libdbusmenu-gtk3-4 libindicator3-7 xbase-clients python-psutil \
    && apt-get install -yq ezgo-artwork ezgo-menu ezgo-kde5 ezgo-phet ezgo-usgs ezgo-npa ezgo-chem ezgo-gsyan ezgo-wordtest \
                           ezgo-misc-arduino-rules ezgo-misc-decompress ezgo-misc-desktop-files ezgo-misc-furiusisomount \
                           ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive ezgo-misc-klavaro ezgo-misc-ktuberling \
                           ezgo-misc-qtqr ezgo-misc-winff \
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
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && sed -i 's/LANG=\(.*\)/LANG=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/LANGUAGE=\(.*\)/LANGUAGE=\"zh_TW\"/g' /etc/default/locale \
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
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
    
USER ezgo
WORKDIR /home/ezgo

ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW.utf-8
ENV LC_ALL zh_TW.UTF-8
ENV DISPLAY :1

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
