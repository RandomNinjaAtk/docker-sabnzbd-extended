#!/usr/bin/with-contenv bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
TITLESHORT="APP"
ScriptVersion="1.02"
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
    files="$(ls -1v "$1"/*.mp3)"
    start=0
    chapterNumber=0
    concatFileNames=""
    ffmpegMetadata=""
    chapterFile="$1/chapters.txt"
    fileList="$1/list.txt"
    for i in $(echo "$files"); do
        chapterNumber=$(( $chapterNumber + 1))
        if [ -z "$ffmpegMetadata" ]; then
            ffmpegMetadata=$(ffmpeg -i "$i" -f ffmetadata -v quiet -)
            echo "$ffmpegMetadata" >> $chapterFile
            echo "" >> $chapterFile
        fi
        #echo "start :: $start"
        echo "[CHAPTER]" >> $chapterFile
        echo "TIMEBASE=1/1000" >> $chapterFile
        echo "START=$start" >> $chapterFile
        seconds=$(sox "$i" -n stat |& head -2 | tail -1 | grep -o '[[:digit:]]*' | head -1)
        seconds=$(( $seconds * 1000 ))
        end=$(( $start + $seconds - 1 ))
        #echo "seconds :: $seconds"
        #echo "end :: $end"
        echo "END=$end" >> $chapterFile
        echo "title=Part \#$chapterNumber" >> $chapterFile
        echo "" >> $chapterFile
        start=$(( $end + 1 ))
        echo "file '$i'" >> $fileList

        
    done
    IFS="$OLDIFS"
    ffmpeg -f concat -safe 0 -i "$fileList" -i "$chapterFile" -map_metadata 1 -vn -acodec aac "$1/output.mp4"
    mv "$1/output.mp4" "$1/audiobook.m4b"
    find "$1" -type f -iname "*.mp3" -delete
    rm "$chapterFile"
    rm "$fileList"
fi
duration=$SECONDS
echo "Post Processing Completed in $(($duration / 60 )) minutes and $(($duration % 60 )) seconds!"
exit
