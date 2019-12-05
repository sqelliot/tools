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

## Source other bash files
source ~/repos/tools/bash/aws/.bashrc


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


function functions() {
  grep -hr "function .*().*{" ${toolsPath} | sort
}

##########################################################
################# Shared git commands ####################
##########################################################
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gpsh='git push'
alias    gadd='git add'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gorigindev='gfo && gdev && gitreset origin/dev'
alias gbragrep="git branch | grep"
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias grebase='gfo && git rebase'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias    fc='gogit fcms-config'
alias    fd='gogit fcms-deployment'
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
alias   mci='mvn clean install'
alias  mciskip='mci -Dmaven.test.skip=true'

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

function gpshodefault() {
  if [[ $(git_branch) == "dev" ]]; then
    echo "Error: cannot push to dev"
    return 0
  fi
  gpsho -u $(git_branch) $@
}

function gitreset() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: gitreset <remote branch>"
    return 0
  fi
  branch=$1
  gfo && git reset --hard ${branch}
}

# Create a new branch off remote origin/dev
function gitfeaturebranch() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: git dev <jira number>[-<info>]"
    return 0
  fi
  
  name=$1
  gfo
  git checkout -b feature/dev/${name} origin/dev
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
  echo $(git_branch ) | grep -oE "(FCMS|FES|WOOD).*" | awk -F'[-]' '{printf "%s-%s", $1,$2}'
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
