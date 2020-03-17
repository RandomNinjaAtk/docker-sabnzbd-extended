#!/usr/bin/with-contenv bash

# import new config, if does not exist
if [ ! -f "/config/scripts/autoProcess.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/autoProcess.ini"
	# set permissions
	chmod 0666 "/config/scripts/autoProcess.ini"
fi

# link config file for use
if [ ! -f "/usr/local/sma/config/autoProcess.ini" ]; then
	ln -s "/config/scripts/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
fi

# remove sickbeard_mp4_automator log if exists
if [ -f "/var/log/sma.log" ]; then
	rm "/var/log/sma.log"
fi

# remove sickbeard_mp4_automator log from sma config folder if exists
if [ -f "/config/sma/sma.log" ]; then
	rm "/config/sma/sma.log"
fi

# create sma log file
touch "/config/scripts/sma.log" && \

# set permissions
chmod 0666 "/config/scripts/sma.log" && \

# link sma log file
ln -s "/config/scripts/sma.log" "/var/log/sma.log" && \

# Set ffmpeg/ffprobe location
sed -i "s/ffmpeg.exe/ffmpeg/g" "/config/scripts/autoProcess.ini"
sed -i "s/ffprobe.exe/ffprobe/g" "/config/scripts/autoProcess.ini"

chmod 0777 -R "/usr/local/sma"

exit 0
