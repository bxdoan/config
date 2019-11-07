# =============================================================================
# alias usefull command
# =============================================================================
alias upd_bash='source ~/.bashrc'
alias grepd='grep -r -s -I --color'
alias emacsnw='emacs -nw'
alias lsa='ls -a'
alias ll='ls -alF'

export repo='/home/$USER/Repo'
export config='/home/$USER/Repo/config'
export source='/home/$USER/Repo/source'



# =============================================================================
# Alias Git
# =============================================================================
alias g='git'
alias ga='git add'
alias gbr='git br'
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
alias grs='git reset'

# =============================================================================
# add source to verify the command
# =============================================================================
source ~/Repo/config/BASH/bash_func.sh
add_PATH ~/
change_PS1
