FROM jrottenberg/ffmpeg:snapshot-vaapi as ffmpeg
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV SMA_UPDATE false

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

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

RUN \
	# ffmpeg
	apt-get update -qq && \
	apt-get install -qq -y \
		libva-drm2 \
		libva2 \
		i965-va-driver \
		libgomp1 && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	chgrp users /usr/local/bin/ffmpeg && \
	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe

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
	# setup cron
	service cron start && \
	echo "* * * * *   root   bash /etc/cont-init.d/02-script-setup.bash" >> "/etc/crontab" && \
	# Download Scripts
	mkdir -p "/root/scripts" && \
	curl -o "/root/scripts/AudioPostProcessing.bash" "https://raw.githubusercontent.com/RandomNinjaAtk/Scripts/master/sabnzbd/AudioPostProcessing.bash"

WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config /storage
