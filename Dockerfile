FROM ubuntu:15.10
MAINTAINER Albert Dixon <albert.dixon@schange.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --no-install-recommends -y --force-yes \
    curl wget ca-certificates avahi-daemon \
    avahi-utils supervisor git unzip

RUN curl -#kL https://github.com/albertrdixon/tmplnator/releases/download/v2.2.1/t2-linux.tgz |\
    tar xvz -C /usr/local/bin

RUN curl -#kL https://github.com/albertrdixon/escarole/releases/download/v0.1.0/escarole-linux.tar.gz |\
    tar xvz -C /usr/local/bin

RUN git clone https://github.com/mrworf/plexupdate.git /plexupdate

RUN apt-get autoremove -y && apt-get autoclean -y &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD bashrc /root/.bashrc
ADD configs /templates
ADD scripts/* /usr/local/bin/
ADD preroll /preroll
RUN chown root:root /usr/local/bin/* \
    && chmod a+rx /usr/local/bin/* \
    && useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
    && mkdir -p /plexmediaserver \
    && chown -R plex /plexmediaserver

# Unsupported App Store
ADD http://bit.ly/ihqmEu /uas.zip

ENTRYPOINT ["docker-entry"]
CMD ["docker-start"]
VOLUME ["/plexmediaserver"]
EXPOSE 32400 1900 5353 32410 32412 32413 32414 32469

ENV OPEN_FILE_LIMIT     32768
ENV UPDATE_TIME         3:00
ENV UPDATE_INTERVAL     24h

ENV PLEX_MEDIA_SERVER_HOME                    /usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_USER                    root
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /plexmediaserver
ENV PLEX_MEDIA_SERVER_TMPDIR                  /tmp
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE          4000
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS        6
