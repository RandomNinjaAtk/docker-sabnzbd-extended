ARG ffmpeg_tag=snapshot-vaapi
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV SABSCRIPTS_PATH /usr/local/sabnzbd-scripts
ENV SMA_PATH /usr/local/sma
ENV UPDATE_EXT TRUE
ENV UPDATE_SMA FALSE
ENV VIDEO_LANG eng
ENV VIDEO_SMA FALSE
ENV AUDIO_VERIFY TRUE
ENV AUDIO_FORMAT FDK-AAC
ENV AUDIO_BITRATE 320
ENV AUDIO_REPLAYGAIN FALSE
ENV AUDIO_DSFA TRUE
ENV AUDIO_DSFAS 150M
ENV AUDIO_BEETSTAGGING TRUE
ENV AUDIO_REQUIREBEETSTAGGING false
# converter settings
ENV CONVERTER_THREADS="0"
ENV CONVERTER_OUTPUT_FORMAT="mp4"
ENV CONVERTER_OUTPUT_EXTENSION="mp4"
ENV CONVERTER_MINIMUM_SIZE="0"
ENV CONVERTER_SORT_STREAMS="True"
ENV CONVERTER_PROCESS_SAME_EXTENSIONS="False"
ENV CONVERTER_FORCE_CONVERT="False"
ENV CONVERTER_PREOPTS=""
ENV CONVERTER_POSTOPTS=""
# permissions
ENV PERMISSIONS_CHMOD="0666"
# metadata settings
ENV METADATA_RELOCATE_MOV="True"
ENV METADATA_TAG="False"
ENV METADATA_TAG_LANGUAGE="eng"
ENV METADATA_DOWNLOAD_ARTWORK="poster"
ENV METADATA_PRESERVE_SOURCE_DISPOSITION="True"
# video settings
ENV VIDEO_CODEC="h264, x264"
ENV VIDEO_MAX_BITRATE="0"
ENV VIDEO_CRF="-1"
ENV VIDEO_CRF_PROFILES=""
ENV VIDEO_MAX_WIDTH="0"
ENV VIDEO_PROFILE=""
ENV VIDEO_MAX_LEVEL="0.0"
ENV VIDEO_PIX_FMT=""
# audio settings
ENV AUDIO_CODEC="ac3"
ENV AUDIO_LANGUAGES=""
ENV AUDIO_DEFAULT_LANGUAGE=""
ENV AUDIO_FIRST_STREAM_OF_LANGUAGE="False"
ENV AUDIO_CHANNEL_BITRATE="128"
ENV AUDIO_MAX_BITRATE="0"
ENV AUDIO_MAX_CHANNELS="0"
ENV AUDIO_PREFER_MORE_CHANNELS="True"
ENV AUDIO_DEFAULT_MORE_CHANNELS="True"
ENV AUDIO_FILTER=""
ENV AUDIO_SAMPLE_RATES=""
ENV AUDIO_COPY_ORIGINAL="False"
ENV AUDIO_AAC_ADTSTOASC="False"
ENV AUDIO_IGNORE_TREHD="mp4, m4v"
# universal audio settings
ENV UAUDIO_CODEC="aac"
ENV UAUDIO_CHANNEL_BITRATE="128"
ENV UAUDIO_FIRST_STREAM_ONLY="False"
ENV UAUDIO_MOVE_AFTER="False"
ENV UAUDIO_FILTER=""
# subtitle settings
ENV SUBTITLE_CODEC="mov_text"
ENV SUBTITLE_CODEC_IMAGE_BASED="" 
ENV SUBTITLE_LANGUAGES=""
ENV SUBTITLE_DEFAULT_LANGUAGE=""
ENV SUBTITLE_FIRST_STREAM_OF_LANGUAGE="False"
ENV SUBTITLE_ENCODING=""
ENV SUBTITLE_BURN_SUBTITLES="False"
ENV SUBTITLE_BURN_DISPOSITIONS="forced"
ENV SUBTITLE_DOWNLOAD_SUBS="False"
ENV SUBTITLE_DOWNLOAD_HEARING_IMPAIRED_SUBS="False"
ENV SUBTITLE_DOWNLOAD_PROVIDERS=""
ENV SUBTITLE_EMBED_SUBS="True"
ENV SUBTITLE_EMBED_IMAGE_SUBS="False"
ENV SUBTITLE_EMBED_ONLY_INTERNAL_SUBS="False"
ENV SUBTITLE_FILENAME_DISPOSITIONS="forced"
ENV SUBTITLE_IGNORE_EMBEDDED_SUBS="False"
ENV SUBTITLE_ATTACHMENT_CODEC=""

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

RUN \
	echo "************ install dependencies ************" && \
	apt-get update -qq && \
	apt-get install -qq -y \
		mkvtoolnix \
		mp3val \
		flac \
		opus-tools \
		jq \
		git \
		wget \
		beets \
		python3 \
		python3-pip \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	echo "************ setup SMA ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SMA_PATH} && \
	echo ""************ download repo ************" && \
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	echo "************ create logging file ************" && \
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	echo "************ install pip dependencies ************" && \
	python3 -m pip install --user --upgrade pip && \
	pip3 install -r ${SMA_PATH}/setup/requirements.txt && \
	echo "************ setup sabnzbd-scripts ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SABSCRIPTS_PATH} && \
	echo "************ download repo ************" && \
	git clone https://github.com/RandomNinjaAtk/sabnzbd-scripts.git ${SABSCRIPTS_PATH} && \
	echo "************ setup cron ************" && \
	service cron start && \
	echo "* * * * *   root   bash /etc/cont-init.d/33-script-setup.bash" >> "/etc/crontab" && \
	echo "************ setup ffmpeg ************" && \
	chgrp users /usr/local/bin/ffmpeg && \
	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "************ install runtime ************" && \
	apt-get update && \
	apt-get install -y \
		i965-va-driver \
		libexpat1 \
		libgl1-mesa-dri \
		libglib2.0-0 \
		libgomp1 \
		libharfbuzz0b \
		libv4l-0 \
		libx11-6 \
		libxcb1 \
		libxext6 \
		libxml2 \
		libva-drm2 \
		libva2 && \
 	echo "************ clean up ************" && \
	rm -rf \
		/var/lib/apt/lists/* \
		/var/tmp/*
	
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config /storage
