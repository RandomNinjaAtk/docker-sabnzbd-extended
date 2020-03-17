FROM randomninjaatk/ffmpeg:bin as binstage
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV SABSCRIPTS_PATH /usr/local/sabnzbd-scripts
ENV SMA_PATH /usr/local/sma
ENV UPDATE false

# Add files from binstage
COPY --from=binstage / /

# hardware env
ENV LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ENV NVIDIA_VISIBLE_DEVICES="all"

RUN \
	# ffmpeg
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
		libxml2 && \
	echo "**** clean up ****" && \
	rm -rf \
		/var/lib/apt/lists/* \
		/var/tmp/*
	chmod 777 /usr/local/bin/ffmpeg && \
	chmod 777 /usr/local/bin/ffprobe


ENV VERSION="1.0.0"

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
  touch /var/log/sma.log && \
  chgrp users /var/log/sma.log && \
  chmod g+w /var/log/sma.log && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m pip install --user --upgrade pip && \
  python3 -m pip install --user virtualenv && \
  python3 -m virtualenv ${SMA_PATH}/venv && \
  cd ${SMA_PATH} && \
  pip3 install -r ${SMA_PATH}/setup/requirements.txt

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
