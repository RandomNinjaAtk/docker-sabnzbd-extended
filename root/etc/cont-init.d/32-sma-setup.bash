#!/usr/bin/with-contenv bash

# Remove exisitng
if [ -d "/config/scripts/logs" ]; then
	rm -rf "/config/scripts/logs" && \
	sleep 0.1
fi

if [ -d "/usr/local/sma/config" ]; then
	rm -rf /usr/local/sma/config/* && \
	sleep 0.1
fi

# create logs directory
if [ ! -d "/config/scripts/logs" ]; then
	mkdir -p "/config/scripts/logs" && \
	chmod 0777 -R "/config/scripts/logs"
fi

# create config directory
if [ ! -d "/config/scripts/configs" ]; then
	mkdir -p "/config/scripts/configs" && \
	chmod 0777 -R "/config/scripts/configs"
fi

# import new config, if does not exist
if [ ! -f "/config/scripts/configs/radarr-sma.ini" ] || [ ! -f "/config/scripts/configs/sonarr-sma.ini" ]; then
	if [ ! -f "/config/scripts/configs/video-pp-sma.ini" ]; then
		cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/configs/video-pp-sma.ini" && \
		python3 /scripts/update.py
	fi
fi

if [ -f "/config/scripts/configs/video-pp-sma.ini" ]; then
    cp "/config/scripts/configs/video-pp-sma.ini" "/config/scripts/configs/radarr-sma.ini" && \
    cp "/config/scripts/configs/video-pp-sma.ini" "/config/scripts/configs/sonarr-sma.ini" && \
    rm "/config/scripts/configs/video-pp-sma.ini"
fi


# create sma log file
touch "/config/scripts/logs/sma.log" && \

# link sma files
ln -s "/config/scripts/logs/sma.log" "/usr/local/sma/config/sma.log" && \

# set permissions
chmod 0777 -R "/usr/local/sma"
chmod 0777 -R "/scripts"
chmod 0777 -R "/config/scripts"

exit $?
