FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM linuxserver/sabnzbd:arm32v7-latest

# Add QEMU
COPY --from=builder qemu-arm-static /usr/bin

LABEL maintainer="RandomNinjaAtk"
ENV TITLE="SABnzbd Extended"
ENV VERSION="1.0.144"
ENV SMA_PATH /usr/local/sma
ENV VIDEO_LANG eng
ENV VIDEO_SMA FALSE
ENV VIDEO_SMA_TAGGING FALSE
ENV AUDIO_VERIFY TRUE
ENV AUDIO_FORMAT FLAC
ENV AUDIO_BITRATE 320
ENV AUDIO_REPLAYGAIN FALSE
ENV AUDIO_DSFA TRUE
ENV AUDIO_DSFAS 153600k
ENV RequireAudioQualityMatch false

RUN \
	echo "************ install and update packages ************" && \
	apk add  -U --update --no-cache \
		flac \
		opus-tools \
		jq \
		git \
		mkvtoolnix \
		sox \
		ffmpeg && \
	echo "************ install python packages ************" && \
	pip install --upgrade --no-cache-dir -U \
		r128gain && \
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
