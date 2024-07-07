echo 'BEGIN ned-mac.sh'

# Set variables -------------------------

# original prompt:
# PROMPT='%n@%m %1~ %#'
# export PROMPT='%F{green}%n%f@%F{blue}%m%f:%F{cyan}%~%f$ '
export PROMPT='%F{red}%h%f%F{blue}%n%f%?@%F{yellow}%~%f|%w|%*%# '


export HISTFILE=/Users/ned/.ned_history
export HISTSIZE=99999
export SAVEHIST=99999
setopt hist_ignore_all_dups

export EBOOKS="/Users/ned/Library/Containers/com.amazon.Lassen/Data/Library/eBooks"


# Functions -----------------------------
# function code {
#     file = $1
#     open -b com.microsoft.vscode ${file}
# }

function my_traceroute {
    local host="${1:-google.com}"
    local maxHops="${2:-5}"
    traceroute -m "${maxHops}" -q 1 -v "${host}" 28
}

# extractAudio <media file> <output file>
function extractAudioFunc {
	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -map 0:a -c:a copy "${outputFile}"
}

# extractVideo <media file> <output file>
function extractVideoFunc {
	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -map 0:v -c:v copy "${outputFile}"
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


# Aliases -------------------------------

alias code='open -b com.microsoft.vscode'
alias S='source /Users/ned/ned-mac.sh'
# alias S='source ~/.zprofile'
# alias R='code(~/dev/repos/bash-settings)'
alias R='open -b com.microsoft.vscode ~/dev/repos/bash-settings'
alias ll='ls -alF'
alias la='ls -A'
alias Y='~/dev/repos/yt-dlp/dist/yt-dlp_macos_arm64 --no-mtime'
alias python='python3'
alias spot='pushd ~/dev/repos/onthespot/src; python -m onthespot; popd'

# Linux
#alias l='ls -a --classify --human-readable -l --reverse -t'

# Mac
alias l='ls -alFGhrt'
alias history='history -500'
alias networkUp='watch -n 3 ping -c 1 google.com'
alias publicIp='curl ifconfig.me'
alias localIp='ipconfig getifaddr en0'
alias t='my_traceroute'

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
alias moveLrfFiles='moveLrfFiles'


echo
echo "   UPDATED NED-MAC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo 'END ned-mac.sh'