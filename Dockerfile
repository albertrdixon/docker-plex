FROM debian:8
MAINTAINER Albert Dixon <albert@dixon.rocks>

ENTRYPOINT ["/bin/tini", "-g", "--", "/sbin/entry"]
CMD ["/sbin/docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 33400 1900 5353 32410 32412 32413 32414 32469

ENV DEBIAN_FRONTEND=noninteractive \
    FD_LIMIT=32768 \
    GOSU_VER=1.9 \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/plexmediaserver \
    PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6 \
    PLEX_MEDIA_SERVER_MAX_STACK_SIZE=4000 \
    PLEX_MEDIA_SERVER_TMPDIR=/tmp \
    PLEX_MEDIA_SERVER_USER=plex \
    PLEX_UID=7000 \
    PLEX_GID=7000 \
    PLEX_VER=1.1.3.2700-6f64a8d-debian \
    TINI_VER=v0.10.0 \
    USE_TRAKT=yes \
    USE_UAS=yes \
    USE_SUBLIMINAL=no

COPY dummy /bin/start
COPY dummy /bin/systemctl
COPY dummy /bin/service

RUN apt-get update \
    && apt-get install -y locales \
    && sed -i 's|# en_US.UTF-8|en_US.UTF-8|' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure locales
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN useradd --create-home --user-group \
      --home-dir ${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR} \
      --shell /bin/bash \
      --uid ${PLEX_UID} plex \
    && groupmod --gid ${PLEX_GID} plex
RUN apt-get install -y --force-yes --no-install-recommends wget libssl-dev \
    && wget -q --show-progress --progress=bar:force:noscroll -O - http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key | apt-key add - \
    && echo "deb http://shell.ninthgate.se/packages/debian plexpass main" > /etc/apt/sources.list.d/plexmediaserver.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        ca-certificates \
        openssl \
        plexmediaserver=${PLEX_VER} \
        rsync \
        unzip \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-$dpkgArch" \
    && wget -O /bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-$dpkgArch.asc" \
    && wget -O /bin/tini "https://github.com/krallin/tini/releases/download/${TINI_VER}/tini" \
    && wget -O /bin/tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VER}/tini.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 0527A9B7 \
    && gpg --batch --verify /bin/gosu.asc /bin/gosu \
    && gpg --batch --verify /bin/tini.asc /bin/tini \
    && chmod +x /bin/tini /bin/gosu \
    && wget -O /sublim.zip https://github.com/bramwalet/Subliminal.bundle/archive/master.zip \
    && wget -O /trakt.zip https://github.com/trakt/Plex-Trakt-Scrobbler/archive/master.zip \
    && wget -O /webtools.zip https://github.com/dagalufh/WebTools.bundle/archive/master.zip \
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
    && chown -R plex:plex "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" \
    && apt-get autoremove -y && apt-get autoclean -y \
    && /bin/gosu nobody true \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
          /Plex-Trakt-Scrobbler-master /bin/*.asc \
          "$GNUPGHOME"

COPY ["entry", "docker-start", "/sbin/"]
COPY preroll /preroll

WORKDIR /usr/lib/plexmediaserver
