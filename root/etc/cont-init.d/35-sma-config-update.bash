#!/usr/bin/with-contenv bash

# Check if config is already updated, if not start cron...
if [ ! -f "/config/config.xml" ]; then
	# start cron
	service cron start
	exit 0
fi

if [ -f "/config/config.xml" ]; then 
	# update autoprocess
	python3 /scripts/update.py
	# stop cron
	service cron status > /dev/null && service cron stop
fi

exit $?
