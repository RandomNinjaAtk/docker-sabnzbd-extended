#!/usr/bin/with-contenv bash

# Create scripts directory
if [ ! -d "/config/scripts" ]; then
	mkdir -p "/config/scripts"
fi

# Remove existing LAD start script
if [ -f "/config/scripts/AudioPostProcessing.bash" ]; then
	rm "/config/scripts/AudioPostProcessing.bash"
	sleep 0.1
fi

# Copy AudioPostProcessing into scripts directory
if [ ! -f "/config/scripts/AudioPostProcessing.bash" ]; then
	cp "/root/scripts/AudioPostProcessing.bash" "/config/scripts/AudioPostProcessing.bash"
	chmod 0777 "/config/scripts/AudioPostProcessing.bash"
fi

# Create downloads incomplete directory
if [ ! -d "/downloads/incomplete" ]; then
	mkdir -p "/downloads/incomplete"
	chmod 0777 "/downloads/incomplete"
fi

# Create downloads complete directory
if [ ! -d "/downloads/complete" ]; then
	mkdir -p "/downloads/complete"
	chmod 0777 "/downloads/incomplete"
fi

sed -i "s/script_dir = \"\"/script_dir = \"\/config\/scripts\"/g" "/config/sabnzbd.ini" && \
sed -i "s/Downloads\/incomplete/\/downloads\/incomplete/g" "/config/sabnzbd.ini" && \
sed -i "s/Downloads\/complete/\/downloads\/complete/g" "/config/sabnzbd.ini"

exit 0
