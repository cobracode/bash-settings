echo 'BEGIN ned.sh'

# Set variables -------------------------
HISTSIZE=9999
HISTFILESIZE=9999


# Aliases -------------------------------

alias S='source ~/.zprofile'
alias R='open -b com.microsoft.vscode ~/dev/repos/bash-settings'
alias ll='ls -alF'
alias la='ls -A'

# Linux
#alias l='ls -a --classify --human-readable -l --reverse -t'

# Mac
alias l='ls -alFGhrt'


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


echo
echo "   UPDATED  BASHRC SETTINGS   on $(date +%Y-%m-%d\ %H:%M:%S)"
echo