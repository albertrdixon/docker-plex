FROM ubuntu:15.10
MAINTAINER Albert Dixon <albert.dixon@schange.com>

ENTRYPOINT ["tini", "-g", "--", "entry"]
CMD ["start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 1900 5353 32410 32412 32413 32414 32469

ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LC_ALL          C.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV PLEX_VER        0.9.14.5.1595-5c6e524-debian

ADD https://github.com/krallin/tini/releases/download/v0.8.4/tini /bin/
ADD https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 /bin/gosu
ADD http://bit.ly/ihqmEu /uas.zip
ADD http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key /ninthgate.key
ADD entry /usr/local/sbin/
ADD start /usr/local/sbin/
RUN apt-key add /ninthgate.key && rm -f /ninthgate.key \
    && echo "deb http://shell.ninthgate.se/packages/debian plexpass main" > /etc/apt/sources.list.d/plexmediaserver.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        avahi-daemon \
        avahi-utils \
        ca-certificates \
        plexmediaserver=${PLEX_VER} \
        unzip \
    && bash -c 'chmod +x /bin/{tini,gosu} /usr/local/sbin/{entry,start}' \
    && mkdir -p "/plexmediaserver/Plex Media Server/Plug-ins" \
    && unzip /uas.zip -d "/plexmediaserver/Plex Media Server/Plug-ins" \
    && chown -R plex /plexmediaserver \
    && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD preroll /
RUN {\
        echo '#!/bin/sh'; \
        echo 'exit 0'; \
    } | tee /bin/{start,systemctl}

ENV PLEX_MEDIA_SERVER_HOME                    /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH                           ${PLEX_MEDIA_SERVER_HOME}
ENV PLEX_MEDIA_SERVER_USER                    plex
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /plexmediaserver
ENV PLEX_MEDIA_SERVER_TMPDIR                  /tmp
ENV TMPDIR                                    ${PLEX_MEDIA_SERVER_TMPDIR}
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE          4000
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS        6

WORKDIR /usr/lib/plexmediaserver
