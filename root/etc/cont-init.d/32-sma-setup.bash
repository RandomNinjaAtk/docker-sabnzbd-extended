#!/usr/bin/with-contenv bash

# Remove exisitng
if [ -d "/config/scripts/sma" ]; then
	rm -rf "/config/scripts/sma" && \
	sleep 0.1
fi

if [ -d "/usr/local/sma/config" ]; then
	rm -rf /usr/local/sma/config/* && \
	sleep 0.1
fi

# create config directory
if [ ! -d "/config/scripts/sma" ]; then
	mkdir -p "/config/scripts/sma" && \
	chmod 0777 -R "/config/scripts/sma"
fi


# import new config, if does not exist
if [ ! -f "/config/sma/autoProcess.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/usr/local/sma/config/autoProcess.ini"
fi

# create sma log file
touch "/config/scripts/sma/sma.log" && \

# link sma log file
ln -s "/config/scripts/sma/sma.log" "/usr/local/sma/config/sma.log" && \

# set permissions
chmod 0666 "/config/scripts/sma"/*
chmod 0777 -R "/usr/local/sma"
chmod 0777 -R "/scripts"

exit 0
