
# self-source
toolsPath=~/tools/
sharedBash='/tools/bash/shared/.bashrc'
localBash='~/.bashrc'
updateFileMessage=$'

#########################################

               BASH UPDATED

#########################################

'

alias sourceSharedBash='source ~/${sharedBash} && echo \"$updateFileMessage\"'
alias editSharedBash='vim ~/${sharedBash}; sourceSharedBash'
alias editLocalBash='vim ${localBash}; source ${localBash}'

alias tools='cd ~/tools/'

# Random junk for now
alias grep='grep --color'

# Shared git commands
alias gpllo='git pull origin'
alias gpll='git pull'
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gpshodefault='gpsho $(gcurrbra)'
alias gpsh='git push'
alias    gadd='git add'
alias    gbra='git branch'
alias  gcurrbra="git branch | grep \* | cut -d ' ' -f2"
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias  gtfo='gfo'
alias    glog='git log'     
alias  greset='git stash; gfo; git reset --hard'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias gupdate='gfo; git rebase'
alias    fc='cd ~/repos/fcms-config'
alias    fd='cd ~/repos/fcms-deployment'
alias   mci='mvn clean install'
alias  mciskip='mci -Dmaven.test.skip=true'

function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  cd ~/repos/$1
}

function gitclone() {
  proj=$1
  repo=$2

  git clone ssh://git@git.goldlnk.rootlnka.net/$1/$2
}


function goup() {
  num=$1

  for i in $(seq 1 ${num})
  do
    #echo "Went up ${i} dirs"
    pwd
    cd ..
  done
}
