# [RandomNinjaAtk/sabnzbd-extended](https://github.com/RandomNinjaAtk/docker-sabnzbd-extended)

This continer includes [SABnzbd](https://sabnzbd.org/) along with a set of post-processing scripts to enhance your SABnzbd usage


[![sabnzbd](https://raw.githubusercontent.com/RandomNinjaAtk/unraid-templates/master/randomninjaatk/img/sabnzbd-icon.png)](https://sabnzbd.org/)

This containers base image is provided by: [linuxserver/sabnzbd](https://github.com/linuxserver/docker-sabnzbd)


## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | SAbnzbd + Extended Scripts + SMA |

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| --- | --- |
| `-p 8080` | The port for the Sonarr webinterface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-v /config` | Sabnzbd application files |
| `-v /storage` | Location of Downloads location |
| `-e UPDATE_EXT=TRUE` | TRUE = enabled :: Update scripts from git on container start |
| `-e UPDATE_SMA=FALSE` | TRUE = enabled :: Update scripts from git on container start |
| `-e AUDIO_FORMAT=FLAC` | FLAC or OPUS or MP3 or FDK-AAC or AAC or ALAC - converts lossless FLAC files to set format |
| `-e AUDIO_BITRATE=320` | Set to desired bitrate when converting to OPUS/MP3/FDK-AAC/AAC format types |
| `-e AUDIO_VERIFY=TRUE` | TRUE = ENABLED, Verifies FLAC/MP3 files for errors (fixes MP3's, deletes bad FLAC files) |
| `-e AUDIO_DSFA=TRUE` | TRUE = ENABLED :: Detects single file albums and mark download as failed if detected |
| `-e AUDIO_REPLAYGAIN=FALSE` | TRUE = ENABLED, adds replaygain tags for compatible players (FLAC ONLY) |
| `-e VIDEO_LANG=eng` | Default: eng :: Set to required language (ISO 639-2 language code), if not found, will mark as failed |
| `-e VIDEO_SMA=FALSE` | TRUE = Enabled :: Uses SMA to process incoming video files, update your configuraiton at: /config/scripts/configs/(radarr/sonarr)-pp.ini |

## Application Setup

Access the webui at `<your-ip>:8080`, for more information check out [SABnzbd](https://sabnzbd.org/).
