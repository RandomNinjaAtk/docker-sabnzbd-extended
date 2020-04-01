ARG ffmpeg_tag=snapshot-vaapi
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV SABSCRIPTS_PATH /usr/local/sabnzbd-scripts
ENV SMA_PATH /usr/local/sma
ENV UPDATE_EXT FALSE
ENV UPDATE_SMA FALSE
ENV VIDEO_LANG eng
ENV VIDEO_SMA FALSE
ENV AUDIO_VERIFY TRUE
ENV AUDIO_FORMAT FLAC
ENV AUDIO_BITRATE 320
ENV AUDIO_REPLAYGAIN FALSE
ENV AUDIO_DSFA TRUE
ENV AUDIO_DSFAS 150M
ENV AUDIO_BEETSTAGGING TRUE
ENV AUDIO_REQUIREBEETSTAGGING false
ENV CONVERTER_HWACCELS=" "
ENV CONVERTER_HWACCEL_DECODERS=" "

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
		libchromaprint-tools \
		ffmpeg \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	echo "************ install Beets dependencies ************" && \
	pip3 install --no-cache-dir -U \
		requests \
		Pillow \
		pylast \
		pyacoustid && \
	echo "************ setup SMA ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SMA_PATH} && \
	echo "************ download repo ************" && \
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
	echo "* * * * *   root   bash /etc/cont-init.d/33-script-setup.bash" >> "/etc/crontab"
	
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config /storage
