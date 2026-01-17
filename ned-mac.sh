echo 'BEGIN ned-mac.sh'

# Set variables ---------------------------

export DEV_PATH="${HOME}/dev"
export REPO_PATH="${DEV_PATH}/repos"
export BASH_SETTINGS_PATH="${REPO_PATH}/bash-settings"
export NED_MAC_PATH="${BASH_SETTINGS_PATH}/ned-mac.sh"
export HOSTS_PATH='/etc/hosts'

export MARS='UNDEFINED'


# Homebrew variables
eval "$(/opt/homebrew/bin/brew shellenv)"

# original prompt:
# PROMPT='%n@%m %1~ %#'
# export PROMPT='%F{green}%n%f@%F{blue}%m%f:%F{cyan}%~%f$ '
export PROMPT='%F{red}%h%f%F{blue}%n%f%?@%F{yellow}%~%f|%w|%*%# '

# Update PATH
#export PATH="${PATH}:${HOME}/dev/platform-tools:${HOME}/Library/Python/3.9/bin"
export PATH="${PATH}:${HOME}/dev/bin/ffmpeg"


# Unused for now 20250426
#export HISTFILE=/Users/ned/.ned_history

export HISTSIZE=99999
export SAVEHIST=99999
setopt hist_ignore_all_dups

export EBOOKS="${HOME}/Library/Containers/com.amazon.Lassen/Data/Library/eBooks"

# export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"



# Functions -----------------------------
# function code {
#     file = $1
#     open -b com.microsoft.vscode ${file}
# }

function printCommandHeader {
    local cmd="${1:-'NO COMMAND SPECIFIED'}"

    echo '---------------'
    echo 'Running command'
    echo '---------------'
    echo
    echo "${cmd}"
    echo
    echo '---------------'
}



function my_traceroute {
    local host="${1:-google.com}"
    local maxHops="${2:-3}"
    echo 'my_traceroute <maxhops:3> <host:google.com>'

    local cmd="traceroute -m ${maxHops} -q 1 -v ${host} 28"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

# shrinkAudioFunc <media file>
function shrinkAudioFunc {
    if [ "$#" -ne 1 ]; then
        echo 'shrinkAudioFunc <media file>'
        return
    fi

    local mediaFile="$1"
    local cmd="ffmpeg -i ${mediaFile} -ac 1 -c:a libopus -b:a 6k -bandwidth narrowband -application voip -vbr on -frame_duration 60 ${mediaFile}-shrunk.opus"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}


# extractAudio <media file> <output file>
function extractAudioFunc {
    if [ "$#" -ne 2 ]; then
        echo 'extractAudio <media file> <output file>'
        return
    fi

    local mediaFile="$1"
    local outputFile="$2"
    
    local cmd="ffmpeg -i ${mediaFile} -map 0:a -c:a copy ${outputFile}"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

# extractVideo <media file> <output file>
function extractVideoFunc {
    if [ "$#" -ne 2 ]; then
        echo 'extractVideo <media file> <output file>'
        return
    fi

    local mediaFile="$1"
    local outputFile="$2"
    
    local cmd="ffmpeg -i ${mediaFile} -map 0:v -c:v copy ${outputFile}"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

function imageSongFunc {
    if [ "$#" -ne 3 ]; then
        echo 'imageSongFunc <image file> <song file> <output file>'
        return
    fi

    local imageFile="$1"
    local songFile="$2"
    local outputFile="$3"

    local cmd="ffmpeg -loop 1 -framerate 1 -i ${imageFile} -i ${songFile} -c:v libx265 -c:a copy -shortest -pix_fmt yuv420p ${outputFile}"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

function cutVideoFunc {
    if [ "$#" -ne 4 ]; then
        echo 'cutVideoFunc <input file> <start hh:mm:ss> <end hh:mm:ss> <output file>'
        return
    fi

    local inputFile="$1"
    local start="$2"
    local end="$3"
    local outputFile="$4"

    local cmd="ffmpeg -i ${inputFile} -ss ${start} -to ${end} -c copy ${outputFile}"

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

function convertVideoTrackCrf {
    if [ "$#" -lt 5 ]; then
        echo 'convertVideoTrackCrf <media file> <height> <fps> <crf> <output file> <duration>'
        return
    fi

    local mediaFile="$1"
    local height="$2"
    local fps="$3"
    local crf="$4"
    local outputFile="$5"
    local duration="$6"
    local cmd=''

    if [ -n "${duration}" ]; then
        cmd="ffmpeg -i ${mediaFile} -to ${duration} -acodec copy -c:v libx265 -crf ${crf} -vf 'scale=-2:${height}, fps=${fps}' ${outputFile}"
    else
        cmd="ffmpeg -i ${mediaFile} -acodec copy -c:v libx265 -crf ${crf} -vf 'scale=-2:${height}, fps=${fps}' ${outputFile}"
    fi

    printCommandHeader "${cmd}"
    eval "${cmd}"
}

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

    echo "ffmpeg -i ${mediaFile} -map 0:v -c:v libx265 -b:v ${bitrate} -vf scale=-2:${width}, fps=${fps} -preset veryfast ${outputFile}"
    ffmpeg -i "${mediaFile}" -map 0:v -c:v libx265 -b:v "${bitrate}" -vf "scale=-2:${width}, fps=${fps}" -preset veryfast "${outputFile}"
}


# Run ffmpeg -h encoder=hevc_videotoolbox to list options specific to hevc_videotoolbox.
# Use -b:v to control quality in terms of target bitrate.
# Use -q:v for quality control between 1 and 100 (higher is better).
# -crf is only for libx264, libx265, libvpx, and libvpx-vp9. It will be ignored by other encoders. It will also ignore -preset.
# hevc_videotoolbox isn't as good as libx265, but it is fast

# convertVideoTrackFunc - Universal video conversion with named parameters
# Required: --mediaFile, --outputFile
# Optional: --height, --width, --fps, --crf, --bitrate, --duration, --preset, --copyAudio, --vcodec
# Usage: convertVideoTrackFunc --mediaFile=input.mp4 --outputFile=output.mp4 --height=720 --fps=30 --crf=23
function convertVideoFunc {
    local mediaFile=""
    local outputFile=""
    local height=720
    local width=""
    local fps=24
    local crf=40
    local bitrate=""
    local duration=
    local preset='medium'
    local copyAudio=false
    local useVideoToolboxEncoder=false
    local videoToolboxQuality=50
    local videoCodec='libx265'
    local previewOnly=false

    # Define valid options array for reuse in help message
    local validOptions=(
        "height"
        "width"
        "fps"
        "crf"
        "bitrate"
        "duration"
        "preset"
        "copyAudio"
        "useVideoToolbox"
        "preview"
    )

    # Helper function to generate options help text
    local generateOptionsHelp() {
        local opts=""
        for opt in "${validOptions[@]}"; do
            if [ -n "${opts}" ]; then
                opts="${opts}, --${opt}"
            else
                opts="--${opt}"
            fi
        done
        echo "${opts}"
    }

    # Parse named parameters
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --mediaFile=*)
                mediaFile="${1#*=}"
                shift
                ;;
            --mediaFile)
                mediaFile="$2"
                shift 2
                ;;
            --preview)
                previewOnly=true
                shift
                ;;
            --outputFile=*)
                outputFile="${1#*=}"
                shift
                ;;
            --outputFile)
                outputFile="$2"
                shift 2
                ;;
            --height=*)
                height="${1#*=}"
                shift
                ;;
            --height)
                height="$2"
                shift 2
                ;;
            --width=*)
                width="${1#*=}"
                shift
                ;;
            --width)
                width="$2"
                shift 2
                ;;
            --fps=*)
                fps="${1#*=}"
                shift
                ;;
            --fps)
                fps="$2"
                shift 2
                ;;
            --crf=*)
                crf="${1#*=}"
                shift
                ;;
            --crf)
                crf="$2"
                shift 2
                ;;
            --bitrate=*)
                bitrate="${1#*=}"
                shift
                ;;
            --bitrate)
                bitrate="$2"
                shift 2
                ;;
            --duration=*)
                duration="${1#*=}"
                shift
                ;;
            --duration)
                duration="$2"
                shift 2
                ;;
            --preset=*)
                preset="${1#*=}"
                shift
                ;;
            --preset)
                preset="$2"
                shift 2
                ;;
            --copyAudio)
                copyAudio=true
                shift
                ;;
            --useVideoToolbox)
                useVideoToolboxEncoder=true
                videoCodec='hevc_videotoolbox'
                shift
                ;;
            --useVideoToolbox,*)
                useVideoToolboxEncoder=true
                videoCodec='hevc_videotoolbox'
                videoToolboxQuality="${1#*,}"
                shift
                ;;
            *)
                echo "Unknown parameter: $1"
                echo "Usage: convertVideoTrackOptions --mediaFile=<file> --outputFile=<file> [options]"
                echo "Options: $(generateOptionsHelp)"
                return 1
                ;;
        esac
    done

    # Validate required parameters
    if [ -z "${mediaFile}" ] || [ -z "${outputFile}" ]; then
        echo "Error: --mediaFile and --outputFile are required"
        echo "Usage: convertVideoTrackOptions --mediaFile=<file> --outputFile=<file> [options]"
        return 1
    fi

    # Build ffmpeg command
    local cmd="ffmpeg -i \"${mediaFile}\""

    # Add duration if specified
    if [ -n "${duration}" ]; then
        cmd="${cmd} -to \"${duration}\""
    fi

    # Add audio handling
    if [ "${copyAudio}" = "true" ]; then
        cmd="${cmd} -acodec copy"
    else
        # Add video mapping
        cmd="${cmd} -map 0:v"
    fi

    # Add video codec
    cmd="${cmd} -c:v ${videoCodec}"

    # VideoToolbox encoder has its own quality mechanism
    if [ "${useVideoToolboxEncoder}" = true ]; then
        cmd="${cmd} -q:v ${videoToolboxQuality}"
    # Add quality control (CRF takes precedence over bitrate)
    elif [ -n "${crf}" ]; then
        cmd="${cmd} -crf ${crf}"
    elif [ -n "${bitrate}" ]; then
        cmd="${cmd} -b:v \"${bitrate}\""
    fi

    # Build video filter
    local vfParts=""
    
    # Add scaling (width takes precedence over height if both provided)
    if [ -n "${width}" ]; then
        vfParts="scale=${width}:-2"
    elif [ -n "${height}" ]; then
        vfParts="scale=-2:${height}"
    fi

    # Add fps if specified
    if [ -n "${fps}" ]; then
        if [ -n "${vfParts}" ]; then
            vfParts="${vfParts}, fps=${fps}"
        else
            vfParts="fps=${fps}"
        fi
    fi

    # Add video filter if any parts exist
    if [ -n "${vfParts}" ]; then
        cmd="${cmd} -vf \"${vfParts}\""
    fi

    # Add preset
    if [ -n "${preset}" ]; then
        cmd="${cmd} -preset ${preset}"
    fi

    # Add output file
    cmd="${cmd} \"${outputFile}\""

    # Print and execute command
    echo "${cmd}"

    if [ "${previewOnly}" = false ]; then
        #echo 'RUNNING COMMAND!'
        eval "${cmd}"
    fi
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

function previewRandomFileFunc {
    local dir="${1:-$(pwd)}"

    local file=$(find "${dir}" | shuf -n 1)
    qlmanage -p "${file}"
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



#  AWS

function awsIdentityFunc {
    #local audioBitrate="${5:-96}"
    local profile="${1:-default}"
    echo "profile: $profile"
    aws sts get-caller-identity --profile "${profile}"
}


# Aliases -------------------------------

# AWS
# alias aid='aws sts get-caller-identity'
alias aid='awsIdentityFunc'




# now taken care of upon Cursor installation
#alias code='open -b com.microsoft.vscode'

alias S="source ${NED_MAC_PATH}"
# alias S='source ~/.zprofile'

# alias R='code(~/dev/repos/bash-settings)'
# alias R='open -b com.microsoft.vscode ~/dev/repos/bash-settings'
alias R="code ${BASH_SETTINGS_PATH}"

alias ll='ls -alF'
alias la='ls -A'
#alias Y='~/dev/repos/yt-dlp/dist/yt-dlp_macos_arm64 --no-mtime'
alias Y='yt-dlp --no-mtime'
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
alias c='curl --connect-timeout 5 --verbose astro.com'
alias brewSpace='du -sch $(brew --cellar)/*/* | sed "s|$(brew --cellar)/\([^/]*\)/.*|\1|" | sort -k1h'
alias crypt="pushd ${REPO_PATH}/crypt; source venv/bin/activate; python main.py & deactivate; popd"
alias priv='open -a "Google Chrome" --args --incognito --enable-logging --v=1'
alias previewRandomFile='previewRandomFileFunc'
alias flushDns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias openHosts="sudo mv -v ${HOSTS_PATH} ${HOSTS_PATH}-open"
alias closeHosts="sudo mv -v ${HOSTS_PATH}-open ${HOSTS_PATH}"
alias checkHosts="head -n 50 ${HOSTS_PATH}"
alias grepF='grep -F'

# Git --------
alias ga='git add'
alias gb='git branch -vvv'
alias gba='git branch --all -vvv'
alias gd='git diff'
alias gs='git status'
alias gf='git fetch --prune'
alias gl='git log --oneline --graph'
alias gsp='git stash save && git pull && git stash pop'
alias gp='git pull'

# Editing -------
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'
alias Yold='youtube-dl --no-overwrites --no-mtime'
alias extractAudio='extractAudioFunc'
alias extractVideo='extractVideoFunc'
alias shrinkAudio='shrinkAudioFunc'
alias imageSong='imageSongFunc'
alias moveLrfFiles='moveLrfFiles'
alias cutVideo='cutVideoFunc'
alias convertVideoTrack='convertVideoTrack'
alias convertVideoTrackCrf='convertVideoTrackCrf'
alias convertVideo='convertVideoFunc'
alias combineVideoAudio='combineVideoAudioFunc'

## ffmpeg ------
alias listCaptureDevices='ffmpeg -f avfoundation -list_devices true -i ""'

alias vidHere='vidHereNonRepeatingFunc'
alias fav='vidHereFunc'
alias replay='replayFunc'
alias saveLastPlayed='saveLastPlayedFunc'

echo
echo "   UPDATED NED-MAC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo "END ${NED_MAC_PATH}"
