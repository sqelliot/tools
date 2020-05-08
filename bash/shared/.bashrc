#!/bin/bash

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

function editBashrc() {
  vim ~/.bashrc; source ~/.bashrc
}

function editSharedBash() {
  vim ${sharedBash}; sourceBash ${sharedBash}
}
function editLocalBash() {
  vim ${localBash}; sourceBash ${localBash}
}

function editAwsBash() {
  vim ${awsBash}; sourceBash ${awsBash}
}

function sourceSharedBash() {
  sourceBash ${sharedBash}
}

# go to tools
alias tools="gogit tools"


function functions() {
  grep -hr "function .*().*{" ${toolsPath} | sort
}

function updatetools() {
  bash -lic "tools && grebase" 
  sourceSharedBash
}

function toolssta() {
  tools && git status
}


function toolsgdiff() {
  tools && git diff
}
function toolsgadd() {
  tools && git add .
}

function toolsgcom() {
  tools && gcom '$@'
}

function toolsgpshodefault() {
  tools && git push origin master
}

function toolspush() {
  git push origin master
}

alias conlib='gogit conlib'
alias ecl='gogit ecl'

## shell ##
#################################################
alias ll='ls -l'
function llbs() {
  ll --block-size=$1
}
#function cd () {
#  bash -lic "/bin/cd $1 && ls"
#}

function mytop() {
  if [ "$#" -ge 1 ]; then
    echo "cp $1 $CL_TOP"
    cp $@ $CL_TOP
  fi
  MYTOP='ls -lrst '$CL_TOP
  echo $MYTOP; $MYTOP
  date
}

alias grep='grep --color'

alias dotar='tar -czf'
alias undotar='tar -xzf '
#alias aws='/usr/local/bin/aws --no-verify-ssl'

MYDEVLNK='/project/geoint-2240a/vol/git1/selliott'
function devlnkhome () {
  cd $MYDEVLNK
}


## systemctl
function sysstop() {
  for system in $@
  do
    sudo systemctl stop "$system"
  done
}
alias sysstatus='sudo systemctl status '
alias sysrestart='sudo systemctl restart '

function mountdevlnk() {
  sudo umount /project/NCL_SYS
  sudo umount /project/geoint-2240a

  sudo sshfs -o allow_other,IdentityFile=/home/sean/.ssh/id_rsa selliott@elliott2-lnx7-dev.devlnk.net:/net/geoint-2240a /project/geoint-2240a
  sudo sshfs -o allow_other,IdentityFile=/home/sean/.ssh/id_rsa selliott@elliott2-lnx7-dev.devlnk.net:/project/NCL_SYS /project/NCL_SYS/
}


ANSIBLETOP='-e "{ service_config_info : { staging_directory : /home/users/selliott/repos/conlib/top }}"'
ANSIBLELOCAL='--connection=local'
ANSIBLE_DEV=$ANSIBLETOP' '$ANSIBLELOCAL
APCL='ansible-playbook -vv -bK '
alias apcl='echo $APCL; $APCL'
APCLLOCAL='ansible-playbook -vv -bK --connection=local'
alias apcllocal='echo $APCLLOCAL; $APCLLOCAL'
function apcllocaldev () {
  ansible-playbook -v -bK --connection=local $1 -e "{service_config_info : { staging_directory : $CL_TOP }}"
}

function apclsqslocal() {
  ansible-playbook --connection=local -v -bK $1 -e "{service_config_info : { staging_directory : $CL_TOP }}" -e "{receiver : { sqs : { name : SELLIOTT-FG-CLOUD-POP-COMPLETE }}}" -e "{ site : { modify : { destination : SELLIOTT-FG-SITE-FLOW-CONTROL }}}" -e "{ preprocessing : { sqs : { name : SELLIOTT-PP-FRONT-GATE-COMPLETE }}}"
}

function apcltop() {
  ansible-playbook -v -bK $1 -e "{service_config_info : { staging_directory : $CL_TOP }}" ${@:2}
}

##########################################################
################# Shared git commands ####################
##########################################################
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gd='git diff'
alias gdifforigin='git diff origin/$(git_branch)'
alias gpsh='git push'
alias    gadd='git add'
alias  gpatch='git add --patch'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gmaster='git checkout master'
alias gbragrep="git branch | grep"
alias gbraremotegrep="gfo; git branch -r | grep"
alias   gbram='git branch -m'
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias    gitcommits='git log --graph --abbrev-commit --decorate  --first-parent $(git_branch)'     
alias grebase='gfo && git rebase'
alias grebasedefault='gfo && git rebase origin/$(gitdefaultbranch)'
alias grebaseorigin='gfo && git rebase origin/$(git_branch)'
alias gresetorigin='gfo && git reset --hard origin/$(git_branch)'
alias gresetHEAD='git reset --hard HEAD'
alias grhh='git reset --hard HEAD'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias gd='git diff'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
MCI='mvn clean install'
CL_TOP=~/repos/conlib/top
MVN_CL_CONFIGS='-P copy-artifacts -Duser.top='$CL_TOP
MICL='mvn install '$MVN_CL_CONFIGS
MCICL='mvn clean install '$MVN_CL_CONFIGS
MCISKIP='mvn clean install -Dmaven.test.skip=true '
MCICLSKIP=$MCISKIP' '$MVN_CL_CONFIGS

alias   mci='echo $MCI; $MCI'
alias  mciskip='echo $MCISKIP && $MCISKIP'
alias mvntree='mvn dependency:tree'
alias micl='echo $MICL && $MICL'
alias mcicl='echo $MCICL && $MCICL ; mytop'
alias mciclskip='echo $MCICLSKIP && $MCICLSKIP ; mytop'

##### Gradle commands ##### 
alias gradlefast='${reposPath}/fast/gradlew'


function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  cd ${reposPath}/$1
}

function conlib() {
  gogit conlib/$1
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
personal_branch_name=selliott
function gitfeaturebranch() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: gitfeaturebranch <jira number>[-<info>] [target branch]"
    return 0
  fi
  
  name=$1
  target_branch=$(gitdefaultbranch)

  if [ "$#" = 2 ]; then
    target_branch=$2
  fi

  gfo
  git checkout -b feature/${target_branch}/${personal_branch_name}/${name} origin/$target_branch
}

function gitbugfixbranch() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <jira number>[-<info>] [target branch]"
    return 0
  fi
  
  name=$1
  target_branch=$(gitdefaultbranch)

  if [ "$#" = 2 ]; then
    target_branch=$2
  fi

  gfo
  git checkout -b drfix/${target_branch}/${personal_branch_name}/${name} origin/$target_branch
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
  ls
}

function goto() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <delimiter>"
    return 0
  fi

  delimiter=$1
  new_path=$(pwd | awk -F${delimiter} '{print $1}' )$delimiter

  cd $new_path
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

function gitjiracommitandpush () {
  if [ "$#" -lt 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <msg> <files>"
    return 0
  fi

  msg=$1
  files=${@:2}

  gadd $files &&  gjiracommit $msg && gpshodefault
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
  branch=$(gbragrep  $1)
  if [ ! "$branch" ];then
    gfo
    branch=$(gbraremotegrep  $1)
    if [ ! "$branch" ];then
      echo "No branch found"
      return
    fi
  fi

  printf '%s\n' "$branch"
  branch=$(echo $branch | awk '{print $1}' |  sed -e 's/^origin\///')
  printf '%s\n' "$branch"

  gch $branch
}

function gitdefaultbranch() {
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

function gorigindefault() {
  branch=$(gitdefaultbranch)
  if [ "$#" == 1 ];then
    branch=$1
  fi 

  if [ "$branch" == "master" ];then
    echo "Default branch [$branch] "
    return
  fi
 
  echo "Checking out $branch and reseting to remote..."
  gfo -p
  git checkout $branch
  gitreset origin/$branch
}


function eclssh(){
  ssh ecl-corefulltest${1}-lnx7-dev.devlnk.net
}

#######################
## Utility functions ##
#######################

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

function pathjump () {
  dest_dir=$1
  _pwd=$(pwd)
  dest_path=${_pwd%${dest_dir}*}
  dest_path=${dest_path}/${dest_dir}
  cd $dest_path
}

function searchsystemctl() {
  sudo systemctl | grep -i -E "$1" | awk '{print $1}'
}
#alias newestfile="ll -rst | tail -n 1 | awk '{print $NF}'"
function newestfile() {
  ll -rst | tail -n 1 | awk '{print $NF}'
}

function findname() {
  find . -name $@
}

##########################################################
################ Shared docker commands ##################
##########################################################
alias dpsa='docker ps -a'
