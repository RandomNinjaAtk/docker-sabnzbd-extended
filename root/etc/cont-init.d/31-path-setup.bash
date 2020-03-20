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

# Create downloads incomplete directory
if [ ! -d "/storage/downloads/sabnzbd/incomplete" ]; then
	mkdir -p "/storage/downloads/sabnzbd/incomplete"
	chmod 0777 "/storage/downloads/sabnzbd/incomplete"
fi

# Create downloads complete directory
if [ ! -d "/storage/downloads/sabnzbd/complete" ]; then
	mkdir -p "/storage/downloads/sabnzbd/complete"
	chmod 0777 "/storage/downloads/sabnzbd/complete"
fi

exit 0
