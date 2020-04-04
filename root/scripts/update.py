#!/usr/bin/env python

import os
import sys
import logging
import configparser
import xml.etree.ElementTree as ET

autoProcess = os.path.join(os.environ.get("SMA_PATH", "/usr/local/sma"), "config/autoProcess.ini")

def main():
   
    safeConfigParser = configparser.ConfigParser()
    safeConfigParser.read(autoProcess)

    # Set Converter Settings
    safeConfigParser.set("Converter", "ffmpeg", "ffmpeg")
    safeConfigParser.set("Converter", "ffprobe", "ffprobe")
    if os.environ.get("CONVERTER_THREADS"):
        safeConfigParser.set("Converter", "threads", os.environ.get("CONVERTER_THREADS"))
    if os.environ.get("CONVERTER_HWACCELS"):
        safeConfigParser.set("Converter", "hwaccels", os.environ.get("CONVERTER_HWACCELS"))
    else:
        safeConfigParser.set("Converter", "hwaccels", " ")
    if os.environ.get("CONVERTER_HWACCEL_DECODERS"):
        safeConfigParser.set("Converter", "hwaccel-decoders", os.environ.get("CONVERTER_HWACCEL_DECODERS"))
    else:
        safeConfigParser.set("Converter", "hwaccel-decoders", " ")
    if os.environ.get("CONVERTER_OUTPUT_FORMAT"):    
        safeConfigParser.set("Converter", "output-format", os.environ.get("CONVERTER_OUTPUT_FORMAT"))
    if os.environ.get("CONVERTER_OUTPUT_EXTENSION"):    
        safeConfigParser.set("Converter", "output-extension", os.environ.get("CONVERTER_OUTPUT_EXTENSION"))
    if os.environ.get("CONVERTER_MINIMUM_SIZE"):    
        safeConfigParser.set("Converter", "minimum-size", os.environ.get("CONVERTER_MINIMUM_SIZE"))
    if os.environ.get("CONVERTER_SORT_STREAMS"):    
        safeConfigParser.set("Converter", "sort-streams", os.environ.get("CONVERTER_SORT_STREAMS"))
    if os.environ.get("CONVERTER_PROCESS_SAME_EXTENSIONS"):    
        safeConfigParser.set("Converter", "process-same-extensions", os.environ.get("CONVERTER_PROCESS_SAME_EXTENSIONS"))
    if os.environ.get("CONVERTER_FORCE_CONVERT"):    
        safeConfigParser.set("Converter", "force-convert", os.environ.get("CONVERTER_FORCE_CONVERT"))
    if os.environ.get("CONVERTER_PREOPTS"):
        safeConfigParser.set("Converter", "preopts", os.environ.get("CONVERTER_PREOPTS"))
    else:
        safeConfigParser.set("Converter", "preopts", " ")
    if os.environ.get("CONVERTER_POSTOPTS"):    
        safeConfigParser.set("Converter", "postopts", os.environ.get("CONVERTER_POSTOPTS"))
    else:
        safeConfigParser.set("Converter", "postopts", " ")
    
    # SET Permissions
    if os.environ.get("PERMISSIONS_CHMOD"):
        safeConfigParser.set("Permissions", "chmod", os.environ.get("PERMISSIONS_CHMOD"))
    
    # Set Metadata Settings
    if os.environ.get("METADATA_RELOCATE_MOV"):
        safeConfigParser.set("Metadata", "relocate-moov", os.environ.get("METADATA_RELOCATE_MOV"))
    if os.environ.get("METADATA_TAG"):
        safeConfigParser.set("Metadata", "tag", os.environ.get("METADATA_TAG"))
    if os.environ.get("METADATA_TAG_LANGUAGE"):
        safeConfigParser.set("Metadata", "tag-language", os.environ.get("METADATA_TAG_LANGUAGE"))
    if os.environ.get("METADATA_DOWNLOAD_ARTWORK"):
        safeConfigParser.set("Metadata", "download-artwork", os.environ.get("METADATA_DOWNLOAD_ARTWORK"))
    if os.environ.get("METADATA_SANITIZE_DISPOSITION"):
        safeConfigParser.set("Metadata", "sanitize-disposition", os.environ.get("METADATA_SANITIZE_DISPOSITION"))

    # Set Video Settings
    if os.environ.get("VIDEO_CODEC"):
        safeConfigParser.set("Video", "codec", os.environ.get("VIDEO_CODEC"))
    if os.environ.get("VIDEO_MAX_BITRATE"):
        safeConfigParser.set("Video", "max-bitrate", os.environ.get("VIDEO_MAX_BITRATE"))
    if os.environ.get("VIDEO_CRF"):
        safeConfigParser.set("Video", "crf", os.environ.get("VIDEO_CRF"))
    if os.environ.get("VIDEO_CRF_PROFILES"):
        safeConfigParser.set("Video", "crf-profiles", os.environ.get("VIDEO_CRF_PROFILES"))
    else:
        safeConfigParser.set("Video", "crf-profiles", " ")
    if os.environ.get("VIDEO_MAX_WIDTH"):
        safeConfigParser.set("Video", "max-width", os.environ.get("VIDEO_MAX_WIDTH"))
    if os.environ.get("VIDEO_PROFILE"):
        safeConfigParser.set("Video", "profile", os.environ.get("VIDEO_PROFILE"))
    else:
        safeConfigParser.set("Video", "profile", " ")
    if os.environ.get("VIDEO_MAX_LEVEL"):
        safeConfigParser.set("Video", "max-level", os.environ.get("VIDEO_MAX_LEVEL"))
    if os.environ.get("VIDEO_PIX_FMT"):
        safeConfigParser.set("Video", "pix-fmt", os.environ.get("VIDEO_PIX_FMT"))
    else:
        safeConfigParser.set("Video", "pix-fmt", " ")
    
    # Set Audio Settings
    if os.environ.get("AUDIO_CODEC"):
        safeConfigParser.set("Audio", "codec", os.environ.get("AUDIO_CODEC"))
    if os.environ.get("AUDIO_LANGUAGES"):
        safeConfigParser.set("Audio", "languages", os.environ.get("AUDIO_LANGUAGES"))
    else:
        safeConfigParser.set("Audio", "languages", " ")
    if os.environ.get("AUDIO_DEFAULT_LANGUAGE"):
        safeConfigParser.set("Audio", "default-language", os.environ.get("AUDIO_DEFAULT_LANGUAGE"))
    else:
        safeConfigParser.set("Audio", "default-language", " ")
    if os.environ.get("AUDIO_FIRST_STREAM_OF_LANGUAGE"):
        safeConfigParser.set("Audio", "first-stream-of-language", os.environ.get("AUDIO_FIRST_STREAM_OF_LANGUAGE"))
    if os.environ.get("AUDIO_CHANNEL_BITRATE"):
        safeConfigParser.set("Audio", "channel-bitrate", os.environ.get("AUDIO_CHANNEL_BITRATE"))
    if os.environ.get("AUDIO_MAX_BITRATE"):
        safeConfigParser.set("Audio", "max-bitrate", os.environ.get("AUDIO_MAX_BITRATE"))
    if os.environ.get("AUDIO_MAX_CHANNELS"):
        safeConfigParser.set("Audio", "max-channels", os.environ.get("AUDIO_MAX_CHANNELS"))
    if os.environ.get("AUDIO_PREFER_MORE_CHANNELS"):
        safeConfigParser.set("Audio", "prefer-more-channels", os.environ.get("AUDIO_PREFER_MORE_CHANNELS"))
    if os.environ.get("AUDIO_DEFAULT_MORE_CHANNELS"):
        safeConfigParser.set("Audio", "default-more-channels", os.environ.get("AUDIO_DEFAULT_MORE_CHANNELS"))
    if os.environ.get("AUDIO_FILTER"):
        safeConfigParser.set("Audio", "filter", os.environ.get("AUDIO_FILTER"))
    else:
        safeConfigParser.set("Audio", "filter", " ")
    if os.environ.get("AUDIO_SAMPLE_RATES"):
        safeConfigParser.set("Audio", "sample-rates", os.environ.get("AUDIO_SAMPLE_RATES"))
    else:
        safeConfigParser.set("Audio", "sample-rates", " ")
    if os.environ.get("AUDIO_COPY_ORIGINAL"):
        safeConfigParser.set("Audio", "copy-original", os.environ.get("AUDIO_COPY_ORIGINAL"))
    if os.environ.get("AUDIO_AAC_ADTSTOASC"):
        safeConfigParser.set("Audio", "aac-adtstoasc", os.environ.get("AUDIO_AAC_ADTSTOASC"))
    if os.environ.get("AUDIO_IGNORE_TREHD"):
        safeConfigParser.set("Audio", "ignore-truehd", os.environ.get("AUDIO_IGNORE_TREHD"))
        
    # Set Universal Audio Settings
    if os.environ.get("UAUDIO_CODEC"):
        safeConfigParser.set("Universal Audio", "codec", os.environ.get("UAUDIO_CODEC"))
    else:
        safeConfigParser.set("Universal Audio", "codec", " ")
    if os.environ.get("UAUDIO_CHANNEL_BITRATE"):
        safeConfigParser.set("Universal Audio", "channel-bitrate", os.environ.get("UAUDIO_CHANNEL_BITRATE"))
    if os.environ.get("UAUDIO_FIRST_STREAM_ONLY"):
        safeConfigParser.set("Universal Audio", "first-stream-only", os.environ.get("UAUDIO_FIRST_STREAM_ONLY"))
    if os.environ.get("UAUDIO_MOVE_AFTER"):
        safeConfigParser.set("Universal Audio", "move-after", os.environ.get("UAUDIO_MOVE_AFTER"))
    if os.environ.get("UAUDIO_FILTER"):
        safeConfigParser.set("Universal Audio", "filter", os.environ.get("UAUDIO_FILTER"))
    else:
        safeConfigParser.set("Universal Audio", "filter", " ")
                         
    # Set Subtitle Settings
    if os.environ.get("SUBTITLE_CODEC"):
        safeConfigParser.set("Subtitle", "codec", os.environ.get("SUBTITLE_CODEC"))
    if os.environ.get("SUBTITLE_CODEC_IMAGE_BASED"):
        safeConfigParser.set("Subtitle", "codec-image-based", os.environ.get("SUBTITLE_CODEC_IMAGE_BASED"))
    else:
        safeConfigParser.set("Subtitle", "codec-image-based", " ")
    if os.environ.get("SUBTITLE_LANGUAGES"):
        safeConfigParser.set("Subtitle", "languages", os.environ.get("SUBTITLE_LANGUAGES"))
    else:
        safeConfigParser.set("Subtitle", "languages", " ")
    if os.environ.get("SUBTITLE_DEFAULT_LANGUAGE"):
        safeConfigParser.set("Subtitle", "default-language", os.environ.get("SUBTITLE_DEFAULT_LANGUAGE"))
    else:
        safeConfigParser.set("Subtitle", "default-language", " ")
    if os.environ.get("SUBTITLE_FIRST_STREAM_OF_LANGUAGE"):
        safeConfigParser.set("Subtitle", "first-stream-of-language", os.environ.get("SUBTITLE_FIRST_STREAM_OF_LANGUAGE"))
    if os.environ.get("SUBTITLE_ENCODING"):
        safeConfigParser.set("Subtitle", "encoding", os.environ.get("SUBTITLE_ENCODING"))
    else:
        safeConfigParser.set("Subtitle", "encoding", " ")
    if os.environ.get("SUBTITLE_BURN_SUBTITLES"):
        safeConfigParser.set("Subtitle", "burn-subtitles", os.environ.get("SUBTITLE_BURN_SUBTITLES"))
    if os.environ.get("SUBTITLE_BURN_DISPOSITIONS"):
        safeConfigParser.set("Subtitle", "burn-dispositions", os.environ.get("SUBTITLE_BURN_DISPOSITIONS"))
    else:
        safeConfigParser.set("Subtitle", "burn-dispositions", " ")
    if os.environ.get("SUBTITLE_DOWNLOAD_SUBS"):
        safeConfigParser.set("Subtitle", "download-subs", os.environ.get("SUBTITLE_DOWNLOAD_SUBS"))
    if os.environ.get("SUBTITLE_DOWNLOAD_HEARING_IMPAIRED_SUBS"):
        safeConfigParser.set("Subtitle", "download-hearing-impaired-subs", os.environ.get("SUBTITLE_DOWNLOAD_HEARING_IMPAIRED_SUBS"))
    if os.environ.get("SUBTITLE_DOWNLOAD_PROVIDERS"):
        safeConfigParser.set("Subtitle", "download-providers", os.environ.get("SUBTITLE_DOWNLOAD_PROVIDERS"))
    else:
        safeConfigParser.set("Subtitle", "download-providers", " ")
    if os.environ.get("SUBTITLE_EMBED_SUBS"):
        safeConfigParser.set("Subtitle", "embed-subs", os.environ.get("SUBTITLE_EMBED_SUBS"))
    if os.environ.get("SUBTITLE_EMBED_IMAGE_SUBS"):
        safeConfigParser.set("Subtitle", "embed-image-subs", os.environ.get("SUBTITLE_EMBED_IMAGE_SUBS"))
    if os.environ.get("SUBTITLE_EMBED_ONLY_INTERNAL_SUBS"):
        safeConfigParser.set("Subtitle", "embed-only-internal-subs", os.environ.get("SUBTITLE_EMBED_ONLY_INTERNAL_SUBS"))
    if os.environ.get("SUBTITLE_FILENAME_DISPOSITIONS"):
        safeConfigParser.set("Subtitle", "filename-dispositions", os.environ.get("SUBTITLE_FILENAME_DISPOSITIONS"))
    if os.environ.get("SUBTITLE_IGNORE_EMBEDDED_SUBS"):
        safeConfigParser.set("Subtitle", "ignore-embedded-subs", os.environ.get("SUBTITLE_IGNORE_EMBEDDED_SUBS"))
    if os.environ.get("SUBTITLE_ATTACHMENT_CODEC"):
        safeConfigParser.set("Subtitle", "attachment-codec", os.environ.get("SUBTITLE_ATTACHMENT_CODEC"))
    else:
        safeConfigParser.set("Subtitle", "attachment-codec", " ")
                         
    # Set Plex Settings
    if os.environ.get("PLEX_HOST"):
        safeConfigParser.set("Plex", "host", os.environ.get("PLEX_HOST"))
    if os.environ.get("PLEX_PORT"):
        safeConfigParser.set("Plex", "port", os.environ.get("PLEX_PORT"))
    if os.environ.get("PLEX_REFRESH"):
        safeConfigParser.set("Plex", "refresh", os.environ.get("PLEX_REFRESH"))
    if os.environ.get("PLEX_TOKEN"):
        safeConfigParser.set("Plex", "token", os.environ.get("PLEX_TOKEN"))
                         
    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()


if __name__ == '__main__':
    main()
