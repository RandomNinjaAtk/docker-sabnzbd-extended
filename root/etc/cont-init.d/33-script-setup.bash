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

if [ -f "/config/scripts/video-pp.bash" ]; then
	rm "/config/scripts/video-pp.bash"
	sleep 0.1
fi

# cp config file for use
if [ ! -f "/config/scripts/video-pp.bash" ]; then
	cp "/usr/local/sabnzbd-scripts/sabnzbd/video-pp.bash" "/config/scripts/video-pp.bash" && \
	chmod 0777 "/config/scripts/video-pp.bash"
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

# Check if config is already updated, if not start cron...
if cat "/config/sabnzbd.ini" | grep "/config/scripts" | read; then
	echo "config already updated..."
	exit 0
else
	# start cron
	service cron start
fi

# Check for finished initial config file, if sab is done, proceed with automated modifications...
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

	# Enable pause on post processing
	if cat "/config/sabnzbd.ini" | grep "pause_on_post_processing = 0" | read; then
		sed -i "s/pause_on_post_processing = 0/pause_on_post_processing = 1/g" "/config/sabnzbd.ini"
	fi

	# Set permissions
	if cat "/config/sabnzbd.ini" | grep "permissions = \"\"" | read; then
		sed -i "s/permissions = \"\"/permissions = \"766\"/g" "/config/sabnzbd.ini"
	fi

	# purge default categories
	sed -i '/\[\[software\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[audio\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini" && \
	sed -i '/\[\[movies\]\]/,+7d' "/config/sabnzbd.ini" && \

	# Add categories
	sed -i '/\[categories\]/a\\[\[radarr\]\]\npriority = -100\npp = ""\nname = radarr\nscript = video-pp.bash\nnewzbin = ""\norder = 1\n\dir = radarr\n\[\[sonarr\]\]\npriority = -100\npp = ""\nname = sonarr\nscript = video-pp.bash\nnewzbin = ""\norder = 2\n\dir = sonarr\n\[\[lidarr\]\]\npriority = -100\npp = ""\nname = lidarr\nscript = audio-pp.bash\nnewzbin = ""\norder = 3\n\dir = lidarr' "/config/sabnzbd.ini"
				
	sleep 2
	restartsab=$(pgrep s6-supervise | sort -r | head -n1) && \
	kill ${restartsab} && \
	echo "config updated" && \
	# stop cron
	service cron stop
fi

exit 0
