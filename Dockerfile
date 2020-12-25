FROM kdeneon/plasma

ENV LC_ALL zh_TW.UTF-8
ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW
USER root

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone \
    && apt-get install -y tzdata locales \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen "zh_TW.UTF-8" \
    && apt-get install -yq sudo pulseaudio gnupg2 wget git vim mc software-properties-common python language-pack-kde-zh-hant \
    && apt-get install -yq dbus-x11 x11vnc xvfb xrdp supervisor \
    && wget -q https://free.nchc.org.tw/ezgo-core/ezgo.gpg.key -O- | sudo apt-key add - \
    && echo "deb http://free.nchc.org.tw/ezgo-core testing main" | tee /etc/apt/sources.list.d/ezgo.list \
    && apt-get update \
    && apt-get install -yq about-ezgo ezgo-accessories ezgo-artwork ezgo-menu ezgo-kde5 ezgo-phet ezgo-usgs ezgo-npa \
                           ezgo-gsyan ezgo-wordtest ezgo-chem ezgo-common ezgo-education ezgo-graphics ezgo-unity \
                           ezgo-network ezgo-office audacity ezgo-multimedia \
                           ezgo-misc-arduino-rules ezgo-misc-decompress ezgo-misc-desktop-files \
                           ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive ezgo-misc-klavaro ezgo-misc-ktuberling \
                           ezgo-misc-qtqr ezgo-misc-winff ezgo-misc-7zip ezgo-misc-audacity ezgo-misc-tuxpaint \
    && apt-get remove -y scratch \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get -y install msttcorefonts fontconfig \
    && fc-cache -f -v \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -G sudo,pulse-access ezgo \
    && echo "ezgo:ezgo" | chpasswd -e \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && sed -i 's/LANG=\(.*\)/LANG=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/LANGUAGE=\(.*\)/LANGUAGE=\"zh_TW.UTF-8\"/g' /etc/default/locale \
    && sed -i 's/defaultWallpaperTheme=.*/defaultWallpaperTheme=ezgo/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperWidth=.*/defaultWallpaperWidth=1920/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && sed -i 's/defaultWallpaperHeight=.*/defaultWallpaperHeight=1080/' /usr/share/plasma/desktoptheme/*/metadata.desktop \
    && echo "run_im fcitx" > /etc/skel/.xinputrc \
    && cd /root \
    && wget https://github.com/scratux/scratux/releases/download/1.4.1/scratux_1.4.1_amd64.deb \
    && dpkg -i scratux_1.4.1_amd64.deb \
    && wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i ./chrome.deb && rm -f chrome.deb \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cp /usr/lib/noVNC/vnc.html /usr/lib/noVNC/index.html \
    && cd /usr/lib/noVNC/utils \
    && git clone https://github.com/novnc/websockify \
    && xrdp-keygen xrdp auto \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && cp /home/neon/.gitconfig /home/ezgo/.gitconfig \
    && mkdir /home/ezgo/.config && cp /home/neon/.config/kwinrc /home/ezgo/.config \
    && userdel -r neon \
    && mkdir /run/ezgo \
    && chown -R ezgo:ezgo /home/ezgo /run/ezgo \
    && chmod -R 7700 /run/ezgo 

COPY plasmarc /etc/skel/.config/plasmarc
COPY servers.conf /etc/supervisor/conf.d/servers.conf
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop

ENV DISPLAY :1
ENV KDE_FULL_SESSION true
ENV SHELL /bin/bash
ENV XDG_RUNTIME_DIR /run/ezgo
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
