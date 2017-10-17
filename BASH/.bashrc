# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# =============================================================================
# alias usefull command
# =============================================================================
alias upd_bash='source /c/Users/doan.x.bui/.bashrc'
alias grepd='grep -r -s -I --color'

alias lsa='ls -a'
export config='/d/Repo/config/'
export foodcoping='/d/Repo/Foodcoping'

# =============================================================================
# Alias Git
# =============================================================================
alias g='git'
alias ga='git add'
alias gb='git br'
alias gt='git tree'
alias go='git co'
alias gof='git co -f'
alias gi='git commit'
alias gpl='git pull'
alias gplrb='git pull --rebase'
alias giam='git commit --amend'
alias gm='git merge'
alias gcp='git cherry-pick'
alias gps='git push'
alias gh='git hist'
alias gs='git st' 
alias gsu='git st -u'
alias gk='gitk &'
alias gf='git fetch'
alias gr='git reset'

# =============================================================================
# add source to verify the command
# =============================================================================
source /d/Repo/config/BASH/bash_func.sh
add_PATH /d/Repo/
change_PS1