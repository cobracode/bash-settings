#!/bin/env zsh
setopt errexit pipefail nounset
set -xv

readonly start=${EPOCHREALTIME:=0}

print -- '------- createRamdisk.zsh START -------'

trap 'printf "Runtime: %.3f ms\n" $(((EPOCHREALTIME - start) * 1000))' EXIT INT TERM

# optional: better error messages
trap 'print -u2 "Error on line $LINENO"; exit 1' ERR


(( $# == 1 )) || {
    print -u2 -- 'usage: <MB>'
    return 1
}

readonly mb="$1"


readonly SAFARI_CACHE="${HOME}/Library/Containers/com.apple.Safari/Data/Library/Caches"
readonly SAFARI_TMPDIR="${TMPDIR}../C/com.apple.Safari"


[[ "$mb" != <-> ]] || (( "$mb" < 100 )) && {
    print -u2 -- 'ERROR: Size must be 100 MB minimum'
    return 1
}

readonly ramdisk="${2:=ramdisk}"
readonly ramdiskVolume="/Volumes/${ramdisk}"


# helper functions
getRamdiskSectors() {
    (( $# == 1 )) || {
        print -u2 -- 'usage: <MB>'
        return 1
    }

    local -r mb="$1"
    print $(( $mb * 2048 ))
}

# create disk
createRamdisk() {
    if [[ -d "${ramdiskVolume}" ]]; then
        print -- "WARNING: Ramdisk volume [${ramdiskVolume}] already exists; skipping creation."
        return 0
    fi

    print -- "Creating [${mb}] MB ramdisk at [${ramdisk}]"

    local -r numSectors=$(getRamdiskSectors "${mb}")
    print -- "Will use [${numSectors}] sectors"

    local ram_drive
    read -r ram_drive <<< "$(hdiutil attach -nomount "ram://${numSectors}")"
    print -- "Created drive on [${ram_drive}]"

    local -r formatResult=$(diskutil erasevolume APFS "${ramdisk}" "${ram_drive}")
    print -- "[${formatResult}]"

    print
    print -- "Done creating ramdisk"
    print
}


# setup folders
setupFolders() {
    local -r folders=(
        'brave-cache'
        'google-earth-cache'
        'spotify-cache'
        'omlx'
    )

    print
    print -- 'Setting up ramdisk folders:'
    
    for folder in "${folders[@]}"; do
        local folderPath="${ramdiskVolume}/${folder}"
        mkdir -vp "${folderPath}"
        chmod -v 1777 "${folderPath}"
    done

    print
    print -- 'Done setting up folders'
    print
}

createRamdisk
setupFolders

print -- '------- createRamdisk.zsh END -------'
