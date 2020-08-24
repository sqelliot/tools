#!/bin/bash

# self-references
if [ "$reposPath" == "" ]; then
  reposPath=~/repos/
fi
if [ $(hostname) == "GLDLBAE496014" ]; then
  reposPath=/c/dev/repos/
fi
if [ $(whoami) == "root" ]; then
  reposPath=~selliott/repos/
fi
if [ $(whoami) == "ec2-user" ]; then
  reposPath=~/sean.elliott3/
fi
if [ "$GIT_BRANCH_NAME" == "" ]; then
  GIT_BRANCH_NAME=selliott
fi
export PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\] `gitbranch || echo ""` {`date`} \[\033[0m\]\nπ '
CL_TOP=${reposPath}/conlib/top
toolsPath=${reposPath}/tools/
sharedBash=${toolsPath}/bash/shared/.bashrc
localBash=${toolsPath}/bash/local/.bashrc
programPath=${toolsPath}/bash/program/
programBash=${programPath}/.bashrc
awsBash=${toolsPath}/bash/aws/.bashrc
vimPath=${toolsPath}/vim/.vimrc
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
source ${programBash}

## source vim file
source $vimPath

function editBashrc() {
  vim ~/.bashrc; sourceBash ~/.bashrc
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

function editProgramBash() {
  vim ${programBash}; sourceBash ${programBash}
}

function sourceSharedBash() {
  sourceBash ${sharedBash}
}

# go to tools
function tools() {
  gogit tools
}


function functions() {
  grep -hr -e "function [a-zA-Z0-9_-]*() {" ${toolsPath} | sort
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

alias cl='gogit conlib'
alias ecl='gogit ecl'
alias fg='gogit conlib/cl-frontgate'
alias fgansible='fg && cd deployment/ansible'
alias dissemtest='gogit conlib/cl-dissem/services/apps/dissem/src/main/assembled/examples'
alias eclansible='ecl && cd ecl-rlc-deployment/ansible'

## shell ##
#################################################
alias ll='ls -l'
alias l1='ls -1'
function llbs() {
  ll --block-size=$1
}
#function cd () {
#  bash -lic "/bin/cd $1 && ls"
#}

function epoch() {
  date +'%s'
}

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

alias randomString="head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''"

function export_to_env() {
  if [ "$#" != 1  ]; then
    echo "Usage: ${FUNCNAME[0]} <var_name>"
    return
  fi
  var_name=$1

  echo -n "Secret: "
  read -s secret
  echo

  export $var_name=$secret
}

## systemctl
function sys() {
  action=$1
  for system in ${@:2}
  do
    sudo systemctl $action "$system" 
  done
}
alias sysstatus='systemctl status '
alias sysrestart='sys restart '
alias sysstop='sys stop '
alias sysdisable='sys disable '
alias sysstate='systemctl show --property "ActiveState" --property "Id" --property "ExecMainStartTimestamp" --property "Description"'
function sysend() {
  sys "disable --now" $@
}
function jrnl(){
  sudo journalctl -u $@
}

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
  ansible-playbook -v -bK --connection=local $@ -e "{service_config_info : { staging_directory : $CL_TOP }}" -e "{ saml : { validation : { enabled : false }}}"
}

function apcllocalsamldev () {
  ansible-playbook -v -bK --connection=local $@ -e "{service_config_info : { staging_directory : $CL_TOP }}" 
}

function apclsqslocal() {
  ansible-playbook --connection=local -v -bK $1 -e "{service_config_info : { staging_directory : $CL_TOP }}" -e "{receiver : { sqs : { name : SELLIOTT-FG-CLOUD-POP-COMPLETE }}}" -e "{ site : { modify : { destination : SELLIOTT-FG-SITE-FLOW-CONTROL }}}" -e "{ preprocessing : { sqs : { name : SELLIOTT-PP-FRONT-GATE-COMPLETE }}}"
}

function apcltop() {
  ansible-playbook -v -bK $1 -e "{service_config_info : { staging_directory : $CL_TOP }}" ${@:2}
}

alias layerlog='sudo docker-compose --file /opt/api-gateway/docker-compose.yml logs -t -f --tail 200 api-gateway'

alias baelog='cd /var/log/baesystems/ '
alias baeopt='cd /opt/baesystems/ '
##########################################################
################# Shared git commands ####################
##########################################################
alias gpsha='git push --all'
alias gpsho='git push origin'
alias gd='git diff --color-words'
alias gdc='git diff --cached '
alias gdorigin='git diff origin/$(gitbranch)'
alias gpsh='git push'
alias    gadd='git add'
alias  gpatch='git add --patch'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gmaster='git checkout master'
alias gbragrep="git branch | grep"
alias gbraremotegrep="gfo; git branch -r | grep"
alias    gch='git checkout'
alias    gco='git commit'
alias   gcom='git commit -m'
alias   gfo='git fetch origin -p'
alias   gfa='git fetch -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias    gitcommits='git log --graph --abbrev-commit --decorate  --first-parent $(gitbranch)'     
alias grebase='gfo && git rebase'
alias grebasedefault='gfo && git rebase origin/$(gitdefaultbranch)'
alias grebaseorigin='gfo && git rebase origin/$(gitbranch)'
alias grebasegitlab='gfa && git rebase gitlab/$(gitbranch)'
alias gresetdefaultsoft='gfo && grebasedefault && git reset --soft origin/$(gitdefaultbranch)'
alias gresetdefaulthard='gfo && git reset --hard origin/$(gitdefaultbranch)'
alias gresetheadsoft='git reset --soft HEAD'
alias gresetheadhard='git reset --hard HEAD'
alias gresetoriginhard='gfo && git reset --hard origin/$(gitbranch)'
alias gresetdefaultsoft='git reset --soft origin/$(gitdefaultbranch)'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gcommitcontents='git diff-tree --no-commit-id --name-only -r '


function gbrame() {
  git branch | grep $GIT_BRANCH_NAME
}
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
MCI='mvn clean install'
MVN_CL_CONFIGS='-P copy-artifacts -Duser.top='$CL_TOP
MICL='mvn install '$MVN_CL_CONFIGS
MCICL='mvn clean install '$MVN_CL_CONFIGS
MCISKIP='mvn clean install -Dmaven.test.skip=true '
MCICLSKIP=$MCISKIP' '$MVN_CL_CONFIGS

alias   mci='echo $MCI; $MCI'
alias  mciskip='echo $MCISKIP && $MCISKIP'
alias mvntree='mvn dependency:tree'
alias micl='echo $MICL && $MICL'
alias mcicl='echo $MCICL && $MCICL && mytop'

function mciclskip() {
  echo $MCICLSKIP && $MCICLSKIP $@ && mytop
}

##### Gradle commands ##### 
alias gradlefast='${reposPath}/fast/gradlew'


function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  cd ${reposPath}/$1
}

function gitbranch() {
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
  #if [[ $(gitbranch) == "cl-dev" ]] || [[ $(gitbranch) == "dev" ]] || [[ $(gitbranch) == "master" ]]; then
  #  echo "Error: commits cannot be directly pushed to this branch"
  #  return 0
  #fi
  gpsho -u $(gitbranch) $@
}

function gitreset() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: gitreset <branch>"
    return 0
  fi
  branch=$1
  gfo && git reset --hard ${branch}
}

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
  git checkout -b feature/${target_branch}/${GIT_BRANCH_NAME}/${name} origin/$target_branch
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
  git checkout -b drfix/${target_branch}/${GIT_BRANCH_NAME}/${name} origin/$target_branch
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

  for i in $(seq 1 ${num});
  do
    #echo "Went up ${i} dirs"
    #pwd
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
  new_path=$(pwd | awk -F ${delimiter} '{print $1}' )$delimiter

  cd $new_path
}

# Grabs only the jira number from the current git branch
# Example: drfix/dev/FCMS-0000-fix -> FCMS-0000
function git_jira_issue() {
  prefixes="(FCMS|FES|WOOD|ECLDEV|CLDEV).*"
  echo $(gitbranch ) | grep -oE ${prefixes} | awk -F'[-]' '{printf "%s-%s", $1,$2}'
}

# update a branch
# default to remote if no arg given
function gupdate() {
  if [ "$#" -ne 1 ]; then
    gfo; git rebase origin/$(gitbranch)
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

 
  echo "Checking out $branch and reseting to remote..."
  gfo -p
  git stash
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

function mysed() {
  if [ "$#" -lt 2  ]; then
    echo "Usage: ${FUNCNAME[0]} <target string> <replacer> <targets...>"
    return
  fi
  
  sudo sed -i 's/${1}/${2}/g' ${@:3}
  #echo $cmd
  #bash -lic $cmd
}

function sd() {
  sudo $@
}

function randomfile() {
  units=M
  size=1
  append=false
  while test $# -gt 0; do
    case "$1" in
      -u)
        shift
        units=$1
        shift
        ;;
      -s)
        shift
        size=$1
        shift
        ;;
      -d)
        shift
        dest=$1
        shift
        ;;
      -a)
        shift
        append=true
        ;;
      *)
        echo "Unrecognized flag: $1"
        return 1;
        ;;
    esac
  done

  if [[ $(isWholeNumber $size) != 0 ]]; then
    echo "Size must be a whole number"
    return 1;
  fi

  if [ -z $dest ]; then
    echo "Destination undefined"
    return 1;
  fi

  if [ "$append" == false ]; then
    head -c ${size}${units} </dev/urandom > $dest
  else
    head -c ${size}${units} </dev/urandom >> $dest
  fi
  
}

function pathjump () {
  dest_dir=$1
  _pwd=$(pwd)
  dest_path=${_pwd%${dest_dir}*}
  dest_path=${dest_path}/${dest_dir}
  cd $dest_path
}

function searchsystemctl() {
  systemctl | grep  -E "$1" | awk '{print $1}'
}

function eclservices() {
  searchsystemctl "Front|Library|RLC"
}

function eclstop() {
  sysstop $(eclservices)
}
#alias newestfile="ll -rst | tail -n 1 | awk '{print $NF}'"
function newestfile() {
  string=""
  num=1
  _args=1rt
  while test $# -gt 0; do
    case "$1" in
      -n)
        shift
        num=$1
        shift
        ;;
      -s)
        shift
        string=$1
        shift
        ;;
      -l)
        shift
        _args=$_args"l"
        ;;
      *)
        echo "Unrecognized flag: $1"
        return 1;
        ;;
    esac
done
 
  ls "-$_args" | grep "$string" | tail -n $num 
}

function oldestfile() {
  string=""
  num=1
  _args=1rt
  while test $# -gt 0; do
    case "$1" in
      -n)
        shift
        num=$1
        shift
        ;;
      -s)
        shift
        string=$1
        shift
        ;;
      -l)
        shift
        _args=$_args"l"
        ;;
      *)
        echo "Unrecognized flag: $1"
        return 1;
        ;;
    esac
done
 
  ls "-$_args" | grep "$string" | head -n $num
}
function findname() {
  find . -name $@
}

function findfile() {
  find $@ -type f
}

function finddir() {
  find $@ -type d
}
##########################################################
################ Shared docker commands ##################
##########################################################
alias dpsa='docker ps -a'
