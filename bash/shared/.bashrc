# self-references
reposPath=~/repos/
if [ $(hostname) == "GLDLBAE496014" ]; then
  reposPath=/c/dev/repos/
fi
toolsPath=${reposPath}/tools/
sharedBash=${toolsPath}/bash/shared/.bashrc
localBash=${toolsPath}/bash/local/.bashrc
awsBash=${toolsPath}/bash/aws/.bashrc
updateFileMessage=$'

#########################################

               BASH UPDATED

#########################################

'

######################
## tools management ##
######################

function sourceBash() {
  echo "Sourcing $1..."
  source $1 ; echo "$updateFileMessage"
}

## Source other bash files
source ${localBash}
source ${awsBash}

function editSharedBash() {
  vim ${sharedBash}; sourceBash ${sharedBash}
}
function editLocalBash() {
  vim ${localBash}; sourceBash ${localBash}
}

function editAwsBash() {
  vim ${awsBash}; sourceBash ${awsBash}
}

# go to tools
alias tools="gogit tools"


function functions() {
  grep -hr "function .*().*{" ${toolsPath} | sort
}

function updatetools() {
  bash -lic "tools && grebase && sourceBash $sharedBash"
}

function toolssta() {
  bash -lic "tools && git status"
}


function toolsgdiff() {
  bash -lic "tools && git diff"
}
function toolsgadd() {
  bash -lic "tools && git add ."
}

function toolsgcom() {
  bash -lic "tools && gcom '$@'"
}

function toolsgpshodefault() {
  bash -lic "tools && git push origin master"
}

## shell ##
#################################################
alias ll='ls -l'

##########################################################
################# Shared git commands ####################
##########################################################
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gpsh='git push'
alias    gadd='git add'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gmaster='git checkout master'
alias gbragrep="git branch | grep"
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias grebase='gfo && git rebase'
alias grebasedefault='gfo && git rebase origin/$(gitdefaultbranch)'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias gdiff='git diff'
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
alias   mci='mvn clean install'
alias  mciskip='mci -Dmaven.test.skip=true'

export MICL='mvn install -P copy-artifacts -Duser.top=~/repos/conlib/top'
alias micl='echo $MICL; bash ${MICL}'

##### Gradle commands ##### 
alias gradlefast='${reposPath}/fast/gradlew'


function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  cd ${reposPath}/$1
}

function git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

function gitclone() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: gitclone <project> <repo>"
    return 0
  fi
  proj=$1
  repo=$2

  git clone ssh://git@git.goldlnk.rootlnka.net/$1/$2
}


function gitcloneenforma() {
  base_url=https://git.space.enforma.io
  echo "Cloning ${base_url}/${1} ..."
  git clone ${base_url}/$1
}

function gpshodefault() {
  if [[ $(git_branch) == "dev" ]] || [[ $(git_branch) == "master" ]]; then
    echo "Error: commits cannot be directly pushed to this branch"
    return 0
  fi
  gpsho -u $(git_branch) $@
}

function gitreset() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: gitreset <branch>"
    return 0
  fi
  branch=$1
  gfo && git reset --hard ${branch}
}

# Create a new branch off remote origin/dev
function gitfeaturebranch() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: gitfeaturebranch <jira number>[-<info>]"
    return 0
  fi
  
  name=$1
  target_branch=$(gitdefaultbranch)
  gfo
  git checkout -b feature/$(gitdefaultbranch)/${name} origin/$target_branch
}

# Create the two branches necessary for a DR
function gitDr() {

  if [ "$#" -ne 2 ]; then
    echo "Usage: gitDR <jira number> <release number>"
    return 0
  fi

  branch_suffix=$1
  release_num=$2
  
  gfo
  git branch drfix/release/${release_num}/${branch_suffix} origin/release/${release_num}
  gch -b drfix/dev/${branch_suffix} origin/dev
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

# Grabs only the jira number from the current git branch
# Example: drfix/dev/FCMS-0000-fix -> FCMS-0000
function git_jira_issue() {
  prefixes="(FCMS|FES|WOOD|ECLDEV|CLDEV).*"
  echo $(git_branch ) | grep -oE ${prefixes} | awk -F'[-]' '{printf "%s-%s", $1,$2}'
}

# update a branch
# default to remote if no arg given
function gupdate() {
  if [ "$#" -ne 1 ]; then
    gfo; git rebase origin/$(git_branch)
    return 0
  fi

  gfo; git rebase origin/$1
}

# Commit with message starting with the current jira issue 
function gjiracommit(){
  if [ "$#" -lt 1  ]; then
    echo "Usage: gjiracommit <msg>"
    return 0
  fi
  msg=$@
  git commit -m "$(git_jira_issue): ${msg}"
}

function is_repo_path() {
  path=$(pwd)
  if [[ $path != *"repos"* ]]; then
    return 1
  fi

  return 0
}

function curr_repo_path() {
  path=$(git rev-parse --show-toplevel)
  git_bck_path=${path}/.git/GITGUI_BCK

  echo "$(git_jira_issue): " > $git_bck_path
}

function gitguijira() {
  #if [[ is_repo_path != 0 ]];then
  #  echo "Error: Not a repo path"
  #  return 1
  #fi
  curr_repo_path
  git gui
}

function gchgrep() {
  gch $(gbragrep $1)
}

function gitdefaultbranch() {
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}
#######################
## Utility functions ##
#######################

function goriginmaster() {
  branch=dev
  if [ "$#" == 1 ];then
    branch=$1
  fi 
 
  echo "Reseting to local $branch to remote..."
  gfo
  git checkout $branch
  gitreset origin/$branch
}

function isWholeNumber() {
  re='^[0-9]+$'

  if [ "$#" != 1  ]; then
    echo 1
    return
  fi
  if ! [[ $1 =~ $re ]] ; then
      echo 1
      return
  fi
  echo 0
}

function random_file() {
  gigs=$1
  head -c ${gig}G </dev/urandom > ~/randomFile.txt
}


##########################################################
################ Shared docker commands ##################
##########################################################
alias dpsa='docker ps -a'
