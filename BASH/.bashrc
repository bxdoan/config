# =============================================================================
# alias usefull command
# =============================================================================
alias upd_bash='source ~/.bashrc'
alias grepd='grep -r -s -I --color'
alias emacsnw='emacs -nw'
alias lsa='ls -a'
alias ll='ls -alF'

export repo='/home/$USER/repo'
export config='/home/$USER/repo/config'
export source='/home/$USER/repo/source'
export docker_compose='/home/$USER/repo/docker-compose-services'

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
alias grb='git rebase'
alias dockerps='sudo chmod 666 /var/run/docker.sock && docker ps'
alias psql='docker exec -it gc_postgres_dn psql -U postgres'

export PIPENV_VENV_IN_PROJECT=1

export PATH="/home/doabui/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# =============================================================================
# Alias giga
# =============================================================================
export aqa='34.87.182.148'

alias sshaqa='ssh doan@34.87.182.148'
alias goatlas='cd ~/giga/atlas && source .venv/bin/activate && source .env'
alias goatlas2='cd ~/giga/atlas2 && source .venv/bin/activate && source .env'
alias goatlas3='cd ~/giga/atlas3 && source .venv/bin/activate && source .env'
alias restore_schem='~/giga/devops/replicate-schema/restore-schema-2-docker-psql.sh'
alias cpsetip='mkdir tmp; cp ~/repo/config/bin/setipaddress.sh ~/repo/config/bin/setup_ipaddress.py tmp/'
alias setip='./tmp/setipaddress.sh'

# =============================================================================
# add source to verify the command
# =============================================================================
source ~/Repo/config/BASH/bash_func.sh
add_PATH ~/
change_PS1
