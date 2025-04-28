echo 'BEGIN ned-mac.sh'

# Set variables -------------------------

# Homebrew variables
eval "$(/opt/homebrew/bin/brew shellenv)"

# original prompt:
# PROMPT='%n@%m %1~ %#'
# export PROMPT='%F{green}%n%f@%F{blue}%m%f:%F{cyan}%~%f$ '
export PROMPT='%F{red}%h%f%F{blue}%n%f%?@%F{yellow}%~%f|%w|%*%# '

# Update PATH
export PATH="${PATH}:${HOME}/dev/platform-tools:${HOME}/Library/Python/3.9/bin"



# Unused for now 20250426
#export HISTFILE=/Users/ned/.ned_history

export HISTSIZE=99999
export SAVEHIST=99999
setopt hist_ignore_all_dups

export EBOOKS="/Users/ned/Library/Containers/com.amazon.Lassen/Data/Library/eBooks"
export MARS="/Users/ned/my-stuff/Documents/.system"


# Functions -----------------------------
# function code {
#     file = $1
#     open -b com.microsoft.vscode ${file}
# }

function my_traceroute {
    local host="${1:-google.com}"
    local maxHops="${2:-3}"
    echo 'my_traceroute <maxhops:3> <host:google.com>'
    echo "\ntraceroute -m ${maxHops} -q 1 -v ${host} 28\n"
    traceroute -m "${maxHops}" -q 1 -v "${host}" 28
}

# shrinkAudioFunc <media file>
function shrinkAudioFunc {
    if [ "$#" -ne 1 ]; then
        echo 'shrinkAudioFunc <media file>'
        return
    fi

	local mediaFile="$1"
	echo "ffmpeg -i ${mediaFile} -ac 1 -c:a libopus -b:a 6k -ar 8000 -vbr on ${mediaFile}.opus"
	ffmpeg -i "${mediaFile}" -ac 1 -c:a libopus -b:a 6k -ar 8000 -vbr on "${mediaFile}.opus"
}


# extractAudio <media file> <output file>
function extractAudioFunc {
    if [ "$#" -ne 2 ]; then
        echo 'extractAudio <media file> <output file>'
        return
    fi

	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -map 0:a -c:a copy "${outputFile}"
}

# extractVideo <media file> <output file>
function extractVideoFunc {
    if [ "$#" -ne 2 ]; then
        echo 'extractVideo <media file> <output file>'
        return
    fi

	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -map 0:v -c:v copy "${outputFile}"
}

function imageSongFunc {
    if [ "$#" -ne 3 ]; then
        echo 'imageSongFunc <image file> <song file> <output file>'
        return
    fi

    local imageFile="$1"
    local songFile="$2"
    local outputFile="$3"

    ffmpeg -loop 1 -framerate 1 -i ${imageFile} -i ${songFile} -c:v libx265 -c:a copy -shortest -pix_fmt yuv420p ${outputFile}
}

# convertVideoTrack <media file> <width> <fps> <crf> <output file>
function convertVideoTrackCrf {
    if [ "$#" -ne 5 ]; then
        echo 'convertVideoTrackCrf <media file> <width> <fps> <crf> <output file>'
        return
    fi

    local mediaFile="$1"
    local width="$2"
    local fps="$3"
    local crf="$4"
    local outputFile="$5"

    # TODO: make this configurable: with or without preserving audio
    echo "ffmpeg -i ${mediaFile} -map 0:v -c:v libx265 -crf ${crf} -vf scale=-1:${width}, fps=${fps} ${outputFile}"
    ffmpeg -i "${mediaFile}" -acodec copy -c:v libx265 -crf ${crf} -vf "scale=-1:${width}, fps=${fps}" "${outputFile}"
}

# convertVideoTrack <media file> <width> <fps> <bitrate> <output file>
function convertVideoTrack {
    if [ "$#" -ne 5 ]; then
        echo 'convertVideoTrack <media file> <width> <fps> <bitrate> <output file>'
        return
    fi

    local mediaFile="$1"
    local width="$2"
    local fps="$3"
    local bitrate="$4"
    local outputFile="$5"

    echo "ffmpeg -i ${mediaFile} -map 0:v -c:v libx265 -b:v ${bitrate} -vf scale=-1:${width}, fps=${fps} -preset veryfast ${outputFile}"
    ffmpeg -i "${mediaFile}" -map 0:v -c:v libx265 -b:v "${bitrate}" -vf "scale=-1:${width}, fps=${fps}" -preset veryfast "${outputFile}"
}

function moveLrfFiles {
	local sourceDir="${1:-$(pwd)}"
	local destDir="lrf"
	local filePattern="*.LRF.mp4"
	local fileCount=0

    # If no files, exit
    local numLrfFiles=$(find . -type f -name "${filePattern}" | wc -c)

	echo "Number of .txt files: ${numLrfFiles}"

    if [ "${numLrfFiles}" -eq 0 ]; then
        echo "No .LRF files found in [${sourceDir}]"
        return
    fi

	local file

	for file in "${sourceDir}/${filePattern}"; do
		if [ -f "${file}" ]; then
			#mv -v "${file}" "${destDir}"
			echo "moving file ${file}"
			fileCount=$((fileCount+1))
		fi
	done
	echo "Moved [${fileCount}] LRF files from [${sourceDir}] to [${destDir}]"
}




# ------

function saveLastPlayedFunc {
	local favDir="${MARS}/favs"
	mkdir -pv "${favDir}"
	ln -sv "${LAST_PLAYED}" "${favDir}"
}

function replayFunc {
	mpv --mute --loop "${LAST_PLAYED}" &
}

# vidHereFunc <dir>
function vidHereNonRepeatingFunc {
	local dir="$1"
    local listFile="${MARS}/list.txt"
	#local vid="$(find ${dir} -type f -size +1k -a \( -name 'Flash*' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -name 'com.google.chrome*' \) | shuf -n 1)"
	local vid="$(find ${dir} -not -iname '*.jpg' -type f -size +100k | sort -R | head -n 1)"
	# local vid="$(find ${dir} -not -iname '*.jpg' -type f -size +100k | shuf -n 1)"

	while grep -q "${vid}" "${listFile}"; do
		echo "Video ${vid} already played"
		#vid="$(find ${dir} -type f -size +1k -a \(-iname '*.mov' -o -iname '*.tmp' -name '_Flash*' -o -iname '*.webp' -o -iname '*.gif' -o -name 'f_*' -o -iname '*.avi' -o -name 'Flash*' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -name 'com.google.chrome*' \) | shuf -n 1)"
		vid="$(find ${dir} -not -iname '*.jpg' -type f -size +100k | sort -R | head -n 1)"
	done


	ffprobe "${vid}"

	local last=$(realpath "${vid}")
	export LAST_PLAYED="${last}"

	mpv --mute --loop "${vid}" &
	ls -lh "${vid}"
	echo "\"${vid}\""

	echo "${vid}" >> "${listFile}"
}

# combineVideoAudio <video file> <audio file> <output file> <volume>(5%) <audio bitrate>(96k)
function combineVideoAudioFunc {
    if [ "$#" -lt 3 ]; then
        echo 'combineVideoAudio <video file> <audio file> <output file> <volume>(5%) <audio bitrate>(96k)'
        return
    fi

    local videoFile="$1"
    local audioFile="$2"
    local outputFile="$3"
    local volume="${4:-0.05}"
    local audioBitrate="${5:-96}"

    ffmpeg -i "${videoFile}" -i "${audioFile}" \
        -filter_complex "[1:a]volume=${volume},aloop=loop=-1:size=2e+09[song]; [0:a][song]amix=inputs=2:duration=first[mixedAudio]" \
        -map 0:v -map "[mixedAudio]" \
        -c:v copy -c:a aac -b:a "${audioBitrate}k" \
        "${outputFile}"
}



function generatePgpKey {
	# Generate key with RSA 4096 bits and no expiry for Proton Mail
	gpg --expert \
		--full-generate-key \
		--keyid-format long \
		--with-colons \
		--command-fd 0 << EOF
9
1
4096
0
y
EOF
	# Export public key to import into Proton Mail
	gpg --armor --export
}

# vidHereFunc
function vidHereFunc {
	local dir="${MARS}/favs"
	#local vid="$(find ${dir} -type f -size +1k -a \( -name 'Flash*' -o -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -name 'com.google.chrome*' \) | shuf -n 1)"
	local vid="$(find ${dir} -type l | sort -R | head -n 1)"

	ffprobe "${vid}"

	mpv --mute --loop "${vid}" &
	ls -lh "${vid}"
	echo "\"${vid}\""
}


# Aliases -------------------------------

# now taken care of upon Cursor installation
#alias code='open -b com.microsoft.vscode'

alias S="source ${HOME}/ned-mac.sh"
# alias S='source ~/.zprofile'

# alias R='code(~/dev/repos/bash-settings)'
# alias R='open -b com.microsoft.vscode ~/dev/repos/bash-settings'
alias R='code ~/dev/repos/bash-settings'

alias ll='ls -alF'
alias la='ls -A'
alias Y='~/dev/repos/yt-dlp/dist/yt-dlp_macos_arm64 --no-mtime'
alias python='python3'
alias spot='pushd ~/dev/repos/onthespot/src; python -m onthespot; popd'
alias I="open -a 'Google Chrome' --new --args --incognito"

# Linux
#alias l='ls -a --classify --human-readable -l --reverse -t'

# Mac
alias l='ls -alFGhrt'
alias history='history -500'
alias networkUp='watch -n 3 ping -c 1 google.com'
alias publicIp='curl ifconfig.me'
alias localIp='ipconfig getifaddr en0'
alias t='my_traceroute'
alias c='curl --connect-timeout 5 --verbose astro.com'

# Git --------
alias ga='git add'
alias gd='git diff'
alias gs='git status'
alias gf='git fetch'
alias gl='git log --oneline'

# Editing -------
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'
alias Yold='youtube-dl --no-overwrites --no-mtime'
alias extractAudio='extractAudioFunc'
alias extractVideo='extractVideoFunc'
alias shrinkAudio='shrinkAudioFunc'
alias imageSong='imageSongFunc'
alias moveLrfFiles='moveLrfFiles'
alias convertVideoTrack='convertVideoTrack'
alias convertVideoTrackCrf='convertVideoTrackCrf'
alias combineVideoAudio='combineVideoAudioFunc'

alias vidHere='vidHereNonRepeatingFunc'
alias fav='vidHereFunc'
alias replay='replayFunc'
alias saveLastPlayed='saveLastPlayedFunc'

echo
echo "   UPDATED NED-MAC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo 'END ned-mac.sh'
