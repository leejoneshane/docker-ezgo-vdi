FROM kdeneon/plasma

ENV LC_ALL zh_TW.UTF-8
ENV LANG zh_TW.UTF-8
ENV LANGUAGE zh_TW
USER root

RUN apt-get update \
    && ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone \
    && apt-get install -y tzdata locales \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen "zh_TW.UTF-8" \
    && apt-get install -yq sudo pulseaudio gnupg2 wget git vim mc software-properties-common python \
                        language-pack-gnome-zh-hant language-pack-kde-zh-hant \
    && apt-get install -yq dbus-x11 x11vnc xvfb xrdp supervisor \
    && wget -q https://free.nchc.org.tw/ezgo-core/ezgo.gpg.key -O- | sudo apt-key add - \
    && echo "deb http://free.nchc.org.tw/ezgo-core testing main" | tee /etc/apt/sources.list.d/ezgo.list \
    && apt-get update \
    && apt-get install -yq about-ezgo ezgo-accessories ezgo-artwork ezgo-menu ezgo-kde5 ezgo-phet ezgo-usgs ezgo-npa \
                           ezgo-wordtest ezgo-chem ezgo-common ezgo-education ezgo-graphics ezgo-unity \
                           ezgo-network ezgo-office audacity ezgo-multimedia \
                           ezgo-misc-arduino-rules ezgo-misc-decompress ezgo-misc-desktop-files \
                           ezgo-misc-inkscape ezgo-misc-installer ezgo-misc-kdenlive ezgo-misc-klavaro ezgo-misc-ktuberling \
                           ezgo-misc-qtqr ezgo-misc-winff ezgo-misc-7zip ezgo-misc-audacity ezgo-misc-tuxpaint \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get -y install ttf-mscorefonts-installer fontconfig fcitx fcitx-chewing \
    && fc-cache -f -v \
    && echo "run_im fcitx" > /etc/skel/.xinputrc \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/scratux/scratux/releases/download/1.4.1/scratux_1.4.1_amd64.deb \
    && dpkg -i scratux_1.4.1_amd64.deb && rm -f scratux_1.4.1_amd64.deb \
    && wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i ./chrome.deb && rm -f chrome.deb \
    && cd /usr/lib \
    && git clone https://github.com/novnc/noVNC \
    && cp /usr/lib/noVNC/vnc.html /usr/lib/noVNC/index.html \
    && cd /usr/lib/noVNC/utils \
    && git clone https://github.com/novnc/websockify \
    && xrdp-keygen xrdp auto

RUN mv /home/neon /home/ezgo \
    && usermod -d /home/ezgo -l ezgo neon \
    && echo "ezgo\nezgo" | passwd ezgo \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && mkdir /run/ezgo \
    && chown -R ezgo:neon /home/ezgo /run/ezgo \
    && chmod -R 755 /home/ezgo/.config \
    && chmod -R 7700 /run/ezgo \
    && rm -rf /usr/share/wallpapers/ezgo/contents/images/2560x1600.png \
    && sed -i 's/Image=.*/Image=ezgo/' /usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents/defaults

COPY servers.conf /etc/supervisor/conf.d/servers.conf
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop

ENV DISPLAY :1
ENV KDE_FULL_SESSION true
ENV HOME /home/ezgo
ENV SHELL /bin/bash
ENV XDG_CONFIG_HOME /home/ezgo/.config
ENV XDG_RUNTIME_DIR /run/ezgo
ENV XMODIFIERS @im=fcitx
ENV QT_IM_MODULE fcitx
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
