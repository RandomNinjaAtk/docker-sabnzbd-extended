#!/usr/bin/with-contenv bash

# set permissions
chmod 0777 -R /usr/local/sabnzbd-scripts

if [ -f "/config/scripts/audio-pp.bash" ]; then
	rm "/config/scripts/audio-pp.bash"
	sleep 0.1
fi

# cp config file for use
if [ ! -f "/config/scripts/audio-pp.bash" ]; then
	cp "/usr/local/sabnzbd-scripts/audio-pp.bash" "/config/scripts/audio-pp.bash" && \
	chmod 0777 "/config/scripts/audio-pp.bash"
fi

if [ -f "/config/scripts/radarr-pp.bash" ]; then
	rm "/config/scripts/radarr-pp.bash"
	sleep 0.1
fi

# link config file for use
if [ ! -f "/config/scripts/radarr-pp.bash" ]; then
	cp "/usr/local/sabnzbd-scripts/sabnzbd/radarr-pp.bash" "/config/scripts/" && \
	chmod 0777 "/config/scripts/radarr-pp.bash"
fi

if [ -f "/config/scripts/sonarr-pp.bash" ]; then
	rm "/config/scripts/sonarr-pp.bash"
	sleep 0.1
fi

# link config file for use
if [ ! -f "/config/scripts/sonarr-pp.bash" ]; then
	cp "/usr/local/sabnzbd-scripts/sabnzbd/sonarr-pp.bash" "/config/scripts/" && \
	chmod 0777 "/config/scripts/sonarr-pp.bash"
fi

if [ ! -f "/config/sabnzbd.ini" ]; then
	# start cron
	service cron start
	exit 0
fi

if cat "/config/sabnzbd.ini" | grep "\[categories\]" | read; then
	if cat "/config/sabnzbd.ini" | grep "/config/scripts" | read; then
		sleep 0.1
	else
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

		# Enable pause on post processing
		if cat "/config/sabnzbd.ini" | grep "pause_on_post_processing = 0" | read; then
			sed -i "s/pause_on_post_processing = 0/pause_on_post_processing = 1/g" "/config/sabnzbd.ini"
		fi

		# Set permissions
		if cat "/config/sabnzbd.ini" | grep "permissions = \"\"" | read; then
			sed -i "s/permissions = \"\"/permissions = \"766\"/g" "/config/sabnzbd.ini"
		fi

		# purge default categories
		sed -i '/\[categories\]/,+d' "/config/sabnzbd.ini" && \
		sed -i '/\[\[*\]\]/,+7d' "/config/sabnzbd.ini" && \
		sed -i '/\[\[software\]\]/,+7d' "/config/sabnzbd.ini" && \
		sed -i '/\[\[audio\]\]/,+7d' "/config/sabnzbd.ini" && \
		sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini" && \
		sed -i '/\[\[movies\]\]/,+7d' "/config/sabnzbd.ini" && \

		# Add categories
		echo "[categories]" >> "/config/sabnzbd.ini" && \
		
		# Add * category
		echo "[[*]]" >> "/config/sabnzbd.ini" && \
		echo "priority = 0" >> "/config/sabnzbd.ini" && \
		echo "pp = 3" >> "/config/sabnzbd.ini" && \
		echo "name = *" >> "/config/sabnzbd.ini" && \
		echo "script = None" >> "/config/sabnzbd.ini" && \
		echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
		echo "order = 0" >> "/config/sabnzbd.ini" && \
		echo "dir = \"\"" >> "/config/sabnzbd.ini" && \

		# Add radarr category
		echo "[[radarr]]" >> "/config/sabnzbd.ini" && \
		echo "priority = -100" >> "/config/sabnzbd.ini" && \
		echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
		echo "name = radarr" >> "/config/sabnzbd.ini" && \
		echo "script = radarr-pp.bash" >> "/config/sabnzbd.ini" && \
		echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
		echo "order = 1" >> "/config/sabnzbd.ini" && \
		echo "dir = radarr" >> "/config/sabnzbd.ini" && \

		# Add sonarr category
		echo "[[sonarr]]" >> "/config/sabnzbd.ini" && \
		echo "priority = -100" >> "/config/sabnzbd.ini" && \
		echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
		echo "name = sonarr" >> "/config/sabnzbd.ini" && \
		echo "script = sonarr-pp.bash" >> "/config/sabnzbd.ini" && \
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
		
		sleep 5
		restartsab=$(pgrep s6-supervise | sort -r | head -n1) && \
		kill ${restartsab} && \
		echo "config updated" && \
		# stop cron
		service cron stop
	fi
fi

exit 0
