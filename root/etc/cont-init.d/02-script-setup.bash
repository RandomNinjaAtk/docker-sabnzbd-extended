#!/usr/bin/with-contenv bash

# Create scripts directory
if [ ! -d "/config/scripts" ]; then
	mkdir "/config/scripts"
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

exit 0
