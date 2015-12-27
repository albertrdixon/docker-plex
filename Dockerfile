FROM debian
MAINTAINER Albert Dixon <albert.dixon@schange.com>

ENTRYPOINT ["tini", "-g", "--", "/usr/local/sbin/entry"]
CMD ["docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 1900 5353 32410 32412 32413 32414 32469

ENV DEBIAN_FRONTEND=noninteractive \
    FD_LIMIT=12288 \
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
    PLEX_VER=0.9.14.5.1595-5c6e524-debian \
    TINI_VER=v0.8.4

ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}:${LD_LIBRARY_PATH}" \
    TMPDIR=${PLEX_MEDIA_SERVER_TMPDIR}

COPY ["entry", "docker-start", "/usr/local/sbin/"]
COPY dummy /bin/start
COPY dummy /bin/systemctl
COPY preroll /preroll

# ADD https://github.com/krallin/tini/releases/download/${TINI_VER}/tini /bin/
# ADD https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-amd64 /bin/gosu
# ADD http://bit.ly/ihqmEu /uas.zip
# ADD http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key /ninthgate.key

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends wget \
    && wget -q --show-progress -O - http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | apt-key add - \
    && echo "deb http://shell.ninthgate.se/packages/debian plexpass main" > /etc/apt/sources.list.d/plexmediaserver.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        ca-certificates \
        plexmediaserver=${PLEX_VER} \
        unzip \
    && echo -e "# Plex Libs\n${PLEX_MEDIA_SERVER_HOME}" >/etc/ld.so.conf.d/plexmediaserver.conf \
    && ldconfig -v \
    && wget -q --show-progress -O /bin/tini https://github.com/krallin/tini/releases/download/${TINI_VER}/tini \
    && wget -q --show-progress -O /bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-amd64 \
    && wget -q --show-progress -O /uas.zip http://bit.ly/ihqmEu \
    && bash -c 'chmod +x /bin/{tini,gosu} /usr/local/sbin/{entry,docker-start}' \
    && mkdir -p "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins" \
    && unzip /uas.zip -d "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Plug-ins" \
    && chown -R plex "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}" \
    && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -M plex || true
WORKDIR /usr/lib/plexmediaserver
