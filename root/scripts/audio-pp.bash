#!/usr/bin/with-contenv bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
TITLESHORT="APP"

Main () {
	# SETTINGS
	AudioVerification="${AUDIO_VERIFY}" # TRUE = ENABLED, Verifies FLAC/MP3 files for errors (fixes MP3's, deletes bad FLAC files)
	ConversionFormat="${AUDIO_FORMAT}" # SET TO: OPUS or AAC or MP3 or ALAC or FLAC - converts lossless FLAC files to set format
	ConversionBitrate="${AUDIO_BITRATE}" # Set to desired bitrate when converting to OPUS/AAC/MP3 format types
	ReplaygainTagging="${AUDIO_REPLAYGAIN}" # TRUE = ENABLED, adds replaygain tags for compatible players (FLAC ONLY)
	BeetsTagging="${AUDIO_BEETS}" # TRUE = ENABLED, enables tagging with beets
	DetectNonSplitAlubms="${AUDIO_DSFA}" # TRUE = ENABLED :: Uses "MaxFileSize" to detect and mark download as failed if detected
	MaxFileSize="${AUDIO_DSFAS}" # M = MB, G = GB :: Set size threshold for detecting single file albums

	#============FUNCTIONS============

	settings () {

	echo "Configuration:"
	echo "Remove Non Audio Files: ENABLED"
	echo "Duplicate File CleanUp: ENABLED"
	if [ "${AudioVerification}" = TRUE ]; then
		echo "Audio Verification: ENABLED"
	else
		echo "Audio Verification: DISABLED"
	fi
	echo "Format: $ConversionFormat"
	if [ "${ConversionFormat}" = FLAC ]; then
		echo "Bitrate: lossless"
		echo "Replaygain Tagging: ENABLED"
	elif [ "${ConversionFormat}" = ALAC ]; then
		echo "Bitrate: lossless"
	else
		echo "Conversion Bitrate: ${ConversionBitrate}k"
	fi
	if [ "${DetectNonSplitAlubms}" = TRUE ]; then
		echo "Detect Non Split Alubms: ENABLED"
		echo "Max File Size: $MaxFileSize" 
	else
		echo "DetectNonSplitAlubms: DISABLED"
	fi

	echo "Processing: $1" 

	}

	clean () {
		if find "$1" -type f -iregex ".*/.*\.\(flac\|mp3\|m4a\|alac\|ogg\|opus\)" | read; then
			if find "$1" -type f -not -iregex ".*/.*\.\(flac\|mp3\|m4a\|alac\|ogg\|opus\)" | read; then
				find "$1" -type f -not -iregex ".*/.*\.\(flac\|mp3\|m4a\|alac\|ogg\|opus\)" -delete
			fi
			find "$1" -mindepth 2 -type f -exec mv "{}" "$1"/ \;
			find "$1" -mindepth 1 -type d -delete
		else
			echo "ERROR: NO AUDIO FILES FOUND" && exit 1
		fi
	}

	duplicatefilecleanup () {
		duplicate="FALSE"
		if find "$1" -type f -mindepth 1 -iname "*([0-9]).*" | read; then
			find "$1" -type f -mindepth 1 -iname "*([0-9]).*" -delete
			duplicate="TRUE"
		fi

		if find "$1" -type f -mindepth 1 -iname "*.[0-9].*" | read; then
			find "$1" -type f -mindepth 1 -iname "*.[0-9].*" -delete
			duplicate="TRUE"
		fi

		if find "$1" -type f -mindepth 1 -iname "*.flac" | read; then
			if find "$1"/* -type f -not -iname "*.flac" | read; then
				find "$1"/* -type f -not -iname "*.flac" -delete
				duplicate="TRUE"
			fi
		fi
		if [ "${duplicate}" = TRUE ]; then
			echo "DUPLICATE FILE CLEANUP"
			echo "DUPLICATE FILE CLEANUP COMPLETE"
		fi
	}

	detectsinglefilealbums () {
		if find "$1" -type f -iregex ".*/.*\.\(flac\|mp3\|m4a\|alac\|ogg\|opus\)" -size +${MaxFileSize} | read; then
			echo "ERROR: Non split album detected" && exit 1
		fi
	}

	verify () {
		if find "$1" -iname "*.flac" | read; then
			verifytrackcount=$(find  "$1"/ -iname "*.flac" | wc -l)
			echo "Verifying: $verifytrackcount Tracks"
			if ! [ -x "$(command -v flac)" ]; then
				echo "ERROR: FLAC verification utility not installed (ubuntu: apt-get install -y flac)"
			else
				for fname in "$1"/*.flac; do
					filename="$(basename "$fname")"
					if flac -t --totally-silent "$fname"; then
						echo "Verified Track: $filename"
					else
						echo "ERROR: Track Verification Failed: \"$filename\""
						rm -rf "$1"/*
						sleep 0.1
						exit 1
					fi
				done
			fi
		fi
		if find "$1" -iname "*.mp3" | read; then
			verifytrackcount=$(find  "$1"/ -iname "*.mp3" | wc -l)
			echo ""
			echo "Verifying: $verifytrackcount Tracks"
			if ! [ -x "$(command -v mp3val)" ]; then
				echo "MP3VAL verification utility not installed (ubuntu: apt-get install -y mp3val)"
			else
				for fname in "$1"/*.mp3; do
					filename="$(basename "$fname")"
					if mp3val -f -nb "$fname" > /dev/null; then
						echo "Verified Track: $filename"
					fi
				done
			fi
		fi
	}

	conversion () {
		converttrackcount=$(find  "$1"/ -name "*.flac" | wc -l)
		targetformat="$ConversionFormat"
		bitrate="$ConversionBitrate"
		if [ "${ConversionFormat}" = OPUS ]; then
			options="-acodec libopus -ab ${bitrate}k -application audio -vbr off"
			extension="opus"
			targetbitrate="${bitrate}k"
		fi
		if [ "${ConversionFormat}" = AAC ]; then
			options="-acodec aac -ab ${bitrate}k -movflags faststart"
			extension="m4a"
			targetbitrate="${bitrate}k"
		fi
		if [ "${ConversionFormat}" = MP3 ]; then
			options="-acodec libmp3lame -ab ${bitrate}k"
			extension="mp3"
			targetbitrate="${bitrate}k"
		fi
		if [ "${ConversionFormat}" = ALAC ]; then
			options="-acodec alac -movflags faststart"
			extension="m4a"
			targetbitrate="lossless"
		fi
		if [ "${ConversionFormat}" = FLAC ]; then
			options="-acodec flac"
			extension="flac"
			targetbitrate="lossless"
		fi
		if [ -x "$(command -v ffmpeg)" ]; then
			if [ "${ConversionFormat}" = FLAC ]; then
				sleep 0.1
			elif find "$1"/ -name "*.flac" | read; then
				echo "Converting: $converttrackcount Tracks (Target Format: $targetformat (${targetbitrate}))"
				for fname in "$1"/*.flac; do
					filename="$(basename "${fname%.flac}")"
					if ffmpeg -loglevel warning -hide_banner -nostats -i "$fname" -n -vn $options "${fname%.flac}.temp.$extension"; then
						echo "Converted: $filename"
						if [ -f "${fname%.flac}.temp.$extension" ]; then
							rm "$fname"
							sleep 0.1
							mv "${fname%.flac}.temp.$extension" "${fname%.flac}.$extension"
						fi
					else
						echo "Conversion failed: $filename, performing cleanup..."
						rm -rf "$1"/*
						sleep 0.1
						exit 1
					fi
				done
			fi
		else
			echo "ERROR: ffmpeg not installed, please install ffmpeg to use this conversion feature"
			sleep 5
		fi
	}

	replaygain () {
		if ! [ -x "$(command -v flac)" ]; then
			echo "ERROR: METAFLAC replaygain utility not installed (ubuntu: apt-get install -y flac)"
		elif find "$1" -iname "*.flac" | read; then
			replaygaintrackcount=$(find  "$1"/ -iname "*.flac" | wc -l)
			echo "Replaygain: Calculating $replaygaintrackcount Tracks"
			find "$1" -iname "*.flac" -exec metaflac --add-replay-gain "{}" + && echo "Replaygain: $replaygaintrackcount Tracks Tagged"
		fi
	}
	
	beets () {
		echo ""
		trackcount=$(find "$1" -type f -iregex ".*/.*\.\(flac\|opus\|m4a\|mp3\)" | wc -l)
		echo "Matching $trackcount tracks with Beets"
		if [ ! -d /beets ]; then
			mkdir -p /beets
		fi
		if [ -f /beets/library.blb ]; then
			rm /beets/library.blb
			sleep 0.1
		fi
		if [ -f /beets/beets.log ]; then 
			rm /beets/beets.log
			sleep 0.1
		fi

		touch "/beets-match"
		sleep 0.1

		if find "$1" -type f -iregex ".*/.*\.\(flac\|opus\|m4a\|mp3\)" | read; then
			beet -c /config/scripts/config/beets-config.yaml -l /beets/library.blb -d "$1" import -q "$1" > /dev/null
			if find "$1" -type f -iregex ".*/.*\.\(flac\|opus\|m4a\|mp3\)" -newer "$1/beets-match" | read; then
				echo "SUCCESS: Matched with beets!"
			else
				rm -rf "$1"/* 
				echo "ERROR: Unable to match using beets to a musicbrainz release, marking download as failed..." && exit 1
			fi	
		fi

		if [ -f "/beets-match" ]; then 
			rm "/beets-match"
			sleep 0.1
		fi
	}

	
	#============START SCRIPT============

	settings "$1"
	clean "$1"
	duplicatefilecleanup "$1"
	detectsinglefilealbums "$1"

	if [ "${AudioVerification}" = TRUE ]; then
		verify "$1"
	fi

	conversion "$1"

	if [ "${ReplaygainTagging}" = TRUE ]; then
		replaygain "$1"
	fi
	
	if [ "${BeetsTagging}" = TRUE ]; then
		beets "$1"
	fi

	echo ""
	echo "Post Processing Complete!" && exit 0
	#============END SCRIPT============
}

Main "$@" | tee -a /config/scripts/logs/audio-pp.log
chmod 666 /config/scripts/logs/audio-pp.log
chown abc:abc /config/scripts/logs/audio-pp.log

exit $?
