ARG ffmpeg_tag=snapshot-vaapi
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV SABSCRIPTS_PATH /usr/local/sabnzbd-scripts
ENV SMA_PATH /usr/local/sma
ENV UPDATE false
ENV VIDEO_LANG eng
ENV AUDIO_VERIFY TRUE
ENV AUDIO_FORMAT FDK-AAC
ENV AUDIO_BITRATE 320
ENV AUDIO_REPLAYGAIN FALSE
ENV AUDIO_DSFA TRUE
ENV AUDIO_DSFAS 150M

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

RUN \
	# install dependancies
	apt-get update -qq && \
	apt-get install -qq -y \
		mkvtoolnix \
		mp3val \
		flac \
		opus-tools \
		jq \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean

# get python3 and git, and install python libraries
RUN \
	apt-get update && \
	apt-get install -y \
		git \
		wget \
		python3 \
		python3-pip && \
	# make directory
	mkdir -p ${SMA_PATH} && \
	# download repo
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	# create logging file
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	# install pip, venv, and set up a virtual self contained python environment
	python3 -m pip install --user --upgrade pip && \
	pip3 install -r ${SMA_PATH}/setup/requirements.txt

RUN \
	# ffmpeg
	chgrp users /usr/local/bin/ffmpeg && \
	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "**** install runtime ****" && \
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
 	echo "**** clean up ****" && \
	rm -rf \
		/var/lib/apt/lists/* \
		/var/tmp/*

RUN \
	# make directory
	mkdir -p ${SABSCRIPTS_PATH} && \
	# download repo
	git clone https://github.com/RandomNinjaAtk/sabnzbd-scripts.git ${SABSCRIPTS_PATH}

RUN \
	# setup cron
	service cron start && \
	echo "* * * * *   root   bash /etc/cont-init.d/33-script-setup.bash" >> "/etc/crontab"
	
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config /storage
