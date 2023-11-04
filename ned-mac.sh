echo 'BEGIN ned.sh'

# Set variables -------------------------
HISTSIZE=9999
HISTFILESIZE=9999


# Aliases -------------------------------

alias S='source ~/.zprofile'
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
alias gl='git log'

# Editing -------
alias ffprobe='ffprobe -hide_banner'
alias ffmpeg='ffmpeg -hide_banner'


echo 'TODO: Add datetime at start, end'

echo 'END ned.sh'