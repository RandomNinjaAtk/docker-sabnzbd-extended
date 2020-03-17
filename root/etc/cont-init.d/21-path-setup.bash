#!/usr/bin/with-contenv bash

# Create scripts directory
if [ ! -d "/config/scripts" ]; then
	mkdir -p "/config/scripts"
	chmod 0777 "/config/scripts"
fi

# Create downloads incomplete directory
if [ ! -d "/stroage/downloads/sabnzbd/incomplete" ]; then
	mkdir -p "/stroage/downloads/sabnzbd/incomplete"
	chmod 0777 "/stroage/downloads/sabnzbd/incomplete"
fi

# Create downloads complete directory
if [ ! -d "/stroage//downloads/sabnzbd/complete" ]; then
	mkdir -p "/stroage//downloads/sabnzbd/complete"
	chmod 0777 "/stroage//downloads/sabnzbd/complete"
fi

exit 0
