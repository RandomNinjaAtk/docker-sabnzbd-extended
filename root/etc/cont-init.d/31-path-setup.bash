#!/usr/bin/with-contenv bash

# Create scripts directory
if [ ! -d "/config/scripts" ]; then
	mkdir -p "/config/scripts"
	chmod 0777 "/config/scripts"
fi

# Create configs directory
if [ ! -d "/config/scripts/configs" ]; then
	mkdir -p "/config/scripts/configs"
	chmod 0777 "/config/scripts/configs"
fi

# Create logs directory
if [ ! -d "/config/scripts/logs" ]; then
	mkdir -p "/config/scripts/logs"
	chmod 0777 "/config/scripts/logs"
fi

exit $?
