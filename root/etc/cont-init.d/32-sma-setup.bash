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

# remove sickbeard_mp4_automator log if exists
if [ -f "/var/log/sma.log" ]; then
	rm "/var/log/sma.log"
fi
touch "/var/log/sma.log"


# Set ffmpeg/ffprobe location
sed -i "s/ffmpeg.exe/ffmpeg/g" "/config/scripts/autoProcess.ini"
sed -i "s/ffprobe.exe/ffprobe/g" "/config/scripts/autoProcess.ini"

chmod 0777 -R "/usr/local/sma"

exit 0
