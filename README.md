# [RandomNinjaAtk/sabnzbd-extended](https://github.com/RandomNinjaAtk/docker-sabnzbd-extended)
[![Docker Build](https://img.shields.io/docker/cloud/automated/randomninjaatk/sabnzbd-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sabnzbd-extended)
[![Docker Pulls](https://img.shields.io/docker/pulls/randomninjaatk/sabnzbd-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sabnzbd-extended)
[![Docker Stars](https://img.shields.io/docker/stars/randomninjaatk/sabnzbd-extended?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sabnzbd-extended)
[![Docker Hub](https://img.shields.io/badge/Open%20On-DockerHub-blue?style=flat-square)](https://hub.docker.com/r/randomninjaatk/sabnzbd-extended)
[![Discord](https://img.shields.io/discord/747100476775858276.svg?style=flat-square&label=Discord&logo=discord)](https://discord.gg/JumQXDc "realtime support / chat with the community." )

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
| `-e AUDIO_FORMAT=FLAC` | FLAC or OPUS or MP3 or AAC or ALAC - converts lossless FLAC files to set format |
| `-e AUDIO_BITRATE=320` | Set to desired bitrate when converting to OPUS/MP3/AAC format types |
| `-e AUDIO_VERIFY=TRUE` | TRUE = ENABLED, Verifies FLAC/MP3 files for errors (fixes MP3's, deletes bad FLAC files) |
| `-e AUDIO_DSFA=TRUE` | TRUE = ENABLED :: Detects single file albums and mark download as failed if detected |
| `-e AUDIO_REPLAYGAIN=FALSE` | TRUE = ENABLED, adds replaygain tags for compatible players (FLAC ONLY) |
| `-e VIDEO_LANG=eng` | Default: eng :: Set to required language (ISO 639-2 language code), if not found, will mark as failed |
| `-e VIDEO_SMA=FALSE` | TRUE = Enabled :: Uses SMA to process incoming video files, update your configuration at: `/config/scripts/configs/*-sma.ini` |
| `-e VIDEO_SMA_TAGGING=TRUE` | TRUE = Enabled :: Uses SMA to Tag MP4 files (Enabled SMA process: manual.py -a; Disabled SMA Process: manual.py -nt) |

## Application Setup

Access the webui at `<your-ip>:8080`, for more information check out [SABnzbd](https://sabnzbd.org/).

# Important Docker Information
### Important Paths:
<strong>/config</strong> :: Location of SABnzbd aplication files<br/>
<strong>/config/scripts</strong> :: Location of SABnzbd post process script files (automatically mapped in SABnzbd)<br/>
<strong>/config/scripts/logs</strong> :: Location of script log files<br/>
<strong>/config/scritps/configs</strong> :: Location of config files<br/>

### Important SABNzbd Configuration:
<strong>Folders Configuration:</strong><br/>
* <strong>Scripts Folder</strong> :: Set to: <strong>/config/scripts</strong><br/>

<strong>Switches: Post processing </strong><br/>
* <strong>Pause Downloading During Post-Processing</strong> :: Highly recommended that you enable this setting to not overtask your system<br/>

<strong>Categories Configuration:</strong><br/>
* <strong>lidarr</strong> :: Add category and post processing script: <strong>audio-pp.bash</strong><br/>
* <strong>radarr</strong> :: Add category and post processing script: <strong>video-pp.bash</strong><br/>
* <strong>sonarr</strong> :: Add category and post processing script: <strong>video-pp.bash</strong><br/>

### Scripts/Files included:
<strong>audio-pp.bash</strong> :: Automatically clean up downloaded audio files and convert to standardized format if desired<br/>
<strong>video-pp.bash</strong> :: Verify incoming video files for required audio/subtitle languages and process with SMA if enabled<br/>
### Sickbeard MP4 Automater (SMA):
<strong>Config Files Location:</strong> /config/scritps/configs<br/>
* <strong>radarr-sma.ini</strong> :: config file for SMA (Applies to "radarr" category)
* <strong>sonarr-sma.ini</strong> :: config file for SMA (Applies to "sonarr" category)

<strong>Log Files Location:</strong> /config/scritps/logs<br/>
* <strong>sma.log</strong> :: Log file for SMA

For more detailed configuration info, visit: https://github.com/mdhiggins/sickbeard_mp4_automator<br/><br/>
### Hardware Acceleration:
1. Set the video codec in SMA config file to: `h264vaapi` (h254) or `h265vaapi` (h265)
