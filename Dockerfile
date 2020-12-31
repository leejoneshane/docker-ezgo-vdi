ARG TAG=rolling
FROM ubuntu:$TAG as builder

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        m4 libtool build-essential dpkg-dev git libpulse-dev libcap-dev libudev-dev \
        libsndfile1-dev libspeexdsp-dev libdbus-1-dev libdbus-glib-1-dev libltdl-dev pulseaudio \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global http.sslverify false \
    && cd /root && git clone git://git.launchpad.net/~ubuntu-audio-dev/pulseaudio \
    && cd pulseaudio && ./configure \
    && cd /root && git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git \
    && cd pulseaudio-module-xrdp && ./bootstrap && ./configure PULSE_DIR=/root/pulseaudio \
    && make && make install \
    && cd /root && rm -rf /root/pulseaudio && rm -rf /root/pulseaudio-module-xrdp

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
    && apt-get install -yq sudo pavucontrol pulseaudio pulseaudio-utils \
                           gnupg2 wget git vim mc software-properties-common python \
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

COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/

RUN mv /home/neon /home/ezgo \
    && useradd -G admin,video,sudo,pulse-access -d /home/ezgo -ms /bin/bash ezgo \
    && echo 'ezgo:ezgo' | chpasswd \
    && echo 'ezgo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 \
    && echo 'exit-idle-time = -1' >> /etc/pulse/daemon.conf \
    && mkdir /run/ezgo \
    && chown -R ezgo:ezgo /home/ezgo /run/ezgo \
    && chmod -R 755 /home/ezgo/.config \
    && chmod -R 7700 /run/ezgo \
    && rm -rf /usr/share/wallpapers/ezgo/contents/images/2560x1600.png \
    && sed -i 's/Image=.*/Image=ezgo/' /usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents/defaults \
    && sed -i "s/; autospawn=*/autospawn=yes/" /etc/pulse/client.conf

COPY securetty /etc/securetty
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
ENV PULSE_SERVER unix:/home/ezgo/.config/pulse/native-sock
ENV PULSE_COOKIE unix:/home/ezgo/.config/pulse/cookie
USER ezgo
WORKDIR /home/ezgo

EXPOSE 80 3389 5900
CMD sudo /usr/bin/supervisord -n
