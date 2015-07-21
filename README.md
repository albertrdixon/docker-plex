# Docker - Plex Media Server

A (sort of) minimal Debian Jessie container running [Plex Media Server](http://plex.tv)

Uses a slightly modified version of MrWorf's [Plex update script](https://github.com/mrworf/plexupdate) to keep Plex up to date!

## Usage

Simply attach a local volume to /plexmediaserver in the container to save your configs and cache (or don't, I don't care).
If you have Plex Pass, then set your credentials with PLEX_USERNAME and PLEX_PASSWORD 

```
$ docker run -d -p 32400:32400 -v /path/to/plex:/plexmediaserver albertdixon/plexmediaserver plex
```

## Environment Variables

| Var Name | Default Value | Description |
|----------|---------------|-------------|
| `PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR` | /plexmediaserver | All the plex generated stuff: logs, cache, plugins, etc. |
| `PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS` | 6 | |
| `PLEX_MEDIA_SERVER_MAX_STACK_SIZE` | 4000 | |
| `PLEX_MEDIA_SERVER_TMPDIR` | /tmp | |
| `AUTOINSTALL` | yes | Don't change this, auto installs updates |
| `DOWNLOADDIR` | /plexupdate | Where update packages are downloaded to |
| `FORCE` | no | Force install updates |
| `PUBLIC` | no | Use public update channel. Auto set to 'yes' if `PLEX_USERNAME` or `PLEX_PASSWORD` not set |
| `RELEASE` | 64-bit | Use 64-bit packages |
| `URL_DOWNLOAD` | https://plex.tv/downloads?channel=plexpass | Plex Pass URL for package download |
| `URL_DOWNLOAD_PUBLIC` | https://plex.tv/downloads | Public URL for package downloads |
| `URL_LOGIN` | https://plex.tv/users/sign_in | Plex login URL |
| `UPDATE_TIME` | 1:00 | Daily time to try updates |
