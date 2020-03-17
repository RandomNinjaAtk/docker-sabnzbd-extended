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

if [ ! -f "/config/scripts/sab-config-updated" ]; then
	# start cron
	service cron start

	if [ -f "/config/sabnzbd.ini" ]; then
	
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
		
		# remove software category
		if cat "/config/sabnzbd.ini" | grep "\[\[software\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[software\]\]/,+7d' "/config/sabnzbd.ini"
		fi
		
		# Add radarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[radarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[movies\]\]/,+7d' "/config/sabnzbd.ini" && \
			echo "[[radarr]]" >> "/config/sabnzbd.ini" && \
			echo "priority = -100" >> "/config/sabnzbd.ini" && \
			echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
			echo "name = radarr" >> "/config/sabnzbd.ini" && \
			echo "script = video-pp.bash" >> "/config/sabnzbd.ini" && \
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
			echo "order = 1" >> "/config/sabnzbd.ini" && \
			echo "dir = radarr" >> "/config/sabnzbd.ini"
		fi

		# Add sonarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[sonarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini" && \
			echo "[[sonarr]]" >> "/config/sabnzbd.ini" && \
			echo "priority = -100" >> "/config/sabnzbd.ini" && \
			echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
			echo "name = sonarr" >> "/config/sabnzbd.ini" && \
			echo "script = video-pp.bash" >> "/config/sabnzbd.ini" && \
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
			echo "order = 2" >> "/config/sabnzbd.ini" && \
			echo "dir = sonarr" >> "/config/sabnzbd.ini"
		fi

		# Add lidarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[lidarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[audio\]\]/,+7d' "/config/sabnzbd.ini" && \
			echo "[[lidarr]]" >> "/config/sabnzbd.ini" && \
			echo "priority = -100" >> "/config/sabnzbd.ini" && \
			echo "pp = \"\"" >> "/config/sabnzbd.ini" && \
			echo "name = lidarr" >> "/config/sabnzbd.ini" && \
			echo "script = audio-pp.bash" >> "/config/sabnzbd.ini" && \
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini" && \
			echo "order = 3" >> "/config/sabnzbd.ini" && \
			echo "dir = lidarr" >> "/config/sabnzbd.ini"
		fi

		if [ ! -f "/config/scripts/sab-config-updated" ]; then
			touch "/config/scripts/sab-config-updated" && \
			chmod 0666 "/config/scripts/sab-config-updated"
		fi
	fi
	
	if [ -f "/config/scripts/sab-config-updated" ]; then
		# stop cron
		service cron stop
	fi
fi
exit 0
