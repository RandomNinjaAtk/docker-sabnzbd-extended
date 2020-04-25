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

# Update name of legacy file naming
if [ -f "/config/scripts/configs/autoProcess.ini" ]; then
	mv "/config/scripts/configs/autoProcess.ini" "/config/scripts/configs/video-pp-sma.ini"
fi

# import new config, if does not exist
if [ ! -f "/config/scripts/configs/video-pp-sma.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/configs/video-pp-sma.ini" && \
	python3 /scripts/update.py
fi

# create sma log file
touch "/config/scripts/logs/sma.log" && \

# link sma files
ln -s "/config/scripts/logs/sma.log" "/usr/local/sma/config/sma.log" && \

# set permissions
chmod 0777 -R "/usr/local/sma"
chmod 0777 -R "/scripts"
chmod 0777 -R "/config/scripts"

exit 0
