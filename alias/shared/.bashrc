
# self-source
toolsPath=~/tools/
sharedBash='/tools/alias/shared/.bashrc'
alias sourceSharedBash='source ~/${sharedBash}'
alias editSharedBash='vim ~/${sharedBash}; sourceSharedBash'

## This does not work
#function tools(){
#  git_tool=--git-dir=${toolsPath}
#
#  echo "==========================================="
#  echo "tools: $@ ${git_tool}"
#  echo "==========================================="
#  echo;echo
#  eval '"$@" ${git_tool}'
#}

# Shared git commands
alias gpllo='git pull origin'
alias gpll='git pull'
alias gpsho='git push origin'
alias gpsh='git push'
alias gogit='cd ~/repos/'
alias    gadd='git add'
alias    gbra='git branch'
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gfo='git fetch origin -p'
alias    glog='git log'     
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias    fc='cd ~/repos/fcms-config'
alias    fd='cd ~/repos/fcms-deployment'

function gitnew() {
  git checkout -b $1 origin/dev
}
