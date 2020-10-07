#!/usr/bin/with-contenv bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
TITLESHORT="VPP"

set -e
set -o pipefail

function Configuration {
	log "##### SABnzbd Job: $jobname"
	log "##### SABnzbd Category: $category"
	log "##### DOCKER: $TITLE"
	log "##### SCRIPT: Video Post Processor ($TITLESHORT)"
	log "##### SCRIPT VERSION: 1.0.9"
	log "##### DOCKER VERSION: $VERSION"
	log "##### CONFIGURATION VERIFICATION"
	
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
    echo $m_time" "$1
}


function Main {
	error=0
	folderpath="$1"
	jobname="$3"
	category="$5"
	
	Configuration

	if [ ${VIDEO_SMA} = TRUE ]; then
		touch "$1/sma-conversion-check"
	elif [ ${VIDEO_MKVCLEANER} = TRUE ]; then 
		touch "$1/sma-conversion-check"
	fi

	# check for video files
	if find "$1" -type f -iregex ".*/.*\.\(mkv\|mp4\|avi\)" | read; then
		sleep 0.1
	else
		log "ERROR: No video files found for processing"
		exit 1
	fi


	filecount=$(find "$1" -type f -iregex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" | wc -l)
	log "Processing ${filecount} video files..."
	count=0
	find "$1" -type f -iregex ".*/.*\.\(wmv\|mkv\|mp4\|avi\)" -print0 | while IFS= read -r -d '' video; do
		count=$(($count+1))
		log ""
		log "===================================================="
		basefilename="${video%.*}"
		filename="$(basename "$video")"
		extension="${filename##*.}"
		log "Begin processing $count of $filecount: $filename"
		log "Checking for audio/subtitle tracks"
		tracks=$(ffprobe -v quiet -print_format json -show_streams "$video")
		if [ ! -z "${tracks}" ]; then
			# video tracks
			VideoTrack=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"video\") | .index")
			VideoTrackCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"video\") | .index" | wc -l)
			# video preferred language
			VideoTrackLanguage=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"video\") | select(.tags.language==\"${VIDEO_LANG}\") | .index")
			# audio tracks
			AudioTracks=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | .index")
			AudioTracksCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | .index" | wc -l)
			# audio preferred language
			AudioTracksLanguage=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==\"${VIDEO_LANG}\") | .index")
			AudioTracksLanguageCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==\"${VIDEO_LANG}\") | .index" | wc -l)
			AudioTracksLanguageFound=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | .tags.language")
			# audio unkown laguage
			AudioTracksLanguageUND=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==\"und\") | .index")
			AudioTracksLanguageUNDCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==\"und\") | .index" | wc -l)
			AudioTracksLanguageNull=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==null) | .index")
			AudioTracksLanguageNullCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"audio\") | select(.tags.language==null) | .index" | wc -l)
			# audio foreign language
			AudioTracksLanguageForeignCount=$(echo "${tracks}" | jq ".streams[] | select(.codec_type==\"audio\") | select(.tags.language!=\"${VIDEO_LANG}\") | .index" | wc -l)		
			# subtitle tracks
			SubtitleTracks=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | .index")
			SubtitleTracksCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | .index" | wc -l)
			# subtitle preferred langauge
			SubtitleTracksLanguage=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | select(.tags.language==\"${VIDEO_LANG}\") | .index")
			SubtitleTracksLanguageCount=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | select(.tags.language==\"${VIDEO_LANG}\") | .index" | wc -l)
			SubtitleTracksLanguageFound=$(echo "${tracks}" | jq -r ".streams[] | select(.codec_type==\"subtitle\") | .tags.language")
		else
			log "ERROR: ffprobe failed to read tracks and set values"
			rm "$video" && log "INFO: deleted: $video"
		fi
		
		# Check for video track
		if [ -z "${VideoTrack}" ]; then
			log "ERROR: no video track found"
			rm "$video" && log "INFO: deleted: $filename"
			continue
		else
			log "$VideoTrackCount video track found!"
		fi
		
		# Check for audio track
		if [ -z "${AudioTracks}" ]; then
			log "ERROR: no audio tracks found"
			rm "$video" && log "INFO: deleted: $filename"
			continue
		else
			log "$AudioTracksCount audio tracks found!"
		fi
		
		# Check for audio track
		if [ ! -z "${SubtitleTracks}" ]; then
			log "$SubtitleTracksCount subtitle tracks found!"
		fi
		
		log "Checking for \"${VIDEO_LANG}\" video/audio/subtitle tracks"
		if [ ! -z "$AudioTracksLanguage" ] || [ ! -z "$SubtitleTracksLanguage" ]; then
			if [ ! -z "${AudioTracksLanguage}" ]; then
				log "$AudioTracksLanguageCount \"${VIDEO_LANG}\" audio track found!"
			fi
			if [ ! -z "${SubtitleTracksLanguage}" ]; then
				log "$SubtitleTracksLanguageCount \"${VIDEO_LANG}\" subtitle track found!"
			fi
		else
			if [ ${VIDEO_MKVCLEANER} = TRUE ] || [ ${VIDEO_SMA} = TRUE ]; then
				if [ ! -z "$AudioTracksLanguageUND" ] || [ ! -z "$AudioTracksLanguageNull" ]; then
					if [ ! -z "${AudioTracksLanguageUND}" ]; then
						log "$AudioTracksLanguageUNDCount \"und\" audio tracks found!"
					fi
					if [ ! -z "${AudioTracksLanguageNull}" ]; then
						log "$AudioTracksLanguageNullCount \"unknown\" audio tracks found!"
					fi
				else
					log "ERROR: No \"${VIDEO_LANG}\" or \"Unknown\" audio tracks found..."
					log "ERROR: No \"${VIDEO_LANG}\" subtitle tracks found..."
					rm "$video"
					log "INFO: deleted: $filename"
					continue
				fi
			else			
				log "ERROR: No \"${VIDEO_LANG}\" audio or subtitle tracks found..."
				rm "$video"
				log "INFO: deleted: $filename"
				continue
			fi
		fi
					
		if [ ${VIDEO_MKVCLEANER} = TRUE ]; then
			log "Begin processing with MKV Cleaner..."
			log "Checking for \"${VIDEO_LANG}\" video/audio/subtitle tracks"
			# Check for unwanted audio tracks and remove/re-label as needed...
			if [ ! -z "$AudioTracksLanguage" ] || [ ! -z "$AudioTracksLanguageUND" ] || [ ! -z "$AudioTracksLanguageNull" ]; then
				if [ $AudioTracksCount -ne $AudioTracksLanguageCount ]; then
					RemoveAudioTracks="true"
					if [ ! -z "$AudioTracksLanguage" ]; then
						MKVaudio=" -a ${VIDEO_LANG}"
						log "$AudioTracksLanguageCount audio tracks found!"
						unwantedaudiocount=$(($AudioTracksCount-$AudioTracksLanguageCount))
						if [ $AudioTracksLanguageCount -ne $AudioTracksCount ]; then
							unwantedaudio="true"
						fi
					elif [ ! -z "$AudioTracksLanguageUND" ]; then
						for I in $AudioTracksLanguageUND
						do
							OUT=$OUT" -a $I --language $I:${VIDEO_LANG}"
						done
						MKVaudio="$OUT"
						log "$AudioTracksLanguageUNDCount \"unknown\" audio tracks found, re-tagging as \"${VIDEO_LANG}\""
						unwantedaudiocount=$(($AudioTracksCount-$AudioTracksLanguageUNDCount))
						if [ $AudioTracksLanguageUNDCount -ne $AudioTracksCount ]; then
							unwantedaudio="true"
						fi
					elif [ ! -z "$AudioTracksLanguageNull" ]; then
						for I in $AudioTracksLanguageNull
						do
							OUT=$OUT" -a $I --language $I:${VIDEO_LANG}"
						done
						MKVaudio="$OUT"
						log "$AudioTracksLanguageNullCount \"unknown\" audio tracks found, re-tagging as \"${VIDEO_LANG}\""
						unwantedaudiocount=$(($AudioTracksCount-$AudioTracksLanguageNullCount))
						if [ $AudioTracksLanguageNullCount -ne $AudioTracksCount ]; then
							unwantedaudio="true"
						fi
					fi
				else
					log "$AudioTracksLanguageCount audio tracks found!"
					RemoveAudioTracks="false"
					MKVaudio=""
				fi
			elif [ -z "$SubtitleTracksLanguage" ]; then
				if [ ! -z "${AudioTracks}" ]; then
					log "INFO: ${AudioTracksLanguageFound} audio track found!"
				fi
				if [ ! -z "${SubtitleTracks}" ]; then
					log "INFO: ${SubtitleTracksLanguageFound} subtitle track found!"
				fi
				log "ERROR: no \"${VIDEO_LANG}\" audio/subtitle tracks found!"
				# rm "$video" && echo "INFO: deleted: $filename"
				exit 1
			else
				foreignaudio="true"
				RemoveAudioTracks="false"
				MKVaudio=""
			fi
		
			# Check for unwanted subtitle tracks...
			if [ ! -z "$SubtitleTracks" ]; then
				if [ $SubtitleTracksCount -ne $SubtitleTracksLanguageCount ]; then
					RemoveSubtitleTracks="true"
					MKVSubtitle=" -s ${VIDEO_LANG}"
					if [ ! -z "$SubtitleTracksLanguage" ]; then
						log "$SubtitleTracksLanguageCount subtitle tracks found!"
					fi
					unwantedsubtitlecount=$(($SubtitleTracksCount-$SubtitleTracksLanguageCount))
					if [ $SubtitleTracksLanguageCount -ne $SubtitleTracksCount ]; then
						unwantedsubtitle="true"
					fi
				else
					log "$SubtitleTracksLanguageCount subtitle tracks found!"
					RemoveSubtitleTracks="false"
					MKVSubtitle=""
				fi
			else
				RemoveSubtitleTracks="false"
				MKVSubtitle=""
			fi
			
			# Correct video language, if needed...
			if [ -z "$VideoTrackLanguage" ]; then	
				if [ ! -z "$AudioTracksLanguage" ] || [ ! -z "$AudioTracksLanguageUND" ] || [ ! -z "$AudioTracksLanguageNull" ]; then
					SetVideoLanguage="true"
					if [ "${RemoveAudioTracks}" = true ] || [ "${RemoveSubtitleTracks}" = true ]; then
						log "$VideoTrackCount \"unknown\" video language track found, re-tagging as \"${VIDEO_LANG}\""
					fi
					MKVvideo=" -d ${VideoTrack} --language ${VideoTrack}:${VIDEO_LANG}"
				else
					foreignvideo="true"
					SetVideoLanguage="false"
					MKVvideo=""
				fi
			else
				log "$VideoTrackCount video track found!"
				SetVideoLanguage="false"
				MKVvideo=""
			fi
			
			# Display foreign audio track counts
			if [ "$foreignaudio" = true ] || [ "$foreignvideo" = true ]; then
				log "Checking for \"foreign\" audio/video tracks"
				if [ "$foreignvideo" = true ]; then
					log "$VideoTrackCount video track found!"
					foreignvideo="false"
				fi
				if [ "$foreignaudio" = true ]; then
					log "$AudioTracksLanguageForeignCount audio tracks found!"
					foreignaudio="false"
				fi
			fi
			
			# Display unwanted audio/subtitle track counts
			if [ "$unwantedaudio" = true ] || [ "$unwantedsubtitle" = true ]; then
				log "Checking for unwanted \"not: ${VIDEO_LANG}\" audio/subtitle tracks"
				if [ "$unwantedaudio" = true ]; then
					log "$unwantedaudiocount audio tracks to remove..."
					unwantedaudio="false"
				fi	
				if [ "$unwantedsubtitle" = true ]; then
					log "$unwantedsubtitlecount subtitle tracks to remove..."
					unwantedsubtitle="false"
				fi
			fi	
			skip="false"
			if [ "${RemoveAudioTracks}" = false ] && [ "${RemoveSubtitleTracks}" = false ]; then
				if find "$video" -type f -iname "*.mkv" | read; then
					log "INFO: Video passed all checks, no processing needed"
					touch "$video"
					if [ ${VIDEO_SMA} = TRUE ]; then
						skip="true"
					fi
				else
					log "INFO: Video passed all checks, but is in the incorrect container, repackaging as mkv..."
					MKVvideo=" -d ${VideoTrack} --language ${VideoTrack}:${VIDEO_LANG}"
					MKVaudio=" -a ${VIDEO_LANG}"
					MKVSubtitle=" -s ${VIDEO_LANG}"
				fi
			fi
			if [ $skip = false ]; then
				if mkvmerge --no-global-tags --title "" -o "${basefilename}.merged.mkv"${MKVvideo}${MKVaudio}${MKVSubtitle} "$video"; then
					log "SUCCESS: mkvmerge complete"
					log "INFO: Options used:${MKVvideo}${MKVaudio}${MKVSubtitle}"
					# cleanup temp files and rename
					mv "$video" "$video.original" && log "INFO: Renamed source file"
					mv "${basefilename}.merged.mkv" "${basefilename}.mkv" && log "INFO: Renamed temp file"
					rm "$video.original" && log "INFO: Deleted source file"
					extension="mkv"
				else
					log "ERROR: mkvmerge failed"
					rm "$video" && log "INFO: deleted: $video"
					rm "${basefilename}.merged.mkv" && log "INFO: deleted: ${basefilename}.merged.mkv"
					continue
				fi
			fi
		fi
			
		if [ ${VIDEO_SMA} = TRUE ]; then
			if [ -f "${basefilename}.${extension}" ]; then	
				if [ -f /config/scripts/logs/sma.log ]; then
					chmod 777 /config/scripts/logs/sma.log
					chown abc:abc /config/scripts/logs/sma.log
				fi
				log "========================START SMA========================"
				# Manual run of Sickbeard MP4 Automator
				if python3 /usr/local/sma/manual.py --config "/config/scripts/configs/$5-sma.ini" -i "${basefilename}.${extension}" $tagging; then
					sleep 0.01
				else
					log "ERROR: SMA Processing Error"
					rm "$video" && log "INFO: deleted: $filename"
				fi
				log "========================STOP SMA========================"
			fi
		fi
		
		if [ -f "${basefilename}.mkv" ];  then
			log "========================START MKVPROPEDIT========================"
			mkvpropedit "${basefilename}.mkv" --add-track-statistics-tags
			log "========================STOP MKVPROPEDIT========================="
		fi
		log "Processing complete for: ${filename}!"
	done

	if [ ${VIDEO_SMA} = TRUE ] || [ ${VIDEO_MKVCLEANER} = TRUE ]; then
		find "$1" -type f ! -newer "$1/sma-conversion-check" ! -name "sma-conversion-check" -delete
		# check for video files
		if find "$1" -type f -iregex ".*/.*\.\(mkv\|mp4\)" | read; then
			log "Post Processing Complete!"
		else
			log "ERROR: Post Processing failed, no video files found..."
			exit 1
		fi
		if [ -f "$1/sma-conversion-check" ]; then 
			rm "$1/sma-conversion-check"
		fi
	else
		if find "$1" -type f -iregex ".*/.*\.\(mkv\|mp4\|avi\)" | read; then
			log "Post Processing Complete!"
		else
			log "ERROR: Post Processing failed, no video files found..."
			exit 1
		fi
	fi
}

Main "$@" | tee -a /config/scripts/logs/video-pp.log
chmod 666 /config/scripts/logs/video-pp.log
chown abc:abc /config/scripts/logs/video-pp.log

exit $?
