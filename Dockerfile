FROM debian:8
MAINTAINER Albert Dixon <albert@dixon.rocks>

ENTRYPOINT ["/bin/tini", "-g", "--"]
CMD ["/start-pms"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 33400 1900 5353 32410 32412 32413 32414 32469

ENV GOSU_VER=1.10 \
    TINI_VER=v0.14.0 \
    SIGIL_VERSION=0.4.0 \

    PLEX_VER=plexupdate \
    FD_LIMIT=32768 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/plexmediaserver \
    PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6 \
    PLEX_MEDIA_SERVER_MAX_STACK_SIZE=4000 \
    PLEX_MEDIA_SERVER_TMPDIR=/tmp \
    PLEX_MEDIA_SERVER_USE_SYSLOG=true \
    PLEX_MEDIA_SERVER_USER=plex \
    PLEX_UID=7000 \
    PLEX_GID=7000 \
    USE_TRAKT=yes \
    USE_UAS=yes \
    USE_SUBZERO=yes

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
          ca-certificates \
          curl \
          git \
          locales \
          openssl \
          rsync \
          sudo \
          wget \
    && sed -i 's|# en_US.UTF-8|en_US.UTF-8|' /etc/locale.gen \
    && locale-gen \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && useradd --create-home --user-group \
      --home-dir "${PLEX_MEDIA_SERVER_HOME}" \
      --shell /bin/bash \
      --uid "${PLEX_UID}" plex \
    && groupmod --gid "${PLEX_GID}" plex \
    && curl -sL "https://github.com/gliderlabs/sigil/releases/download/v${SIGIL_VERSION}/sigil_${SIGIL_VERSION}_Linux_x86_64.tgz" | tar xvz -C /bin \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -#L -o /bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-$dpkgArch" \
    && curl -#L -o /bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VER}/gosu-$dpkgArch.asc" \
    && curl -#L -o /bin/tini "https://github.com/krallin/tini/releases/download/${TINI_VER}/tini" \
    && curl -#L -o /bin/tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VER}/tini.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --batch --verify /bin/gosu.asc /bin/gosu \
    && gpg --batch --verify /bin/tini.asc /bin/tini \
    && chmod +x /bin/tini /bin/gosu /bin/sigil \
    && mkdir -pv /plugins /opt \
    && git clone --depth=1 --single-branch --branch=master git://github.com/pannal/Sub-Zero.bundle /plugins/Sub-Zero.bundle \
    && git clone --depth=1 --single-branch --branch=master git://github.com/trakt/Plex-Trakt-Scrobbler /plugins/Plex-Trakt-Scrobbler \
    && git clone --depth=1 --single-branch --branch=master git://github.com/dagalufh/WebTools.bundle /plugins/WebTools.bundle \
    && git clone --depth=1 --single-branch --branch=master git://github.com/mrworf/plexupdate.git /opt/plexupdate \
    && chmod 755 /opt/plexupdate/plexupdate.sh \
    && echo exit 0 >/bin/systemd \
    && echo exit 0 >/usr/bin/systemd \
    && chown -vR plex "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" \
    && chgrp -vR plex "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" \
    && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
          /bin/*.asc "$GNUPGHOME"

COPY ["start-pms", "install-pms", "preroll", "config", "/"]
ENV CHANNEL=Public
WORKDIR /usr/lib/plexmediaserver

ARG VERSION="${PLEX_VER}"
LABEL org.label-schema.name="plex" \
      org.label-schema.description="Plex Media Server" \
      org.label-schema.vcs-url="https://github.com/albertrdixon/docker-plex" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
