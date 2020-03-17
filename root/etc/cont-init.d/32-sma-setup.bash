#!/usr/bin/with-contenv bash

# import new config, if does not exist
if [ ! -f "/config/scripts/configs/sonarr-pp.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/configs/sonarr-pp.ini"
	# set permissions
	chmod 0666 "/config/scripts/configs/sonarr-pp.ini"
fi

# import new config, if does not exist
if [ ! -f "/config/scripts/configs/radarr-pp.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/configs/radarr-pp.ini"
	# set permissions
	chmod 0666 "/config/scripts/configs/radarr-pp.ini"
fi

# Remove sonarr log
if [ ! -f "/config/scripts/logs/sonarr-pp.log" ]; then
	rm "/config/scripts/logs/sonarr-pp.log" && \
	sleep 0.1
fi

# Remove radarr log
if [ ! -f "/config/scripts/logs/radarr-pp.log" ]; then
	rm "/config/scripts/logs/radarr-pp.log" && \
	sleep 0.1
fi

# create sonarr log
if [ ! -f "/config/scripts/logs/sonarr-pp.log" ]; then
	touch "/config/scripts/logs/sonarr-pp.log"
fi

# create radarr log
if [ ! -f "/config/scripts/logs/radarr-pp.log" ]; then
	touch "/config/scripts/logs/radarr-pp.log"
fi

# remove sickbeard_mp4_automator log if exists
if [ -f "/var/log/sma.log" ]; then
	rm "/var/log/sma.log"
fi
touch "/var/log/sma.log"
chmod 0777 "/var/log/sma.log"


# Set ffmpeg/ffprobe location
sed -i "s/ffmpeg.exe/ffmpeg/g" "/config/scripts/configs/sonarr-pp.ini"
sed -i "s/ffprobe.exe/ffprobe/g" "/config/scripts/configs/sonarr-pp.ini"

# Set ffmpeg/ffprobe location
sed -i "s/ffmpeg.exe/ffmpeg/g" "/config/scripts/configs/radarr-pp.ini"
sed -i "s/ffprobe.exe/ffprobe/g" "/config/scripts/configs/radarr-pp.ini"

chmod 0777 -R "/usr/local/sma"

exit 0
