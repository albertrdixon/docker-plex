# Plex Media Server - :whale: ized

A (sort of) minimal Debian container running [Plex Media Server](http://plex.tv)

__NOTE:__ Requires [Plex Pass subscription](https://plex.tv/subscription/about)

Also included:

  * [Official Trakt Scrobbler](https://github.com/trakt/Plex-Trakt-Scrobbler)
  * [WebTools](https://github.com/dagalufh/WebTools.bundle/wiki)
  * [Subliminal](https://github.com/bramwalet/Subliminal.bundle)
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
