#!/usr/bin/with-contenv bash

# link config file for use
if [ ! -f "/config/scripts/audio-pp.bash" ]; then
	ln -s "/usr/local/sabnzbd-scripts/audio-pp.bash" "/config/scripts/audio-pp.bash" && \
	chmod 0777 "/config/scripts/audio-pp.bash"
fi

# link config file for use
if [ ! -f "/config/scripts/video-pp.bash" ]; then
	ln -s "/usr/local/sabnzbd-scripts/video-pp.bash" "/config/scripts/video-pp.bash" && \
	chmod 0777 "/config/scripts/video-pp.bash"
fi

if [ ! -f "/config/sabnzbd.ini" ]; then
	# start cron
	service cron start
	exit 0
fi

if cat "/config/sabnzbd.ini" | grep "\[categories\]" | read; then

	# Add scripts path
	if cat "/config/sabnzbd.ini" | grep "script_dir = \"\"" | read; then
		sed -i "s/script_dir = \"\"/script_dir = \"\/config\/scripts\"/g" "/config/sabnzbd.ini"
	fi

	# Correct incomplete path
	if cat "/config/sabnzbd.ini" | grep "Downloads/incomplete" | read; then
		sed -i "s/Downloads\/incomplete/\/storage\/downloads\/sabnzbd\/incomplete/g" "/config/sabnzbd.ini"
	fi

	# Correct complete path
	if cat "/config/sabnzbd.ini" | grep "Downloads/complete" | read; then
		sed -i "s/Downloads\/complete/\/storage\/downloads\/sabnzbd\/complete/g" "/config/sabnzbd.ini"
	fi

	# Enable script failure
	if cat "/config/sabnzbd.ini" | grep "script_can_fail = 0" | read; then
		sed -i "s/script_can_fail = 0/script_can_fail = 1/g" "/config/sabnzbd.ini"
	fi

	# Enable permissions failure
	if cat "/config/sabnzbd.ini" | grep "permissions = \"\"" | read; then
		sed -i "s/permissions = \"\"/permissions = \"766\"/g" "/config/sabnzbd.ini"
	fi

	# cleanup default categories
	sed -i '/\[\[software\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[audio\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[movies\]\]/,+7d' "/config/sabnzbd.ini" && \
	
	# Add radarr category
	echo "[[radarr]]" >> "/config/sabnzbd.ini" && \
	echo "priority = -100" >> "/config/sabnzbd.ini" && \
	echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
	echo "name = radarr" >> "/config/sabnzbd.ini" && \
	echo "script = video-pp.bash" >> "/config/sabnzbd.ini" && \
	echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
	echo "order = 1" >> "/config/sabnzbd.ini" && \
	echo "dir = radarr" >> "/config/sabnzbd.ini" && \

	# Add sonarr category
	sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini" && \
	echo "[[sonarr]]" >> "/config/sabnzbd.ini" && \
	echo "priority = -100" >> "/config/sabnzbd.ini" && \
	echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
	echo "name = sonarr" >> "/config/sabnzbd.ini" && \
	echo "script = video-pp.bash" >> "/config/sabnzbd.ini" && \
	echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
	echo "order = 2" >> "/config/sabnzbd.ini" && \
	echo "dir = sonarr" >> "/config/sabnzbd.ini" && \

	# Add lidarr category
	echo "[[lidarr]]" >> "/config/sabnzbd.ini" && \
	echo "priority = -100" >> "/config/sabnzbd.ini" && \
	echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
	echo "name = lidarr" >> "/config/sabnzbd.ini" && \
	echo "script = audio-pp.bash" >> "/config/sabnzbd.ini" && \
	echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
	echo "order = 3" >> "/config/sabnzbd.ini" && \
	echo "dir = lidarr" >> "/config/sabnzbd.ini"
	
	restartsab=$(pgrep s6-supervise | sort -r | head -n1) && \
	kill ${restartsab} && \
	echo "config updated" && \
	# stop cron
	service cron stop
fi

exit 0
