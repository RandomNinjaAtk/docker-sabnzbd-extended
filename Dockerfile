FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV TITLE="SABnzbd Extended"
ENV VERSION="1.0.11"
ENV SMA_PATH /usr/local/sma
ENV VIDEO_LANG eng
ENV VIDEO_SMA FALSE
ENV VIDEO_SMA_TAGGING FALSE
ENV AUDIO_VERIFY TRUE
ENV AUDIO_FORMAT FLAC
ENV AUDIO_BITRATE 320
ENV AUDIO_REPLAYGAIN FALSE
ENV AUDIO_DSFA TRUE
ENV AUDIO_DSFAS 150M

RUN \
	echo "************ install dependencies ************" && \
	apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository ppa:jonathonf/ffmpeg-4 -y && \
	echo "************ install and update packages ************" && \
	apt-get update && \
	apt-get install -y \
		mkvtoolnix \
		mp3val \
		flac \
		opus-tools \
		jq \
		git \
		ffmpeg \
		python3 \
		python3-pip && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
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
	echo "************ install beets ************" && \
	pip3 install https://github.com/beetbox/beets/tarball/master && \
	pip3 install pyacoustid
	

# copy local files
COPY root/ /

# set work directory
WORKDIR /config

# ports and volumes
EXPOSE 8080 9090
VOLUME /config
