# Docker - Plex Media Server

A (sort of) minimal Debian container running [Plex Media Server](http://plex.tv)

Also included:

  * Unsupported App Store
  * [Subliminal plugin](https://github.com/bramwalet/Subliminal.bundle)
  * Stupid little preroll clip I use :)

## Usage

Attach your media directory somewhere in the container - I usually do /data. 

Also attach a local volume - or [data volume](https://docs.docker.com/engine/userguide/dockervolumes/#data-volumes) - at /plexmediaserver to save your configs and cache.

```
$ docker run -d -p 32400:32400 -v /path/to/media:/data -v /opt/plex:/plexmediaserver albertdixon/plexmediaserver
```
