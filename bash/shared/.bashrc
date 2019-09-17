# self-references
reposPath=~/repos/
toolsPath=${reposPath}/tools/
sharedBash=${toolsPath}/bash/shared/.bashrc
localBash=${toolsPath}/bash/local/.bashrc
updateFileMessage=$'

#########################################

               BASH UPDATED

#########################################

'

function sourceBash() {
  source $1 ; echo "$updateFileMessage"
}
function editSharedBash() {
  vim ${sharedBash}; sourceBash ${sharedBash}
}
function editLocalBash() {
  vim ${localBash}; sourceBash ${localBash}
}

# go to tools
alias tools="gogit tools"

##########################################################
################# Shared git commands ####################
##########################################################
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gpshodefault='gpsho $(gbracurr)'
alias gpsh='git push'
alias    gadd='git add'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gorigindev='gfo; gdev; gupdate'
alias  gbracurr="git branch | grep \* | cut -d ' ' -f2"
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias grebase='gfo; git rebase'
alias  greset=' gfo; git reset --hard origin/$(gbracurr)'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias gupdate='gfo; git rebase origin/$(gbracurr)'
alias    fc='gogit fcms-config'
alias    fd='gogit fcms-deployment'
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
alias   mci='mvn clean install'
alias  mciskip='mci -Dmaven.test.skip=true'

function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  cd ${reposPath}/$1
}

function gitclone() {
  proj=$1
  repo=$2

  git clone ssh://git@git.goldlnk.rootlnka.net/$1/$2
}

function gitdevbranch() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: git dev <jira number>[-<info>]"
    return 0
  fi
  
  name=$1
  git checkout -b feature/dev/${name} origin/dev
}

function gitDR() {

  if [ "$#" -ne 2 ]; then
    echo "Usage: gitDR <jira number> <release number>"
    return 0
  fi

  branch_suffix=$1
  release_num=$2
  
  gfo
  git branch drfix/dev/${branch_suffix} origin/dev
  gch -b drfix/release/${release_num}/${branch_suffix} origin/release/${release_num}
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

function git_jira() {
  echo $(gbracurr ) | grep -o "\(FCMS\|FES\|WOOD\).*" | awk -F'[-]' '{printf "%s-%s", $1,$2}'
}

function gjiracommit(){
  if [ "$#" -lt 1  ]; then
    echo "Usage: gjiracommit <msg>"
    return 0
  fi
  msg=$@
  git commit -m "$(git_jira): ${msg}"
}
