
# self-source
toolsPath=~/tools/
sharedBash='/tools/alias/shared/.bashrc'
localBash='~/.bashrc'
alias sourceSharedBash='source ~/${sharedBash}'
alias editSharedBash='vim ~/${sharedBash}; sourceSharedBash'
alias editLocalBash='vim ${localBash}; source ${localBash}'

alias tools='cd ~/tools/'

# Random junk for now

# Shared git commands
alias gpllo='git pull origin'
alias gpll='git pull'
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gpsh='git push'
alias    gadd='git add'
alias    gbra='git branch'
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias    glog='git log'     
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias gupdate='git stash; gfo; git rebase; git stash pop'
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
