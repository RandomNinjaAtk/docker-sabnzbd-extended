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
| `-e AUDIO_BEETSTAGGING=TRUE` | TRUE = ENABLED, use beets to tag files |
| `-e VIDEO_LANG=eng` | Default: eng :: Set to required language (ISO 639-2 language code), if not found, will mark as failed |
| `-e VIDEO_SMA=FALSE` | TRUE = Enabled :: Uses SMA to process incoming video files, update your configuraiton at: /config/scripts/configs/(radarr/sonarr)-pp.ini |
| `-e CONVERTER_THREADS="0"` | FFMpeg threads, corresponds to threads parameter |
| `-e CONVERTER_OUTPUT_FORMAT="mkv"` | Wrapped format corresponding to -f in FFmpeg |
| `-e CONVERTER_OUTPUT_EXTENSION="mkv"` | File extension for created media |
| `-e CONVERTER_SORT_STREAMS="True"` | Sort streams by language preferences and channels |
| `-e CONVERTER_PROCESS_SAME_EXTENSIONS="False"` | Run files with the same input and output extensions through the conversion process. Tagging is not effected. If after options are generated all streams are copy conversion will be skipped. Use with caution alongside universal audio and audio copy-original as tracks will keep replicating |
| `-e CONVERTER_FORCE_CONVERT="False"` | Force conversion regardless of streams being in appropriate format |
| `-e CONVERTER_PREOPTS=""` | Additional comma separated FFmpeg options placed before main commands |
| `-e CONVERTER_POSTOPTS=""` | Additional comma separated FFmpeg options placed after main commands |
| `-e PERMISSIONS_CHMOD="0666"` | Base 8 chmod value |
| `-e METADATA_RELOCATE_MOV="FALSE"` | Relocate MOOV atom using QTFastStart. MP4 only |
| `-e METADATA_TAG="False"` | Tag files with metadata from TMDB. MP4 only |
| `-e METADATA_TAG_LANGUAGE="eng"` | Tag language |
| `-e METADATA_DOWNLOAD_ARTWORK="thumb"` | Download artwork and embed in media. poster, thumb, True, False are valid options |
| `-e METADATA_PRESERVE_SOURCE_DISPOSITION="False"` | Maintain disposition elements from source file, set False to have the script set defaults based on sorting and preferences |
| `-e VIDEO_CODEC="h264, x264"` | Approved video codecs. Codecs not on this list are converted to the first codec on the list |
| `-e VIDEO_BITRATE="0"` | Maximum bitrate for video in Kb. Values above this range will be down sampled. 0 for no limit |
| `-e VIDEO_CRF="-1"` | CRF value, -1 to disable |
| `-e VIDEO_CRF_PROFILES=""` | See script website: https://github.com/mdhiggins/sickbeard_mp4_automator/wiki/AutoProcess-Settings |
| `-e VIDEO_MAX_WIDTH="0"` | Maximum video width, videos larger will be down sized |
| `-e VIDEO_PROFILE=""` | Video profile |
| `-e VIDEO_MAX_LEVEL="4.1"` | Maximum video level, videos above will be down sampled. Format example is 4.1 |
| `-e VIDEO_PIX_FMT=""` | Supported pix-fmt list. Formats not on this list are be converted to the first format on the list |
| `-e AUDIO_CODEC="libfdk_aac, aac, mp3, opus"` | Approved audio codecs. Codecs not on this list are converted to the first codec on the list |
| `-e AUDIO_LANGUAGES="eng"` | Approved audio stream languages. Languages not on this list will not be used. Leave blank to approve all languages |
| `-e AUDIO_DEFAULT_LANGUAGE="eng"` | If audio stream language is undefined, assumed this language |
| `-e AUDIO_FIRST_STREAM_OF_LANGUAGE="False"` | Only include the first occurrence of an audio stream of language |
| `-e AUDIO_CHANNEL_BITRATE="64"` | Bitrate of audio stream per channel. Multiple by number of channels to get stream bitrate. Use 0 to attempt to guess based on source bitrate |
| `-e AUDIO_MAX_BITRATE="0"` | Maximum audio stream bitrate regardless of channels. 0 for no limit |
| `-e AUDIO_MAX_CHANNELS="0"` | Maximum number of audio channels per stream. Streams with more channels will be down sampled |
| `-e AUDIO_PREFER_MORE_CHANNELS="True"` | When sorting source audio streams, prefer higher channel counts |
| `-e AUDIO_DEFAULT_MORE_CHANNELS="True"` | When setting default audio stream, prefer higher channel counts |
| `-e AUDIO_FILTER=""` | FFmpeg audio filter. Setting this will not allow copying audio streams |
| `-e AUDIO_SAMPLE_RATES=""` | Approved audio sample rates, rates not on the approved list will be converted to the first rate on the list |
| `-e AUDIO_COPY_ORIGINAL="True"` | Always include a copy of the original audio stream |
| `-e AUDIO_AAC_ADTSTOASC="False"` |  |
| `-e AUDIO_IGNORE_TREHD="mp4, m4v"` | Ignore trueHD audio streams for specific extensions (Not supported in MP4 containers). Leave blank to disable |
| `-e UAUDIO_CODEC=""libfdk_aac, aac, mp3"` | Approved audio codecs. Codecs not on this list are converted to the first codec on the list |
| `-e UAUDIO_CHANNEL_BITRATE="80"` |  Bitrate of universal audio stream per channel. Multiple by number of channels to get stream bitrate. Use 0 to attempt to guess based on source bitrate |
| `-e UAUDIO_FIRST_STREAM_ONLY="True"` | Only create a universal audio stream for the first audio stream encountered |
| `-e UAUDIO_MOVE_AFTER="True"` | Move universal audio stream after the source stream |
| `-e UAUDIO_FILTER=""` | FFmpeg audio filter. Setting this will not allow copying audio streams |
| `-e SUBTITLE_CODEC="srt"` | Approved subtitle codecs. Codecs not on this list are converted to the first codec on the list |
| `-e SUBTITLE_CODEC_IMAGE_BASED=""` | Approved image-based subtitle codecs. Codecs not on this list are converted to the first codec on the list |
| `-e SUBTITLE_LANGUAGES="eng"` | Approved subtitle stream languages. Languages not on this list will not be used. Leave blank to approve all languages |
| `-e SUBTITLE_DEFAULT_LANGUAGE="eng"` | If subtitle stream language is undefined, assumed this language |
| `-e SUBTITLE_FIRST_STREAM_OF_LANGUAGE="False"` | Only include the first occurrence of a subtitle stream of language |
| `-e SUBTITLE_ENCODING=""` | Subtitle encoding format |
| `-e SUBTITLE_BURN_SUBTITLES="False"` | Burns subtitles onto video stream. Valid parameters are true / any, false, default, forced, default, forced. If a valid subtitle for burning is found this will force the video stream to be encoded (cannot copy). Internal subtitles are prioritized over external subtitles. This feature does not support image based subtitle formats |
| `-e SUBTITLE_DOWNLOAD_SUBS="False"` | Attempt to download subtitles of your specified languages automatically using subliminal |
| `-e SUBTITLE_DOWNLOAD_HEARING_IMPAIRED_SUBS="False"` | Download hearing impaired subtitles using subliminal |
| `-e SUBTITLE_DOWNLOAD_PROVIDERS=""` | Subliminal providers, leave blank to use default providers |
| `-e SUBTITLE_EMBED_SUBS="True"` | Embeds text based subtitles in the output video. External subtitles in the same directory will embedded. If false subtitles will be extracted |
| `-e SUBTITLE_EMBED_IMAGE_SUBS="False"` | Embed image based subtitles in the output video. Ensure you are using a container that supports image based subtitles |
| `-e SUBTITLE_EMBED_ONLY_INTERNAL_SUBS="False"` | Limit embedding subtitles to only subs embedded in the source file |
| `-e SUBTITLE_IGNORE_EMBEDDED_SUBS="True"` | Ignore sub streams included in source file, external sources will still be processed |
| `-e SUBTITLE_ATTACHMENT_CODEC=""` | Approved codecs for attachments. Useful for fonts included with source file |

## Application Setup

Access the webui at `<your-ip>:8080`, for more information check out [SABnzbd](https://sabnzbd.org/).

# Important Docker Information
### Important Paths:
<strong>/storage</strong> :: Root location for downloads, see additonal paths below<br/>
<strong>/storage/downloads/sabnzbd/incomplete</strong> :: Automatically created on setup<br/>
<strong>/storage/downloads/sabnzbd/complete</strong> :: Automatically created on setup<br/>
<strong>/config</strong> :: Location of SABnzbd aplication files<br/>
<strong>/config/scripts</strong> :: Location of SABnzbd post process script files (automatically mapped in SABnzbd)<br/>
<strong>/config/scripts/logs</strong> :: Location of SMA log files<br/>
### Important SABNzbd Categories:
<strong>lidarr</strong> :: Automatically configured to post process using <strong>audio-pp.bash</strong><br/>
<strong>radarr</strong> :: Automatically configured to post process using <strong>video-pp.bash</strong><br/>
<strong>sonarr</strong> :: Automatically configured to post process using <strong>video-pp.bash</strong><br/>
### Scripts/Files included:
<strong>audio-pp.bash</strong> :: Automatically clean up downloaded audio files and convert to standardized format if desired<br/>
<strong>video-pp.bash</strong> :: Verify incoming video files for required audio/subtitle languages and process with SMA if enabled<br/>
<strong>beets-config.yaml</strong> :: Beet config file for matching<br/><br/>
Scripts are hosted here: https://github.com/RandomNinjaAtk/sabnzbd-scripts
### Sickbeard MP4 Automater (SMA):
Configuration handled by ENV variables, see parameters<br/>
<strong>Log Files Location:</strong> /config/scritps/logs<br/>
<strong>sma.log</strong> :: Log file for SMA<br/>
For more detailed configuration info, visit: https://github.com/mdhiggins/sickbeard_mp4_automator<br/><br/>
### Hardware Acceleration:
1. After container start, locate <strong>radarr-pp.ini</strong> or <strong>sonarr-pp.ini</strong>
1. Edit the `[Video]` options as specified below:
	* vaapi
		* Set video codec to: `h264vaapi` or `h265vaapi`
