#!/usr/bin/with-contenv bash


if [ -f /config/scripts/video-pp.bash ]; then
	rm /config/scripts/video-pp.bash
fi

if [ ! -f /config/scripts/video-pp.bash ]; then
	cp /scripts/video-pp.bash /config/scripts/video-pp.bash
	chmod 777 /config/scripts/video-pp.bash
	chown abc:abc /config/scripts/video-pp.bash
fi


if [ -f /config/scripts/audio-pp.bash ]; then
	rm /config/scripts/audio-pp.bash
fi

if [ ! -f /config/scripts/audio-pp.bash ]; then
	cp /scripts/audio-pp.bash /config/scripts/audio-pp.bash
	chmod 777 /config/scripts/audio-pp.bash
	chown abc:abc /config/scripts/audio-pp.bash
fi

if [ ! -f /config/scripts/configs/beets-config.yaml ]; then
	cp /scripts/beets-config.yaml /config/scripts/configs/beets-config.yaml
	chmod 777 /config/scripts/configs/beets-config.yaml
	chown abc:abc /config/scripts/configs/beets-config.yaml
fi

if [ -f /config/scripts/logs/audio-pp.log ]; then
	rm /config/scripts/logs/audio-pp.log 
fi

if [ -f /config/scripts/logs/video-pp.log ]; then
	rm /config/scripts/logs/video-pp.log 
fi

chmod 0777 -R /scripts

exit $?
