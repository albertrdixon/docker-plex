# Plex Media Server - :whale: ized

[![](https://images.microbadger.com/badges/version/albertdixon/plex.svg)](https://microbadger.com/images/albertdixon/plex "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/albertdixon/plex.svg)](https://microbadger.com/images/albertdixon/plex "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/albertdixon/plex.svg)](https://microbadger.com/images/albertdixon/plex "Get your own commit badge on microbadger.com")

A (sort of) minimal Debian container running [Plex Media Server](http://plex.tv)

__NOTE:__ Requires [Plex Pass subscription](https://plex.tv/subscription/about)

Also included:

  * [Official Trakt Scrobbler](https://github.com/trakt/Plex-Trakt-Scrobbler)
  * [WebTools](https://github.com/dagalufh/WebTools.bundle/wiki)
  * [Sub-Zero](https://github.com/pannal/Sub-Zero.bundle)
  * Stupid little preroll clip I use :)

## Usage

Attach your media directory somewhere in the container - I usually do /data.

Also attach a local volume - or [data volume](https://docs.docker.com/engine/userguide/dockervolumes/#data-volumes) - at /plexmediaserver to save your configs and cache.

```
$ docker run -d -p 32400:32400 \
   -v /path/to/media:/data \
   -v /opt/plex:/plexmediaserver \
   albertdixon/plexmediaserver
```
