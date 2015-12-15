# Docker - Plex Media Server

A (sort of) minimal Debian Jessie container running [Plex Media Server](http://plex.tv)

## Usage

Simply attach a local volume to /plexmediaserver in the container to save your configs and cache (or don't, I don't care).

```
$ docker run -d -p 32400:32400 -v /path/to/plex:/plexmediaserver albertdixon/plexmediaserver plex
```
