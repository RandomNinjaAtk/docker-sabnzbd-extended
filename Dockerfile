FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

ENV VERSION="1.0.0"

RUN \
	# install dependancies
	apt-get update -qq && \
	apt-get install -qq -y \
		mkvtoolnix \
		mp3val \
		flac \
		ffmpeg \
		opus-tools \
		jq \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean

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
VOLUME /config /downloads
