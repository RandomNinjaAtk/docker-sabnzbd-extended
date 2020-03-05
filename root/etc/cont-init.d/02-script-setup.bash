#!/usr/bin/with-contenv bash

# Create scripts directory
if [ ! -d "/config/scripts" ]; then
	mkdir -p "/config/scripts"
	chmod 0777 "/config/scripts"
fi

# Remove existing AudioPostProcessing script
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
if [ ! -d "/downloads/sabnzbd/incomplete" ]; then
	mkdir -p "/downloads/sabnzbd/incomplete"
	chmod 0777 "/downloads/sabnzbd/incomplete"
fi

# Create downloads complete directory
if [ ! -d "/downloads/sabnzbd/complete" ]; then
	mkdir -p "/downloads/sabnzbd/complete"
	chmod 0777 "/downloads/sabnzbd/complete"
fi

if [ ! -f "/config/scripts/sab-config-updated" ]; then
	# start cron
	service cron start

	if [ -f "/config/sabnzbd.ini" ]; then
	
		# Add scripts path
		if cat "/config/sabnzbd.ini" | grep "/config/scripts" | read; then
			sleep 0.1
		else
			sed -i "s/script_dir = \"\"/script_dir = \"\/config\/scripts\"/g" "/config/sabnzbd.ini"
		fi

		# Correct incomplete path
		if cat "/config/sabnzbd.ini" | grep "/downloads/sabnzbd/incomplete" | read; then
			sleep 0.1
		else
			sed -i "s/Downloads\/incomplete/\/downloads\/sabnzbd\/incomplete/g" "/config/sabnzbd.ini"
		fi

		# Correct complete path
		if cat "/config/sabnzbd.ini" | grep "/downloads/sabnzbd/complete" | read; then
			sleep 0.1
		else
			sed -i "s/Downloads\/complete/\/downloads\/sabnzbd\/complete/g" "/config/sabnzbd.ini"
		fi

		# Enable script failure
		if cat "/config/sabnzbd.ini" | grep "script_can_fail = 0" | read; then
			sleep 0.1
		else
			sed -i "s/script_can_fail = 0/script_can_fail = 1/g" "/config/sabnzbd.ini"
		fi	

		# Add radarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[radarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[movies\]\]/,+7d' "/config/sabnzbd.ini"
			echo "[[radarr]]" >> "/config/sabnzbd.ini"
			echo "priority = -100" >> "/config/sabnzbd.ini"
			echo "pp = \"\"" >> "/config/sabnzbd.ini"
			echo "name = radarr" >> "/config/sabnzbd.ini"
			echo "script = Default" >> "/config/sabnzbd.ini"
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini"
			echo "order = 1" >> "/config/sabnzbd.ini"
			echo "dir = radarr" >> "/config/sabnzbd.ini"
		fi

		# Add sonarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[sonarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[tv\]\]/,+7d' "/config/sabnzbd.ini"
			echo "[[sonarr]]" >> "/config/sabnzbd.ini"
			echo "priority = -100" >> "/config/sabnzbd.ini"
			echo "pp = \"\"" >> "/config/sabnzbd.ini"
			echo "name = sonarr" >> "/config/sabnzbd.ini"
			echo "script = Default" >> "/config/sabnzbd.ini"
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini"
			echo "order = 2" >> "/config/sabnzbd.ini"
			echo "dir = sonarr" >> "/config/sabnzbd.ini"
		fi

		# Add lidarr category
		if cat "/config/sabnzbd.ini" | grep "\[\[lidarr\]\]" | read; then
			sleep 0.1
		else
			sed -i '/\[\[audio\]\]/,+7d' "/config/sabnzbd.ini"
			echo "[[lidarr]]" >> "/config/sabnzbd.ini"
			echo "priority = -100" >> "/config/sabnzbd.ini"
			echo "pp = \"\"" >> "/config/sabnzbd.ini"
			echo "name = lidarr" >> "/config/sabnzbd.ini"
			echo "script = AudioPostProcessing.bash" >> "/config/sabnzbd.ini"
			echo "newzbin = \"\"" >> "/config/sabnzbd.ini"
			echo "order = 3" >> "/config/sabnzbd.ini"
			echo "dir = lidarr" >> "/config/sabnzbd.ini"
		fi

		if [ ! -f "/config/scripts/sab-config-updated" ]; then
			touch "/config/scripts/sab-config-updated"
			chmod 0666 "/config/scripts/sab-config-updated"
		fi
	fi
	
	if [ -f "/config/scripts/sab-config-updated" ]; then
		# stop cron
		service cron stop
	fi
fi
exit 0
