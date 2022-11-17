#!/usr/bin/with-contenv bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
TITLESHORT="VPP"
scriptVersion=1.0.19

set -e
set -o pipefail

touch "/config/scripts/logs/video-pp.txt"
chmod 666 "/config/scripts/logs/video-pp.txt"
exec &> >(tee -a "/config/scripts/logs/video-pp.txt")


function Configuration {
	log "SABnzbd Job: $jobname"
	log "SABnzbd Category: $category"
	log "DOCKER: $TITLE"
	log "DOCKER VERSION: $VERSION"
	log "SCRIPT: Video Post Processor ($TITLESHORT)"
	log "CONFIGURATION VERIFICATION"
	log "##########################"
	
	log "$TITLESHORT: Required Audio/Subtitle Language: ${VIDEO_LANG}"
	if [ ${VIDEO_MKVCLEANER} = TRUE ]; then
		log "$TITLESHORT: MKV Cleaner: ENABLED"
	else
		log "$TITLESHORT: MKV Cleaner: DISABLED"
	fi
	if [ ${VIDEO_SMA} = TRUE ]; then
		log "$TITLESHORT: Sickbeard MP4 Automator (SMA): ENABLED"
		if [ ${VIDEO_SMA_TAGGING} = TRUE ]; then
			tagging="-a"
			log "$TITLESHORT: Sickbeard MP4 Automator (SMA): Tagging: ENABLED"
		else
			tagging="-nt"
			log "$TITLESHORT: Sickbeard MP4 Automator (SMA): Tagging: DISABLED"
		fi
	else
		log "$TITLESHORT: Sickbeard MP4 Automator (SMA): DISABLED"
	fi
	
	if [ -z "VIDEO_SMA_TAGGING" ]; then
		VIDEO_SMA_TAGGING=FALSE
	fi
}


function log {
    m_time=`date "+%F %T"`
    echo $m_time" :: $scriptVersion :: "$1
}


function Main {
	SECONDS=0
	error=0
	folderpath="$1"
	jobname="$3"
	category="$5"
	
	Configuration

	# check for video files
	if find "$1" -type f -regex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" | read; then
		sleep 0.1
	else
		log "ERROR: No video files found for processing"
		exit 1
	fi

	count=0
	fileCount=$(find "$1" -type f -regex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" | wc -l)
	log "Processing ${fileCount} video files..."
	find "$1" -type f -regex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" -print0 | while IFS= read -r -d '' file; do
		count=$(($count+1))
		baseFileName="${file%.*}"
		fileName="$(basename "$file")"
		extension="${fileName##*.}"
		log "$count of $fileCount :: Processing $fileName"
		videoData=$(ffprobe -v quiet -print_format json -show_streams "$file")
		videoAudioLanguages=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"audio\") | .tags.language")
		videoAudioTracksCount=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"audio\") | .index" | wc -l)
		videoSubtitleLanguages=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | .tags.language")
		videoSubtitleTracksCount=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | .index" | wc -l)

		log "$count of $fileCount :: $videoAudioTracksCount Audio Tracks Found!"
		log "$count of $fileCount :: $videoSubtitleTracksCount Subtitle Tracks Found!"

		# Language Check
		log "$count of $fileCount :: Checking for preferred languages \"$VIDEO_LANG\""
		preferredLanguage=false
		IFS=',' read -r -a filters <<< "$VIDEO_LANG"
		for filter in "${filters[@]}"
		do
			videoAudioTracksLanguageCount=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==\"${filter}\") | .index" | wc -l)
			videoSubtitleTracksLanguageCount=$(echo "${videoData}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | select(.tags.language==\"${filter}\") | .index" | wc -l)
			log "$count of $fileCount :: $videoAudioTracksLanguageCount \"$filter\" Audio Tracks Found!"
			log "$count of $fileCount :: $videoSubtitleTracksLanguageCount \"$filter\" Subtitle Tracks Found!"			
			if [ "$preferredLanguage" == "false" ]; then
				if echo "$videoAudioLanguages" | grep -i "$filter" | read; then
					preferredLanguage=true
				elif echo "$videoSubtitleLanguages" | grep -i "$filter" | read; then
					preferredLanguage=true
				fi
			fi
		done

		if [ "$preferredLanguage" == "false" ]; then
			log "$count of $fileCount :: ERROR :: No matching languages found in $(($videoAudioTracksCount + $videoSubtitleTracksCount)) Audio/Subtitle tracks"
			rm "$file" && log "INFO: deleted: $fileName"
		fi

		if [ ${VIDEO_SMA} = TRUE ]; then
			if [ -f "$file" ]; then	
				if [ -f /usr/local/sma/config/sma.log ]; then
					rm /usr/local/sma/config/sma.log
				fi

				log "$count of $fileCount :: Processing with SMA..."
				if [ -f "/config/scripts/configs/$5-sma.ini" ]; then
					
					# Manual run of Sickbeard MP4 Automator
					if python3 /usr/local/sma/manual.py --config "/config/scripts/configs/$5-sma.ini" -i "$file" $tagging; then
						log "$count of $fileCount :: Complete!"
					else
						log "$count of $fileCount :: ERROR :: SMA Processing Error"
						rm "$file" && log "INFO: deleted: $fileName"
					fi
				else
					log "$count of $fileCount :: ERROR :: SMA Processing Error"
					log "$count of $fileCount :: ERROR :: \"/config/scripts/configs/$5-sma.ini\" configuration file is missing..."
					rm "$file" && log "INFO: deleted: $fileName"
				fi
			fi
		fi
		
		log "$count of $fileCount :: Processing complete for: ${fileName}!"

	done
		
	if find "$1" -type f -regex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" | read; then
		duration=$SECONDS
		echo "Post Processing Completed in $(($duration / 60 )) minutes and $(($duration % 60 )) seconds!"
	else
		log "ERROR :: Post Processing failed, no video files found..."
		exit 1
	fi
}

Main "$@" 

exit $?
