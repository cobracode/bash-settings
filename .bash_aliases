


# Apps
alias Y="${APPS}/youtube-dl --update --no-overwrites --no-mtime"
alias YA="Y --extract-audio --audio-format aac --no-post-overwrites --audio-quality 1"


# Core
alias R="${TEXT_EDITOR} ~/.bash_aliases &"
alias RC="${TEXT_EDITOR} ~/.bash_aliases && S"
alias S='source ~/.bashrc';
alias l='ls --all --classify --human-readable -l --reverse -t --context'
alias ln='ln -b -v'
alias grep='grep --line-number --fixed-strings -I'
alias gR='grep --fixed-strings '
alias p='ps -e -f --forest -ww'
alias ptree='pstree --arguments --highlight-all --long'



# Development

# Git
alias ga='git add'
alias gd='git diff'
alias gs='git status'
alias gf='git fetch'

# Java
alias idea='idea.sh &'

# Personal Tools
alias getSongsOld='pushd ${GETSONGS}; python3 getSongs.py; popd'


# Efficiency
alias editSongs="${TEXT_EDITOR} ${DATA}/songs.txt &"
alias editSongDL="${TEXT_EDITOR} ${SONG_LIST_FILE} &"
alias editHosts="gksudo ${TEXT_EDITOR} /etc/hosts &"
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'
alias kp='keepass2 &'
alias mail='google-chrome mail.google.com'
alias transferDocs='cp --recursive --update --verbose ~/Documents/ ${STORAGE}'
alias transferPhotos='cp -nv ~/Pictures/* ${STORAGE}/Photos'
alias getSongs="pushd ~/RAM; Y --update --retries 3 --batch-file ${SONG_LIST_FILE} --no-overwrites --no-mtime --extract-audio --no-post-overwrites --audio-format aac --audio-quality 1; popd"
alias getAudio="pushd ~/RAM; Y --update --retries 3 --batch-file ${SONG_LIST_FILE} --no-overwrites --no-mtime; popd"
alias shrinkAudio='convertToSmallestAudio'
alias shrinkToAac='convertToSmallestAac'
alias shrinkAudios='batchShrinkAudio'
alias extractAudio='extractAudioFunc'

alias sleepMusic="mpv --loop ${MUSIC}/Relaxing\ deep\ sleep\ music.opus &"
alias song='songFunc'
alias songHere='songHereFunc'
alias vidHere='vidHereFunc'
alias replay='replayFunc'
alias rmLastPlayed='rmLastPlayedFunc'
alias saveLastPlayed='saveLastPlayedFunc'
alias saveSong='saveSongFunc'
alias favSong='favSongFunc'
alias snipMedia='snipMediaFunc'
alias syncSongs='syncSongsFunc'


function syncSongsHelperFunc {
	local songPath="$1"
	echo $songPath
}

# syncSongs usb-path
function syncSongsFunc {
	local usbPath="$1"
	local favDir="${MUSIC}/favs"

	# copy non-opus songs (receiver doesnt support opus yet :( )
	find "${favDir}" -type l -not -iname '*.opus' -exec cp --verbose --dereference --no-clobber {} "${usbPath}" \;

	# convert and copy opus songs
	#find "${favDir}" -type l -iname '*.opus' -exec bash -c 'echo "USB PATH: ffff $1"; ffmpeg -nostdin -n -i "$0" "${1}/${0}.aac"' $(basename {}) "${usbPath}" \;
	#find "${favDir}" -type l -iname '*.opus' -exec echo "USB PATH: $(basename {})" \;
	#find "${favDir}" -type l -iname '*.opus' -exec bash -c 'syncSongsHelperFunc "$0"' {} \;
	#echo "USB PATH: ${usbPath}"

	while read -r file
	do
		local filename=$(basename "${file}")
		echo "hellfslfs   : ${file}"
		echo "filename: ${filename}"
		ffmpeg -nostdin -n -i "${file}" "${usbPath}/${filename}.aac"
	done <<< $(find "${favDir}" -type l -iname '*.opus')
}

# favSong songA songB songC
function favSongFunc {
	for song in "$@"
	do
		local songPath=$(readlink -f "${song}")
		local favDir="${MUSIC}/favs"
		ln --verbose --symbolic "${songPath}" "${favDir}"
	done
}

function saveSongFunc {
	local favDir="${MUSIC}/favs"
	mkdir --verbose --parents "${favDir}"
	ln --verbose --symbolic "${LAST_PLAYED}" "${favDir}"
}

function saveLastPlayedFunc {
	local favDir="${SAVE}/favs"
	mkdir --verbose --parents "${favDir}"
	ln --verbose --symbolic "${LAST_PLAYED}" "${favDir}"
}


function replayFunc {
	mpv --mute --loop "${LAST_PLAYED}" &
}

function snipMediaFunc {
	local start="$1"
	local end="$2"
	local file="$3"
	local outFile="$4"

	ffmpeg -ss "$start" -to "$end" -i "$file" -c copy "$outFile"
}


function rmLastPlayedFunc {
	rm -v "${LAST_PLAYED}"
}


function vidHereFunc {
	local dir="$1"
	#local vid="$(find ${dir} -type f -size +1k -a \( -name 'Flash*' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -name 'com.google.chrome*' \) | shuf -n 1)"
	local vid="$(find ${dir} -not -iname '*.jpg' -type f -size +100k | shuf -n 1)"

	while grep -q "${vid}" "${dir}/list.txt"; do
		echo "Video ${vid} already played"
		#vid="$(find ${dir} -type f -size +1k -a \(-iname '*.mov' -o -iname '*.tmp' -name '_Flash*' -o -iname '*.webp' -o -iname '*.gif' -o -name 'f_*' -o -iname '*.avi' -o -name 'Flash*' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -name 'com.google.chrome*' \) | shuf -n 1)"
		vid="$(find ${dir} -not -iname '*.jpg' -type f -size +100k | shuf -n 1)"
	done


	ffprobe "${vid}"

	local last=$(realpath "${vid}")
	export LAST_PLAYED="${last}"

	mpv --mute --loop "${vid}" &
	ls -lh "${vid}"
	echo "\"${vid}\""

	echo "${vid}" >> "${dir}/list.txt"
}


function songHereFunc {
	local dir="$1"
	local song="$(find ${dir} -type f | shuf -n 1)"
	ffprobe "${song}"
	mpv "${song}" &
	ls -lh "${song}"
	echo "\"${song}\""

	local last=$(realpath "${song}")
	export LAST_PLAYED="${last}"
}

function songFunc {
	local song="$(find ${MUSIC} -type f -size +50k | shuf -n 1)"
	ffprobe "${song}"
	mpv "${song}" &
	ls -lh "${song}"
	echo "\"${song}\""

	local last=$(realpath "${song}")
	export LAST_PLAYED="${last}"
}



# extractAudio <media file> <output file>
function extractAudioFunc {
	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -vn -acodec copy "${outputFile}"
}


function go {
	cd "$@"
	l
}

#alias cd='go'


function findSong {
	local songNamePortion="$@"

	echo "Finding song '$songNamePortion'"
	echo
	find $MUSIC -type f -iname "*${songNamePortion}*"
	echo
}

function play {
	local songNamePortion="$@"
	echo "Playing songs containing: ${songNamePortion}";
	find "${MUSIC}" -type f -iname "*${songNamePortion}*" -exec mpv \{\} \; &
}

function waitforjobs() {
    while test $(jobs -p | wc -w) -ge "$1"; do wait -n; done
}

function convertToSmallestAudio {
	local inputFile="$1"
	ffmpeg -nostdin -i "${inputFile}" -ar 8000 -ac 1 -b:a 10K "${inputFile}.opus" &
}

# Needed as many players don't recognize OPUS yet
# AAC is the next best format
function convertToSmallestAac {
	local inputFile="$1"
	ffmpeg -nostdin -i "${inputFile}" -c:a aac -ac 1 -ar 8000 -b:a 15k "${inputFile}.aac" &
}

function batchShrinkAudio() {
	saveifs=$IFS
	IFS=$(echo -en "\n\b")

	for file in $@; do
		local numJobs=$(jobs | wc -l)
		echo "$numJobs jobs running"

		if [ $numJobs -gt 6 ]; then
			echo "Waiting for the next job to finish"
			wait -n
			echo "Starting next song"
			ffmpeg -nostdin -n -i "${file}" -ar 8000 -ac 1 -b:a 10K "${file}.opus" &
		else
			ffmpeg -nostdin -n -i "${file}" -ar 8000 -ac 1 -b:a 10K "${file}.opus" &
		fi
	done

	jobs

	IFS=$saveifs
}


echo
echo "   UPDATED  BASHRC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo
