FROM jrottenberg/ffmpeg:snapshot-vaapi as ffmpeg
FROM linuxserver/sabnzbd
LABEL maintainer="RandomNinjaAtk"

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
