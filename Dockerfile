FROM ubuntu
MAINTAINER Albert Dixon <albert@dixon.rocks>

ENTRYPOINT ["dumb-init", "/sbin/entry"]
CMD ["/sbin/docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 1900 5353 32410 32412 32413 32414 32469

ENV DEBIAN_FRONTEND=noninteractive \
    DOWNLOADDIR=/tmp/plexupdate \
    FD_LIMIT=32768 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/plexmediaserver \
    PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6 \
    PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000 \
    PLEX_MEDIA_SERVER_TMPDIR=/tmp \
    PLEX_MEDIA_SERVER_USER=plex \
    PLEX_UID=7000 \
    PLEX_GID=7000

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libxml2 \
        openssl \
        python \
        python-dev \
        ruby \
        ruby-dev \
        supervisor \
        unzip \
        wget \
    && gem install clockwork \
    && git clone --depth=1 https://github.com/mrworf/plexupdate.git /plexupdate \
    && curl -kL# --retry 3 -o /init.deb https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64.deb \
    && curl -kL# --retry 3 https://github.com/albertrdixon/tmplnator/releases/download/v2.2.1/t2-linux.tgz |\
            tar xz -C /bin \
    && curl -kL# --retry 3 -o /sublim.zip https://github.com/bramwalet/Subliminal.bundle/archive/master.zip \
    && curl -kL# --retry 3 -o /trakt.zip https://github.com/trakt/Plex-Trakt-Scrobbler/archive/master.zip \
    && curl -kL# --retry 3 -o /webtools.zip https://github.com/dagalufh/WebTools.bundle/archive/master.zip \
    && dpkg -i /init.deb && rm -f /init.deb \
    && groupadd -g ${PLEX_GID} plex \
    && useradd -M -N -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" -g ${PLEX_GID} -u ${PLEX_UID} plex \
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
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/* /Plex-Trakt-Scrobbler-master

COPY preroll /preroll
COPY dummy /bin/start
COPY dummy /bin/systemctl
COPY dummy /bin/service
COPY ["entry", "docker-start", "/sbin/"]
COPY clock.rb /
COPY supervisord.conf /etc/
