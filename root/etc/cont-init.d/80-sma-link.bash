#!/usr/bin/with-contenv bash

# create config directory
if [ ! -d "/config/scripts/sma" ]; then
	mkdir -p "/config/scripts/sma" && \
	chmod 0777 -R "/config/scripts/sma"
fi

# import new config, if does not exist
if [ ! -f "/config/scripts/sma/autoProcess.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/scripts/sma/autoProcess.ini"
fi

# link config file for use
if [ ! -f "/usr/local/sma/scripts/config/autoProcess.ini" ]; then
	ln -s "/config/scripts/sma/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
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
touch "/config/scripts/sma/sma.log" && \

# link sma log file
ln -s "/config/scripts/sma/sma.log" "/var/log/sma.log" && \

# set permissions
chmod 0666 "/config/scripts/sma"/*

# update from git
if [[ "${SMA_UPDATE}" == "true" ]]; then
    git -C ${SMA_PATH} pull origin master
fi

# permissions
chown -R abc:abc ${SMA_PATH}
chmod -R 775 ${SMA_PATH}/*.sh

exit 0
