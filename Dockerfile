FROM alpine:3.2
MAINTAINER Albert Dixon <albert.dixon@schange.com>

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update
RUN apk add \
      avahi \
      avahi-tools \
      bash \
      ca-certificates \
      dpkg \
      ffmpeg \
      git \
      libcec \
      supervisor \
      unzip

ADD https://github.com/albertrdixon/tmplnator/releases/download/v2.2.1/t2-linux.tgz /t2.tgz
RUN tar xvzf /t2.tgz -C /usr/local/bin && rm -f /t2.tgz

ADD https://github.com/albertrdixon/escarole/releases/download/v0.1.1/escarole-linux.tgz /es.tgz
RUN tar xvzf /es.tgz -C /usr/local \
    && ln -s /usr/local/bin/escarole-linux /usr/local/bin/escarole \
    && rm -f /es.tgz

RUN git clone https://github.com/mrworf/plexupdate.git /plexupdate

ADD bashrc /root/.profile
ADD configs /templates
ADD scripts/* /usr/local/bin/
ADD preroll /
RUN chown root:root /usr/local/bin/* \
    && chmod a+rx /usr/local/bin/* \
    && adduser -S -u 797 -s /usr/sbin/nologin plex \
    && mkdir -p /plexmediaserver \
    && chown -R plex /plexmediaserver

# Unsupported App Store
ADD http://bit.ly/ihqmEu /uas.zip

ENTRYPOINT ["docker-entry"]
CMD ["docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 1900 5353 32410 32412 32413 32414 32469

ENV OPEN_FILE_LIMIT     32768
ENV UPDATE_INTERVAL     24h

ENV PLEX_MEDIA_SERVER_HOME                    /usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_USER                    root
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /plexmediaserver
ENV PLEX_MEDIA_SERVER_TMPDIR                  /tmp
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE          4000
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS        6
