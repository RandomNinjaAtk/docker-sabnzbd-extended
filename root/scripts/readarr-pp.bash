#!/usr/bin/with-contenv bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
TITLESHORT="APP"
ScriptVersion="1.08"
SECONDS=0

set -e
set -o pipefail

touch "/config/scripts/logs/readarr-pp.txt"
chmod 666 "/config/scripts/logs/readarr-pp.txt"
exec &> >(tee -a "/config/scripts/logs/readarr-pp.txt")

echo "Processing: $1" 

Clean () {
	if [ $(find "$1" -type f -regex ".*/.*\.\(\m4b|flac\|mp3\|m4a\|alac\|ogg\|opus\)" | wc -l) -gt 0 ]; then
		find "$1" -type f -not -regex ".*/.*\.\(flac\|mp3\|m4a\|alac\|ogg\|opus\)" -delete
		find "$1" -mindepth 2 -type f -exec mv "{}" "$1"/ \;
		find "$1" -mindepth 1 -type d -delete
	else
		echo "ERROR: NO AUDIO FILES FOUND" && exit 1
	fi
}

Clean "$1"

echo "Creating Chapters File and File list for FFMPEG processing..."



if [ $(find "$1" -type f -iname "*.mp3" | wc -l) -gt 0 ]; then
    OLDIFS="$IFS"
    IFS=$'\n'
    start=0
    chapterNumber=0
    concatFileNames=""
    ffmpegMetadata=""
    chapterFile="$1/chapters.txt"
    mp3ChapterFile="$1/audiobook.chapters.txt"
    fileList="$1/list.txt"
    completedAudioBook="$1/audiobook.mp3"
    
    if [ -f "$chapterFile" ]; then
        rm "$chapterFile"
    fi
    if [ -f "$fileList" ]; then
        rm "$fileList"
    fi
    if [ -f "$completedAudioBook" ]; then
        rm "$completedAudioBook"
    fi

    files="$(ls -1v "$1"/*.mp3)"

    for i in $(echo "$files"); do
        chapterNumber=$(( $chapterNumber + 1))
	    chapterTitle=""
        mp3val -f "$i"
        chapterTitle=$(ffprobe -i "$i" -show_format -v quiet | sed -n 's/TAG:title=//p')
        if [ -z "$ffmpegMetadata" ]; then
            ffmpegMetadata=$(ffmpeg -i "$i" -f ffmetadata -v quiet -)
            echo "$ffmpegMetadata" >> "$chapterFile"
            echo "" >> "$chapterFile"
        fi
        #echo "start :: $start"
        echo "[CHAPTER]" >> "$chapterFile"
        echo "TIMEBASE=1/1000" >> "$chapterFile"
        echo "START=$start" >> "$chapterFile"
        if [ ! -z "$chapterTitle" ]; then
        	echo "$mp3chapTimeStamp $chapterTitle" >> "$mp3ChapterFile"
	    else
	    	echo "$mp3chapTimeStamp Chapter #$chapterNumber" >> "$mp3ChapterFile"
	    fi
        seconds=$(ffprobe -i "$i" -show_format -v quiet | sed -n 's/duration=//p' | cut -d "." -f1)
        seconds=$(( $seconds * 1000 ))
        end=$(( $start + $seconds - 1 ))
        
        #echo "seconds :: $seconds"
        #echo "end :: $end"
        echo "END=$end" >> "$chapterFile"
	    if [ ! -z "$chapterTitle" ]; then
        	echo "title=$chapterTitle" >> "$chapterFile"
	    else
	    	echo "title=Part \#$chapterNumber" >> "$chapterFile"
	    fi
        echo "" >> "$chapterFile"
        start=$(( $end + 1 ))
        echo "file '$i'" >> "$fileList"      
        
    done
    IFS="$OLDIFS"
    ffmpeg -f concat -safe 0 -i "$fileList" -f ffmetadata -i "$chapterFile" -c copy -map_metadata 1 -map_chapters 1 -id3v2_version 3 -c copy "$completedAudioBook"
    mp3val -f "$completedAudioBook"
    find "$1" -type f -not -iname "audiobook.mp3" -delete
    find "$1" -type f -iname "*.txt" -delete
fi
duration=$SECONDS
echo "Post Processing Completed in $(($duration / 60 )) minutes and $(($duration % 60 )) seconds!"
exit
