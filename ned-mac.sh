echo 'BEGIN ned.sh'

# Set variables -------------------------
export HISTSIZE=99999
export HISTFILESIZE=99999

export EBOOKS="/Users/ned/Library/Containers/com.amazon.Lassen/Data/Library/eBooks"


# Functions -----------------------------
# function code {
#     file = $1
#     open -b com.microsoft.vscode ${file}
# }

# extractAudio <media file> <output file>
function extractAudioFunc {
	local mediaFile="$1"
	local outputFile="$2"
	ffmpeg -i "${mediaFile}" -vn -acodec copy "${outputFile}"
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
alias S='source ~/.zprofile'
# alias R='code(~/dev/repos/bash-settings)'
alias R='open -b com.microsoft.vscode ~/dev/repos/bash-settings'
alias ll='ls -alF'
alias la='ls -A'

# Linux
#alias l='ls -a --classify --human-readable -l --reverse -t'

# Mac
alias l='ls -alFGhrt'
alias history='history -500'


# Git --------
alias ga='git add'
alias gd='git diff'
alias gs='git status'
alias gf='git fetch'
alias gl='git log --oneline'

# Editing -------
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'
alias Y='youtube-dl --no-overwrites --no-mtime'
alias extractAudio='extractAudioFunc'
alias moveLrfFiles='moveLrfFiles'


echo
echo "   UPDATED  BASHRC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo