FROM debian
MAINTAINER Albert Dixon <albert@dixon.rocks>

ENTRYPOINT ["tini", "-g", "--", "/usr/local/sbin/entry"]
CMD ["docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 33400 1900 5353 32410 32412 32413 32414 32469

ENV DEBIAN_FRONTEND=noninteractive \
    FD_LIMIT=32768 \
    GOSU_VER=1.7 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/plexmediaserver \
    PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6 \
    PLEX_MEDIA_SERVER_MAX_STACK_SIZE=4000 \
    PLEX_MEDIA_SERVER_TMPDIR=/tmp \
    PLEX_MEDIA_SERVER_USER=plex \
    PLEX_UID=7000 \
    PLEX_GID=7000 \
    PLEX_VER=0.9.16.3.1840-cece46d-debian \
    TINI_VER=v0.8.4

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends wget libssl-dev \
    && wget -q --show-progress --progress=bar:force:noscroll -O - http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | apt-key add - \
    && echo "deb http://shell.ninthgate.se/packages/debian plexpass main" > /etc/apt/sources.list.d/plexmediaserver.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        ca-certificates \
        openssl \
        plexmediaserver=${PLEX_VER} \
        unzip \
    && wget -q --show-progress --progress=bar:force:noscroll -O /bin/tini https://github.com/krallin/tini/releases/download/${TINI_VER}/tini \
    && wget -q --show-progress --progress=bar:force:noscroll -O /bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-amd64 \
    && wget -q --show-progress --progress=bar:force:noscroll -O /sublim.zip https://github.com/bramwalet/Subliminal.bundle/archive/master.zip \
    && wget -q --show-progress --progress=bar:force:noscroll -O /trakt.zip https://github.com/trakt/Plex-Trakt-Scrobbler/archive/master.zip \
    && wget -q --show-progress --progress=bar:force:noscroll -O /webtools.zip https://github.com/dagalufh/WebTools.bundle/archive/master.zip \
    && chmod +x /bin/tini /bin/gosu \
    && mkdir -p "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins" \
    && unzip /sublim.zip -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins" \
    && mv -v "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins/Subliminal.bundle-master" \
        "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins/Subliminal.bundle" \
    && unzip /trakt.zip \
    && mv -v "/Plex-Trakt-Scrobbler-master/Trakttv.bundle" \
        "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins/" \
    && unzip /webtools.zip -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins" \
    && mv -v "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins/WebTools.bundle-master" \
        "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins/WebTools.bundle" \
    && chown -R plex "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" \
    && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/* /Plex-Trakt-Scrobbler-master

COPY ["entry", "docker-start", "/usr/local/sbin/"]
COPY dummy /bin/start
COPY dummy /bin/systemctl
COPY dummy /bin/service
COPY preroll /preroll

RUN useradd -M plex || true
WORKDIR /usr/lib/plexmediaserver
