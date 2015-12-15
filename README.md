# Docker - Plex Media Server

A (sort of) minimal Debian Jessie container running [Plex Media Server](http://plex.tv)

Uses a slightly modified version of MrWorf's [Plex update script](https://github.com/mrworf/plexupdate) to keep Plex up to date!

## Usage

Simply attach a local volume to /plexmediaserver in the container to save your configs and cache (or don't, I don't care).
If you have Plex Pass, then set your credentials with PLEX_USERNAME and PLEX_PASSWORD 

```
$ docker run -d -p 32400:32400 -v /path/to/plex:/plexmediaserver albertdixon/plexmediaserver plex
```
