#!/bin/bash

goldlnk=false
reposPath=~/dev/repos
bashrcPath=~/.bashrc
auxilary_repos_path=${reposPath}/aux
github_site_repos_path=${auxilary_repos_path}/github
sqelliot_projects_path=${github_site_repos_path}/sqelliot
toolsPath=${sqelliot_projects_path}/tools
tools_bash_path=${toolsPath}/bash
tools_profile_bash_path=${tools_bash_path}/profile/.bashrc

# self-references
if [ "$bash_env" == "HOME" ]; then
  reposPath=~/dev/repos/
fi
if [ $(hostname) == "GLDLBAE496014" ]; then
  reposPath=/c/dev/repos/
  goldlnk=true
fi
if [ $(hostname) == "WIN1050LH8G3" ]; then
  reposPath=~/dev/repos/
  source ${toolsPath}/bash/corp/rmd/.bashrc
  git_branch_author_name=sean.elliott
fi
if [[ $(hostname) == "WIN1050LH8G3-Ubuntu-VM" ]]; then
  bashrcPath=~/.bash_aliases
  source ${toolsPath}/bash/corp/rmd/.bashrc
  git_branch_author_name=sean.elliott
fi
if [ $(whoami) == "root" ]; then
  reposPath=~selliott/repos/
fi
if [ $(whoami) == "ec2-user" ]; then
  reposPath=~/sean.elliott3/
fi
if [ "$reposPath" == "" ]; then
  reposPath=~/repos/
fi
sharedBash=${toolsPath}/bash/shared/.bashrc
localBash=${toolsPath}/bash/local/.bashrc
awsBash=${toolsPath}/bash/aws/.bashrc
corpPath=${toolsPath}/bash/corp
vimPath=${toolsPath}/vim/.vimrc
tmuxPath=${toolsPath}/tmux/.tmux.config
aptPath=${toolsPath}/install/apt
export PATH=$PATH:${toolsPath}/bin
updateFileMessage=$'

#########################################

               BASH UPDATED

#########################################

'

##########
## vars ##
##########

## create tmux config symlink
if [ ! -e "~/.tmux.conf" ]; then
  rm ~/.tmux.conf
  ln -s $tmuxPath ~/.tmux.conf
fi
## vimrc symlink
if [ ! -e "~/.vimrc" ]; then
  rm ~/.vimrc
  ln -s $vimPath ~/.vimrc
fi

#cd() {
#  builtin cd $@ 
#  if [ $(ls -1 | wc -l) -lt 20 ]; then
#    ls
#  fi
#}

######################
## tools management ##
######################

function sourceBash() {
  echo "Sourcing $1..."
  source $1 ; echo "$updateFileMessage"
}

refreshBash() {
  sourceBash ${bashrcPath}
}

## Source other bash files
source ${localBash}
source ${awsBash}
source ${tools_profile_bash_path}


function editBashrc() {
  vim ${bashrcPath}; sourceBash ${bashrcPath} 
}

function e() {
  vim ${sharedBash}; sourceBash ${sharedBash}
}
function editLocalBash() {
  vim ${localBash}; sourceBash ${localBash}
}

function editAwsBash() {
  vim ${awsBash}; sourceBash ${awsBash}
}

bash_corp_count(){
  echo `ls ${corpPath} | wc -l`
}

bash_corp_dirs(){
  echo `ls ${corpPath}`
}

editCorpBash() {
  target_corp_bash=$1
  if [ -z "$target_corp_bash" ]; then
    if [ $(bash_corp_count) -eq 1 ]; then
      target_corp_bash=$(bash_corp_dirs)
    else 
      select corp in $(bash_corp_dirs) exit; do
        case $corp in
          exit)
            return
            break ;;
        *)
          target_corp_bash=$corp
          break ;;
        esac
      done
    fi
  fi

  stat -c "%n" ${corpPath}/$target_corp_bash
  if [ ! $? -eq 0 ]; then
    echo "Can't access ${target_corp_bash}..."
    return
  fi 
  vim ${corpPath}/$target_corp_bash/.bashrc; sourceBash ${corpPath}/$target_corp_bash/.bashrc
}

function sourceSharedBash() {
  sourceBash ${sharedBash}
}

# go to tools
function tools() {
  pushd ${toolsPath}
}

function tools-search(){
  printf "%s\n%s" `alias` `functions`
}


function functions() {
  grep -hr -e "function [a-zA-Z0-9_-]*() {" ${toolsPath} | sort
}

function updatetools() {
  pushd $toolspath
  grebase
  sourceSharedBash
  popd 
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

function toolsgpshobranch() {
  tools && git push origin master
}

function toolspush() {
  git push origin master
}

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

alias datetimestamp="date +'%Y-%m-%d-%H%M%S'"
alias timestamp="date +'%Y%m%d%H%M%S'"

function full_date(){
  date +'%FT%T'
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

myapt(){
  sudo apt install $@ && echo $@ >> ${aptPath}
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


alias layerlog='sudo docker-compose --file /opt/api-gateway/docker-compose.yml logs -t -f --tail 200 api-gateway'

alias baelog='cd /var/log/baesystems/ '
alias baeopt='cd /opt/baesystems/ '
##########################################################
################# Shared git commands ####################
##########################################################
alias gpsho='git push origin'
alias gd='git diff --color'
alias gdc='git diff --cached '
alias gdorigin='git diff origin/$(gitbranch)'
alias gddefault='git diff origin/$(gitdefaultbranch)'
alias gpsh='git push'
alias    gadd='git add'
alias  gpatch='git add --patch'
alias    gbra='git branch'
alias gdev='git checkout dev'
alias gmaster='git checkout master'
alias gbragrep="git branch | grep"
alias gbraremotegrep="gfo ; git branch -r | grep"
alias    gch='git checkout'
alias gcommit='git commit -S '
alias    gco='gcommit'
alias   gcom='gcommit -m'
alias   gca='gcommit --amend'
alias   gfo='git fetch origin -p'
alias   gfa='git fetch --all -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --all --decorate'     
alias    gitcommits='git log --graph --abbrev-commit --decorate  --first-parent $(gitbranch)'     
alias    gitlogone='git log --pretty=oneline'
alias grebase='gfa && git rebase'
alias grebasedefault='gfa && git rebase origin/$(gitdefaultbranch)'
alias grebaseorigin='gfa && git rebase origin/$(gitbranch)'
alias gresetdefaultsoft='gfo && git reset --soft origin/$(gitdefaultbranch) && git restore --staged . && gsta'
alias gresetdefaulthard='gfa && git reset --hard origin/$(gitdefaultbranch)'
alias gresetheadsoft='git reset --soft HEAD'
alias gresetheadhard='git reset --hard HEAD'
alias gresetoriginhard='gfa && git reset --hard origin/$(gitbranch)'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gcommitcontents='git diff-tree --no-commit-id --name-only -r '
alias gcp='git cherry-pick '
alias gcf='git clean -f'
alias gsa='GSA=`git stash apply`; echo $GSA; $GSA'
alias grestore='git restore --staged .'
alias git-chmod-exec='git update-index --chmod=+x --add '
alias gstash='git stash'
alias isgit='git -C . rev-parse'

export GIT_EDITOR=vim


function gbrame() {
  git branch | grep $git_branch_author_name
}
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
MCI='mvn clean install'


mvn(){
  stat ./mvnw > /dev/null
  if [ $? == 0 ]; then
    ./mvnw $@
  else
    /usr/bin/mvn $@
  fi
}
alias   mci='mvn clean install'
alias  mciskip='type mciskip && mci -Dmaven.test.skip=true'
alias mvntree='mvn dependency:tree'
alias mcirun='type mcirun; mci spring-boot:run'



function gitnew() {
  git checkout -b $1 origin/dev
}

function gogit() {
  pushd ${reposPath}/$1
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

  git clone $bitbucket_ssh_clone/$1/$2
}

function toolspush() {
  gpsho -u $(gitbranch) $@
}

function gpshobranch() {
  if [[ $(gitbranch) == "dev" ]] || [[ $(gitbranch) == "master" ]]; then
    echo "Error: commits cannot be directly pushed to this branch"
    return 0
  fi
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

function gitnewbranch() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <name> [target branch]"
    return 0
  fi
  
  name=$1
  target_branch=$(gitdefaultbranch)

  if [ "$#" = 2 ]; then
    target_branch=$2
  fi

  gfo
  git checkout -b feature/${target_branch}/${git_branch_author_name}/${name} origin/$target_branch

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

  feature_branch_name_prefix="feature"
  use_author_name="true"
  use_target_branch_name="true"

  new_branch_name=""
  new_branch_name+="${feature_branch_name_prefix}"
  new_branch_name+=$( [ "$use_target_branch_name" = true ] && echo "/${target_branch}")
  new_branch_name+="/${name}"
  new_branch_name+=$( [ "$use_author_name" = true ] && echo "-${git_branch_author_name}")
  

  gfo
  git checkout -b ${new_branch_name} origin/$target_branch || git rebase origin/$target_branch
}

function gitbackupbranch() {
  git branch --copy $(gitbranch)-$(timestamp)

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
  git checkout -b drfix/${target_branch}/${git_branch_author_name}/${name} origin/$target_branch
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
  up_path=()

  for i in $(seq 1 ${num});
  do
    up_path+='../'
  done

  full=""
  for d in  "${up_path[@]}";
  do
    full+=${d};
  done

  pushd ${full}
  ls
}

#function goto() {
#  if [ "$#" -ne 1 ]; then
#    echo "Usage: ${FUNCNAME[0]} <delimiter>"
#    return 0
#  fi
#
#  delimiter=$1
#  new_path=$(pwd | awk -F ${delimiter} '{print $1}' )$delimiter
#
#  cd $new_path
#}

# Grabs only the jira number from the current git branch
# Example: drfix/dev/FCMS-0000-fix -> FCMS-0000
function git_jira_issue() {
  gitbranch | awk -F '/' '{print $NF}' | awk -F '-' '{print $1"-"$2}'
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

function grih(){
  ## interactive rebase to X commits back
  head_diff=${1:-1}
  git rebase -i HEAD~$1
}


# Commit with message starting with the current jira issue 
function gjiracommit(){
  if [ "$#" -lt 1  ]; then
    echo "Usage: gjiracommit <msg>"
    return 0
  fi
  msg=$@
  gcommit -m "$(git_jira_issue): ${msg}"
}

function gitjiracommitandpush () {
  if [ "$#" -lt 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <msg> <files>"
    return 0
  fi

  msg=$1
  files=${@:2}

  gadd $files &&  gjiracommit $msg && gpshobranch
}

gitpushall(){
  git add .
  
  echo "gcommit message: "
  read

  gjiracommit "$REPLY"
  gpshobranch
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
  #branch=$(gbragrep  $1)
  #if [ ! "$branch" ];then 
  #  gfo
  #  branch=$(gbraremotegrep  $1)
  #  if [ ! "$branch" ];then
  #    echo "No branch found"
  #    return
  #  fi
  #fi

  gfo
  select branch in $(gbraremotegrep  $1) exit; do
    case $branch in
      exit)
        break ;;
    *)
      the_branch=$branch
      break ;;
    esac
  done

  printf '%s\n' "$the_branch"
  # strip remotes and origin
  the_branch=$(echo $the_branch | sed 's/remotes\///g' | sed 's/origin\///g')
  printf '%s\n' "$the_branch"

  gch $the_branch
}

function gitdefaultbranch() {
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}


function git-common-ancestor-with-default-branch(){
  git merge-base $(gitbranch) $(gitdefaultbranch ) 
}

function git-rebase-to-ancestor-branch(){
  git rebase -i $(git-common-ancestor-with-default-branch)
}

function gorigindefault() {
  branch=$(gitdefaultbranch)
  if [ "$#" == 1 ];then
    branch=$1
  fi 

 
  echo "Checking out $branch and reseting to remote..."
  gfa -p
  git stash
  git checkout $branch
  gitreset origin/$branch
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

easyfind(){
  find . -type f -iname "*$1*"
}

function zipdate() {
  if [ "$#" != 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <file>"
  fi
  name=$1
  
  zip -q -r $name-$(datetimestamp).zip $name
}

function tardate() {
  if [ "$#" != 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <file>"
  fi
  name=$1
  tar -cf $name-$(datetimestamp).zip $name
}

function dir-sizes(){
  du -d 1 -h | sort -h
}

just_notes_dir="/c/dev/notes/"
just_notes_location=${just_notes_dir}"just-notes.txt"
alias notes="cd $just_notes_dir"
## just-notes
function just-notes-date() {
  header='======================================================================='

  echo -e '\n\n'$header'\n'`date '+%Y-%m-%d, %A'`'\n'$header >> $just_notes_location
}

function just-notes-open() {
  grep "\[\[\]\]" $just_notes_location | wc -l
  grep "\[\[\]\]" $just_notes_location
}

function just-notes-not-open() {
  grep -E "\[\[.+\]\]" $just_notes_location
}

## just-notes

function just-notes-edit() {
  vim $just_notes_location
}


function perform-in-dirs() {
  if [ "$#" != 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <action>"
  fi
  action=$1
  echo "The action: $action"
  dirs=$(ls -d */)

  for dir in ${dirs}; 
  do
    pushd $dir;
    bash -ic "$action";
    popd
  done
}

alias dpsa='docker ps -a'

convert-pem-to-crt(){
  source_pem=$1


  openssl x509 \
    -outform der \
    -in $source_pem \
    -out $source_pem.crt
}

add-pem-to-keystore(){
  source_pem=$1
  target_keystore=$2

  source_host=$(echo ${source_pem} | awk -F '.' '{print $1}')

  convert-pem-to-crt $source_pem

  keytool -import \
          -keystore $JAVA_HOME/lib/security/cacerts \
          -file ${source_pem}.crt \
          -alias $source_host
  trash ${source_pem}.crt
}

extract_host_ca_chain(){
  if [ "$#" != 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <host> <port>"
    return
  fi
  host=$1
  port=$2
  name=${host}${port}

  tmp_dir=$(mktemp -d --quiet)
  pushd $tmp_dir > /dev/null

  openssl s_client -showcerts -verify 5 -connect ${host}:${port} < /dev/null 2> /dev/null | awk '/BEGIN/,/END/{  out="cert.pem"; print >out}'

  popd > /dev/null
  echo ${tmp_dir}/cert.pem
}

extract_host_ca(){
  if [ "$#" != 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <host> <port>"
    return
  fi
  host=$1
  port=$2
  work_dir=${host}${port}

  mkdir -p $work_dir
  pushd $work_dir
  openssl s_client -showcerts -verify 5 -connect ${host}:${port} < /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".pem"; print >out}';
  for cert in *.pem;
  do
    newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').crt;
    echo "${newname}";
    mv "${cert}" "${newname}";
  done
}

read-pem(){
  openssl x509 -in $1 -noout -text
}

pem-subject(){
  openssl x509 -noout -subject -in $1 | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]'
}

export CA_CERT_PATH=/usr/local/share/ca-certificates

alias start-ssh-agent='eval `ssh-agent`'

add-to-ca-certs(){
  cp $1 ${CA_CERT_PATH}/
  sudo update-ca-certificates
}


git-commit-diff() {
  git diff ${1}~1 ${1}
}


get-current-bash-options(){
  echo "$-"
}

is-bash-vi-mode-enabled(){
  if [[ `set -o | grep "\<vi\>" | awk '{print $2}'` == "on" ]];
  then
    echo "true"
  else
    echo "false"
  fi

}


mytrash(){
  Trash_Path=~/.local/share/Trash
  Trash_Files_Path=${Trash_Path}/files
  Trash_Info_Path=${Trash_Path}/info

  input_path=$1
  input_file_name=$(basename ${input_path})

  timestamp=$(full_date)
  origin_full_path=$(realpath $input_path)

  trash_new_file_path=${Trash_Files_Path}/${input_file_name}
  trash_new_info_path=${Trash_Info_Path}/${input_file_name}.trashinfo

  
  mv ${input_path} ${trash_new_file_path}

  printf "Path=${origin_full_path}\nDeletionDate=${timestamp}\n" > ${trash_new_info_path}
  
}

alias clipboard='xclip -selection clipboard'
alias clear-clipboard='echo | clipboard'

## gio shortcuts
## gio shortcuts
alias gio-trash='gio trash '
alias gio-list-trash='gio list trash://'

alias ls1='ls -1'

alias tree2='tree -L 2'

## saml2aws
export amr_nonprod_profile='rmd-amr-nonprod'
export amr_prod_profile='rmd-amr-prod'
export eu_prod_profile='rmd-eu-prod'
export eu_nonprod_profile='rmd-eu-nonprod'

alias s2a='saml2aws -a ${SAML2AWS_PROFILE}'
alias saml2console='firefox -new-window $(s2a console --link)'
alias saml2link='s2a console --link | tr -d "\n" | xclip -selection clipboard'
alias s2alogin='s2a login --skip-prompt '
alias mcs-dev='set_nonprod_profile; s2alogin --role=arn:aws:iam::668994236368:role/tlz_admin '
alias mcs-alpha='set_nonprod_profile; s2alogin --role=arn:aws:iam::360808914875:role/tlz_admin'
alias amr-prod='set_prod_profile; s2alogin '
alias prod='amr-prod'
alias airview-prd='set_prod_profile; s2alogin --role=arn:aws:iam::077995606180:role/tlz_developer'
alias amr-nonprod='set_nonprod_profile; s2alogin '
alias nonprod='amr-nonprod'
alias amr-nonprod-link='set_nonprod_profile; saml2link '
alias ranlink='amr-nonprod-link'
alias rapi='ranlink'
alias alpha='set_nonprod_profile; s2alogin --role=arn:aws:iam::360808914875:role/tlz_admin'

SAML2AWS_FILE_PATH=~/.aws/saml2aws-profile
AWS_PROFILE_FILE_PATH=~/.aws/profile

source_saml_aws_env(){
  source $AWS_PROFILE_FILE_PATH
  source $SAML2AWS_FILE_PATH
}

source_saml_aws_env


alias set_nonprod_profile='set-aws-env-profile ${amr_nonprod_profile}'
alias set_prod_profile='set-aws-env-profile ${amr_prod_profile}'
alias set_eu_nonprod_profile='set-aws-env-profile ${eu_nonprod_profile}'
alias set_eu_prod_profile='set-aws-env-profile ${eu_prod_profile}'

set-aws-env-profile(){
  profile_name=$1
  echo "Setting $profile_name profile..."


  truncate -s 0 $AWS_PROFILE_FILE_PATH
  echo "export AWS_PROFILE=${profile_name}" >> $AWS_PROFILE_FILE_PATH

  truncate -s 0 $SAML2AWS_FILE_PATH
  echo "export SAML2AWS_PROFILE=${profile_name}" >> $SAML2AWS_FILE_PATH

#  echo "SAML2AWS_PROFILE=${SAML2AWS_PROFILE}"
#  echo "AWS_PROFILE=${AWS_PROFILE}"

  source $AWS_PROFILE_FILE_PATH
  source $SAML2AWS_FILE_PATH

  echo "SAML2AWS_PROFILE=${SAML2AWS_PROFILE}"
  echo "AWS_PROFILE=${AWS_PROFILE}"
}

get-aws-env-profile(){
  echo $AWS_PROFILE
}

set-saml2aws-profile(){
  profile_name$1

  truncate -s 0 $SAML2AWS_FILE_PATH
  echo "SAML2AWS_PROFILE=${profile_name}" >> $SAML2AWS_FILE_PATH
  source $SAML2AWS_FILE_PATH
}


do_prompt(){
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

curr_dir(){
  result=${PWD##*/}          # to assign to a variable
  result=${result:-/}        # to correct for the case where PWD=/
  
 # printf '%s\n' "${PWD##*/}" # to print to stdout
                             # ...more robust than echo for unusual names
                             #    (consider a directory named -e or -n)
  
  printf '%q\n' "${PWD##*/}"
}



## browser/firefox
search(){
  firefox -search "$@"
}

backup(){
  file=$1
  mv ${file} ${file}.old
}

tf-backend() {
  if [ -z "${BACKEND_TEMPLATE_PATH}" ]; then
    BACKEND_TEMPLATE_PATH="${rmdReposPath}/backend.tf"
  fi

  # the tf repo name, which is _probably_ the workspace name (usually)
  tf_repo=`curr_dir`

  regions=(ptfe.prod.dht.live ptfe.prod.rmdeu.live)
  select region in "${regions[@]}" exit; do
    case $region in
      exit) return break;;
      *)
        region=$region
        break;;
    esac
  done

  read -p "workspace name [${tf_repo}]: " workspace_name
  workspace_name=${workspace_name:-$tf_repo}

  cp ${BACKEND_TEMPLATE_PATH} .
  sed -i "s/HOSTNAME/${region}/g" ${BACKEND_TEMPLATE_PATH} ./backend.tf
  sed -i "s/WORKSPACE_NAME/${workspace_name}/g" ${BACKEND_TEMPLATE_PATH} ./backend.tf
}

tf_dht(){

  find -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.dht.live/g' {} \; 
}

tf_eu(){

  find -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.rmdeu.live/g' {} \; 
}

tf_local(){
  find -name "*.tf" -exec sed -i 's/ptfe.prod.dht.live/localterraform.com/g' {} \; 
}


## terraform
tf_get(){
  tmp_file=`mktemp`
  
  echo "terraform get"
#  echo "Temporarily replacing all localterraform.com hostnames for module sources"
#  find -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.dht.live/g' {} \; 
#  tf_eu
  tf_dht

  #terraform get 2>&1 | tee ${tmp_file}
  terraform init 2>&1 | tee ${tmp_file}
  if [[ -n `cat ${tmp_file} | grep localterraform.com` ]]; then
    echo "need to run again"
    tf_get
  else
    echo "terraform get succeeded"
    find -name "*.tf" -exec sed -i 's/ptfe.prod.dht.live/localterraform.com/g' {} \;
  fi
}


java_version(){
  version=$1
  versions_list=(7 8 11 17) 
  if [ ! -n "${version}" ]; then
    select v in "${versions_list[@]}" exit; do
      case $v in
        exit)
          return break ;;
        *)
          echo $v
          version=$v
          break ;;
      esac
    done
  fi
    
  echo $version
  case $version in
    7)
      sudo update-alternatives --set java "${JAVA_7_CONFIG}" && set_java_home "${JAVA_7_HOME}"
      ;;
    8)
      sudo update-alternatives --set java "${JAVA_8_CONFIG}" && set_java_home "${JAVA_8_HOME}"
      ;;
    11)
      sudo update-alternatives --set java "${JAVA_11_CONFIG}" && set_java_home "${JAVA_11_HOME}"
      ;;
    17)
      sudo update-alternatives --set java "${JAVA_17_CONFIG}" && set_java_home "${JAVA_17_HOME}"
      ;;
  esac
}

alias java7='java_version 7'
alias java8='java_version 8'
alias java11='java_version 11'
alias java17='java_version 17'

alias l='ls -CF --group-directories-first'
