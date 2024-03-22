#!/bin/bash

goldlnk=false
reposPath=~/dev/repos
bashAliasesPath=~/.bash_aliases
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
if [ $(hostname) == "MACQMQWTY2GFQ" ]; then
  reposPath=~/dev/repos/
  source ${toolsPath}/bash/corp/rmd/.bashrc
  git_branch_author_name=sean.elliott
fi
if [[ $(hostname) == "WIN1050LH8G3-Ubuntu-VM" ]]; then
  bashAliasesPath=~/.bash_aliases
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
inputrcPath=${toolsPath}/inputrc
tmuxPath=${toolsPath}/tmux/.tmux.config
gpgConfPath=${toolsPath}/gpg/gpg-agent.conf
aptPath=${toolsPath}/install/apt
export PATH=$PATH:${toolsPath}/bin
export PATH=$PATH:~/bin
updateFileMessage=$'

#########################################

               BASH UPDATED

#########################################

'
shopt -s histappend
export HISTFILESIZE=100000

##########
## vars ##
##########

## create tmux config symlink
if [ ! -e "~/.tmux.conf" ]; then
  rm ~/.tmux.conf
fi
ln -s $tmuxPath ~/.tmux.conf
## vimrc symlink
if [ ! -e "~/.vimrc" ]; then
  rm ~/.vimrc
fi
ln -s $vimPath ~/.vimrc
##  inputrc symlink
if [ ! -e "~/.inputrc" ]; then
  rm ~/.inputrc
fi
ln -s $inputrcPath ~/.inputrc

## gpg-agent conf
if [ ! -e "~/.gnupg" ]; then
  if [ ! -e "~/.gnupg/gpg-agent.conf" ]; then
    rm ~/.gnupg/gpg-agent.conf
  fi
  ln -s $gpgConfPath ~/.gnupg/gpg-agent.conf
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
  sourceBash ${bashAliasesPath}
}

## Source other bash files
source ${localBash}
source ${awsBash}
source ${tools_profile_bash_path}


function editBashAliases() {
  vim ${bashAliasesPath}; sourceBash ${bashAliasesPath} 
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

  stat --format "%n" ${corpPath}/$target_corp_bash
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


doTar() {
  target=$1
  archive_name=$2

  # If archive_name is empty, set it to "${target}.tar.gz"
  if [ -z "$archive_name" ]; then
    # Strip out symbols like '/'
    archive_name="${target//\//_}.tar.gz"
  fi

  # Rest of the function code...
  # Add your logic to create the tar archive using target and archive_name
  # For example:
  tar -czf "$archive_name" "$target"
  
  echo "Archive created: $archive_name"
}

alias undotar='tar -xzf '
#alias aws='/usr/local/b

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

initapt(){
  sudo apt update
  sudo apt install -y $(awk '{print $1}' $aptPath)
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




alias baelog='cd /var/log/baesystems/ '
alias baeopt='cd /opt/baesystems/ '
##########################################################
################# Shared git commands ####################
##########################################################
alias gpsho='git push origin'
alias gd='git diff --color'
alias gdc='gd --cache'
alias gdhead='gd HEAD'
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
alias    gch='git checkout'
alias    gco='gcommit'
alias   gca='gcommit --amend'
alias   gfo='git fetch origin -p'
alias   gfa='git fetch --all -p'
alias  gtfo='gfo'
alias    glog='git log --oneline --graph --decorate'     
alias    glogall='git log --oneline --graph --all --decorate'     
alias    gitcommits='git log --graph --abbrev-commit --decorate  --first-parent $(gitbranch)'     
alias    gitlogone='git log --pretty=oneline -n 10'
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
alias grc='gadd . && git rebase --continue'
alias gra='git rebase --abort'
alias gcommitcontents='git diff-tree --no-commit-id --name-only -r '
alias gcp='git cherry-pick '
alias gcpa='gcp --abort'
alias gcf='git clean -fd'
alias gsa='GSA=`git stash apply`; echo $GSA; $GSA'
alias grestore='git restore --staged .'
alias git-chmod-exec='git update-index --chmod=+x --add '
alias gstash='git stash'
alias isgit='git -C . rev-parse'

gselect(){
  select name in $(git diff --name-only) exit; do
    case $name in
      exit)
        return
        break;;
      *)
        gpatch $name
        break;;
    esac
  done
  
}

gcom(){
  gcommit -m "$@"
}
gcommit(){ 
  git commit -S "$@"
}

gbranchlog(){
  git log $(gitdefaultbranch)..$(gitbranch) $@
}



export GIT_EDITOR=vim

function gbraremotegrep(){
  declare -a branches=()
  gfo
  git branch -a | grep $1 | xargs
}

function gbrame() {
  git branch | grep $git_branch_author_name
}

alias gshow='git show --color --pretty=format:%b '
##########################################################
################# Shared git commands ####################
##########################################################

##### Maven commands ##### 
MCI='mvn clean install'

set-version() {
  mvn versions:set -DnewVersion=$1 -DgenerateBackupPoms=false
}


mvn(){
  stat ./mvnw > /dev/null
  if [ $? == 0 ]; then
    ./mvnw $@
  else
    $(which mvn) $@
  fi
}

export MAVEN_OPTS="-Xmx2048m -Xmx1024m"
alias mcc='mvn clean compile'
alias   mci='mvn clean install'
alias  mciskip='type mciskip && mci -Dmaven.test.skip=true'
alias mvntree='mvn dependency:tree'
alias mcirun='type mcirun; mci spring-boot:run'
alias mvnrun='mvn spring-boot:run'
alias mifast='echo "Minimal mvn install..." && mvn install -Dmaven.test.skip=true -DskipTests -Djacoco.skip=true'
alias mcifast='echo "Minimal mvn install..." && mvn clean install -Dmaven.test.skip=true -DskipTests -Djacoco.skip=true'



function gogit() {
  pushd ${reposPath}/$1
}

git-copy-commit-id(){
  git rev-parse --short HEAD | clipboard
}

function gitbranch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

gitbranchnoslashes(){
  echo $(gitbranch) | sed  's/\//-/g'
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
  if [ "$#" -lt 1 ]; then
    echo "Usage: gitreset <branch>"
    return 0
  fi
  branch=$1
  gfo && git reset --hard ${branch}
}


gitnewbranch() {
    local task_id=$1
    local semantic_name=$2
    local meta_info=$3

    # If task_id is not provided, prompt the user to enter it
    if [ -z "$task_id" ]; then
        read -p "Enter the task_id: " task_id
    fi

    if [ ! -z "$meta_info" ]; then
       meta_info="-${meta_info}"
    fi

    # Define the list of valid semantic names
    valid_semantic_names=("chore" "docs" "feature" "fix" "refactor" "style" "test")

    # If semantic_name is not provided, prompt the user to select from the options
    if [ -z "$semantic_name" ]; then
        echo "Valid semantic names: ${valid_semantic_names[*]}"
        echo "Select a semantic name: "
        select option in "${valid_semantic_names[@]}"; do
            if [ -n "$option" ]; then
                semantic_name=$option
                break
            else
                echo "Invalid choice. Please try again."
            fi
        done
    else
        # Validate provided semantic_name
        if [[ ! " ${valid_semantic_names[@]} " =~ " ${semantic_name} " ]]; then
            echo "Error: Invalid semantic_name argument. Valid options are: ${valid_semantic_names[*]}"
            return 1
        fi
    fi

    # Fetch the latest changes from the remote repository
    gfo

    # Get the default branch name
    default_branch=$(gitdefaultbranch)

    # Create and switch to the new branch
    branch_name="${semantic_name}/${task_id}${meta_info}"
    git checkout -b "$branch_name" "$default_branch"
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


gittmpbranch(){
  gfo
  git checkout -b tmp/sean.elliott-`timestamp` origin/$(gitdefaultbranch)
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

function is-jira-issue-format(){
  if [[ "$1" =~ ^[A-Z]{3,}-[0-9]+ ]]; then
    echo 0
  else
    echo 1
  fi
}

function git_jira_issue() {
  result=$(gitbranch | awk -F '/' '{print $NF}' | awk -F '-' '{print $1"-"$2}')

  [[ $(is-jira-issue-format $result) == 0 ]] && echo $result || echo ""
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
  jira_id="$(git_jira_issue)"
  if [ -z "${jira_id}" ]; then
    echo "Jira issue id for this branch is not set. Will not commit changes"
    return 1
  fi

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
  
  

  gjiracommit fix `timestamp`
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

gme(){
  gchgrep "${git_branch_author_name}" 
}

grefs(){
  pattern=".*"
  if [ ! -z $1 ]; then
    pattern=$1 
  fi
  git for-each-ref --format='%(refname)' refs/heads/ refs/remotes/origin | awk '{sub(/^refs\/heads\//, ""); sub(/^refs\/remotes\/origin\//, ""); print}' | grep "$pattern" | sort | uniq
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
  pattern=".*"
  if [ ! -z $1 ]; then
    pattern=$1 
  fi
  declare -a branches=()
  eval branches=("$(grefs $pattern)")

  branch_count=${#branches[@]}
  case $branch_count in
    0) echo "No branches returned"; return ;;
    1) echo "Switching to single branch returned"
       the_branch=${branches[0]} ;;
    *)
      select branch in ${branches[@]} exit; do
        case $branch in
          exit)
            break ;;
        *)
          the_branch=$branch
          break ;;
        esac
      done
  esac

  printf 'The selected branch: %s\n' "$the_branch"
  # strip remotes and origin
  the_branch=$(echo $the_branch | sed 's/remotes\///g' | sed 's/origin\///g')
  printf 'Processed branch name: %s\n' "$the_branch"

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

lsdir(){
  find . -maxdepth 1 -type d
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

### DOCKER COMMAND
alias dpsa='dockerps -a'
alias drestart-all='docker restart $(docker ps -qa)'
alias dockerps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Names}}"'
alias dcd='docker compose down'
alias dcud='docker compose up -d'
alias docker-restart='dcd && dcud'
alias docker-clean='docker rm $(docker ps -aq -f status=exited)'
alias docker-stop-all='docker stop $(docker ps -aq)'



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

gcommitpath(){
  git rev-list --pretty=oneline --ancestry-path $(gitdefaultbranch)..$(gitbranch)
}

view-commit(){
  echo
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

## okta-aws-cli
export RMD_ORG_DOMAIN_GLOBAL='resmed.okta.com'
export RMD_GLOBAL_OIDC_CLIENT_ID='0oapicxw19tkXuW2T2p7'
export RMD_NONPROD_APP_ID='0oa4hc1t74n8BBFxv2p7'
export RMD_NONPROD_APP_URL='https://resmed.okta.com/home/amazon_aws/0oa4hc1t74n8BBFxv2p7/272'

okta_nonprod(){
  okta-aws-cli --aws-acct-fed-app-id ${RMD_NONPROD_APP_ID} \
               --oidc-client-id ${RMD_GLOBAL_OIDC_CLIENT_ID} \
               --org-domain ${RMD_ORG_DOMAIN_GLOBAL} \
               --open-browser \
               --session-duration 28800
}

## saml2aws
export nonprod_amr_profile='nonprod-amr'
export prod_amr_profile='prod-amr'
export prod_eu_profile='prod-eu'
export nonprod_eu_profile='nonprod-eu'

alias s2a='saml2aws -a ${SAML2AWS_PROFILE}'
alias saml2console='wslview $(s2a console --link)'
alias saml2link='s2a console --link | tr -d "\n" | xclip -selection clipboard'
alias mcs-dev='set_nonprod_profile; s2alogin --role=arn:aws:iam::668994236368:role/tlz_admin '
alias mcs1-dev='set_nonprod_profile; s2alogin --role=arn:aws:iam::779411946484:role/tlz_admin '
alias mcs-alpha='set_nonprod_profile; s2alogin --role=arn:aws:iam::360808914875:role/tlz_admin'
alias prod-amr='set_prod_profile; s2alogin '
alias prod='prod-amr'
alias airview-prd='set_prod_profile; s2alogin --role=arn:aws:iam::077995606180:role/tlz_developer'
alias nonprod-amr='set_nonprod_profile; s2alogin '
alias nonprod='nonprod-amr'
alias eunonprod='set_nonprod_eu_profile; s2alogin '
alias nonprod-amr-link='set_nonprod_profile; saml2link '
alias ranlink='nonprod-amr-link'
alias rapi='ranlink'
alias alpha='set_nonprod_profile; s2alogin --role=arn:aws:iam::360808914875:role/tlz_admin'
alias s2alist='s2a --skip-prompt list-roles'

s2arolescsv(){
  s2alist | grep -E "Account:|arn:aws:iam" | awk 'BEGIN { FS = ": " } /Account:/ { account = $2 } /arn:aws:iam/ { sub("arn:aws:iam::", "", $1); printf "%s,%s,%s\n", account, $1, $2 }' 

}

SAML2AWS_FILE_PATH=~/.aws/saml2aws-profile
AWS_PROFILE_FILE_PATH=~/.aws/profile

s2alogin(){
  s2a login --skip-prompt $@ || s2a login $@
}

source_saml_aws_env(){
  source $AWS_PROFILE_FILE_PATH
  source $SAML2AWS_FILE_PATH
}

source_saml_aws_env


alias set_nonprod_profile='set-aws-env-profile ${nonprod_amr_profile}'
alias set_prod_profile='set-aws-env-profile ${prod_amr_profile}'
alias set_nonprod_eu_profile='set-aws-env-profile ${nonprod_eu_profile}'
alias set_prod_eu_profile='set-aws-env-profile ${prod_eu_profile}'

export SAML2AWS_KEYRING_BACKEND=pass
export GPG_TTY=$(tty)

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

#!/bin/bash

samlselect() {
    local env="$1"
    
    # Run saml2aws login with --skip-prompt to get the list of available roles
    local saml2aws_output
    saml2aws_output=$(saml2aws login --skip-prompt)

    # Check if there are multiple matching accounts
    if [[ "$saml2aws_output" == *"$env"* ]]; then
        # Multiple accounts match the provided env, prompt to select one
        echo "Select an AWS account to use: "
        select account in $(echo "$saml2aws_output" | grep -oE '\[.*\]' | sed 's/\[\|\]//g'); do
            if [[ -n "$account" ]]; then
                break
            else
                echo "Invalid selection. Please choose a valid account number."
            fi
        done
    else
        # Only one account matches, use it
        account="$env"
    fi

    # Prompt to select a role associated with the chosen account
    echo "Select an AWS role to assume: "
    select role in $(echo "$saml2aws_output" | grep -oE '\[.*\]' | sed 's/\[\|\]//g'); do
        if [[ -n "$role" ]]; then
            break
        else
            echo "Invalid selection. Please choose a valid role number."
        fi
    done

    # Use saml2aws to assume the selected role
    saml2aws login -a "$account" -r "$role"
}

do_prompt(){
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) echo "Performing action..."; return 0  ;;  
            [Nn]*) echo "Will not perform action..." ; return  1 ;;
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

## terraform

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
  echo "Going to use $workspace_name for the backend"

  cp ${BACKEND_TEMPLATE_PATH} .
  sed -i "s/HOSTNAME/${region}/g"  ./backend.tf
  sed -i "s/WORKSPACE_NAME/${workspace_name}/g" ./backend.tf

  do_prompt "Run 'terraform init --reconfigure' ? " && terraform init --reconfigure
}

tf-dht(){

  find . -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.dht.live/g' {} \; 
}

tf_eu(){

  find -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.rmdeu.live/g' {} \; 
}

tf_local(){
  find . -name "*.tf" -exec sed -i 's/ptfe.prod.dht.live/localterraform.com/g' {} \; 
}

alias tfplan='terraform plan'
alias tfinit='terraform init -reconfigure'


## terraform
tf-get(){
  tmp_file=`mktemp`
  
  echo "terraform get"
#  echo "Temporarily replacing all localterraform.com hostnames for module sources"
#  find -name "*.tf" -exec sed -i 's/localterraform.com/ptfe.prod.dht.live/g' {} \; 
#  tf_eu
  tf-dht

  #terraform get 2>&1 | tee ${tmp_file}
  terraform init 2>&1 | tee ${tmp_file}
  if [[ -n `cat ${tmp_file} | grep localterraform.com` ]]; then
    echo "need to run again"
    tf-get
  else
    echo "terraform get succeeded"
#    find . -name "*.tf" -exec sed -i 's/ptfe.prod.dht.live/localterraform.com/g' {} \;
  fi
}

alias get-java-home='dirname $(dirname `readlink -f /etc/alternatives/java`)'
alias set-java-home='echo "export JAVA_HOME=`get-java-home`" > ~/.java_home && source ~/.java_home'
alias jv='java --version || java -version'
alias jh='echo $JAVA_HOME'
alias java7='java_version 7'
alias java8='java_version 8'
alias java11='java_version 11'
alias java17='java_version 17'
set-java-home

java-version(){

  sudo update-alternatives --config java

  set-java-home
  jv
}



alias l='ls -CF --group-directories-first'

set_java_home(){
  target_java_version=$1
  
  if [ -z "$target_java_version" ]; then
    sudo update-java-alternatives --auto
  else
    target_java_home=$(sudo update-java-alernatives --list | grep "java-1.${target_java_version}" | awk '{print $NF}')

    echo "export JAVA_HOME=${target_java_home}" > ~/.java_home
  fi  
  source ~/.java_home
}

#source ~/.java_home

## open tmp file in vim
tmp(){
  tmp_file=$(mktemp)
  export TMP_FILE=$tmp_file
}
edit-tmp(){
  if [ -z "${TMP_FILE}" ]; then
    tmp
  fi
    vim $TMP_FILE
}

tmp-dir(){
  tmp_dir=$(mktemp -d)
  pushd $tmp_dir
}

processFile() {          
  file="$1"              
  local IFS="\n"         
  while read -r line; do 
    echo -E "$line"      
  done < $file           
}

## github

gh-repos(){
  prefix=$1
  gh api /orgs/resmed/repos --jq '.[].name | select(startswith("$prefix"))' --paginate
}
mcs_repos(){
  gh api /orgs/resmed/repos  --jq '.[].name | select(startswith("mcs"))' --paginate | tee ${github_resmed_path}/mcs/mcs-repos.txt
}

pr-url(){
   wslview "https://github.com/resmed/$(curr_dir)/pull/new/$(gitbranch)"
}

mcs_repos_sync(){
  while test $# -gt 0; do
    case "$1" in
      -r)
        shift
  mcs_repos
        shift
        ;;
      *)
        echo "Unrecognized flag: $1"
        return 1;
        ;;
    esac
  done
  
  local IFS="\n"         
  while read -r repo; do 
    echo -E "repo: $repo"
    if [ -d "${repo}" ]; then
      pushd $repo
      gfo
      popd
    else
      gh repo clone "resmed/$repo"
    fi
  done < "${github_resmed_path}/mcs/mcs-repos.txt"
  
}

install_gh(){
  type -p curl >/dev/null || sudo apt install curl -y
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
}


main-branch(){
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
}

history-grep(){
  history | grep $@
}

lsdirs(){
  ls -d */
}
function remove_xml_section() {
  local file="$1"
  local section_name="$2"
  sed -i "/<$section_name>/,/<\/$section_name>/d" "$file"
}

alias m2='pushd ~/.m2'

change-settings(){
  
  # Find all files matching ~/.m2/settings*.xml
  files=(~/.m2/settings*.xml)
  
  # Check if any files were found
  if [ ${#files[@]} -eq 0 ]; then
      echo "No files matching ~/.m2/settings*.xml were found."
      return 1
  fi
  
  # Display the files to the user and prompt them to select one
  echo "Please select a file to symlink to ~/.m2/settings.xml:"
  select file in "${files[@]}"; do
      if [ -n "$file" ]; then
          # Update the symlink to point to the selected file
          ln -sf "$file" ~/.m2/settings.xml
          echo "Symlink updated to $file"
          return 0
      else
          echo "Invalid selection."
      fi
  done

}



# Define a function to replace a string in a file
function taskid(){
    # Get the new task ID and file from function arguments
    local new_taskid="$1"
    local file="$2"

    # Check that the arguments are not empty
    if [[ -z $new_taskid || -z $file ]]; then
        echo "Error: Both the new task ID and file must be provided."
        return 1
    fi
    
    # Check that the file exists
    if [[ ! -f $file ]]; then
        echo "Error: File not found."
        return 1
    fi
    
    # Replace TASKID with the new value in the specified file
    sed -i "s/TASKID/$new_taskid/g" "$file"
    
    echo "Replacement complete."
    return 0
}

gchfiledefault(){

  local file="$1"
  if [ -z $file ]; then
    echo "enter file..."
    return 1
  fi
  git checkout $(gitdefaultbranch) $1
}


pr(){

  gh pr view $(gh pr list -L 1 --json number | jq '.[0].number') --web
}

alias echo-settings="sed 's/<password>.*<\/password>/<password>PASSWORD<\/password>/g' ~/.m2/settings.xml"



## KUBE
podget(){
  team="${1:-iot}"
  kubectl get pods -n shared-$team
}
watchpod(){
  watch -d "kubectl get pods -n shared-iot $@ "
}
podsearch(){
  team="${2:-messaging}"
  pod_name_filter="${1-}"
  kubectl get pods -n shared-$team -o=name | grep "$pod_name_filter" 
}

# Function to search for kubectl get pods and prompt user to select a pod
podlogs() {
  local pod_names
  team="iot"
  pod_name_filter=""
  container_name_filter=""

  while getopts "c:p:t:" opt; do
    case $opt in
      c)
        container_name_filter="$OPTARG"
        echo $container_name_filter
        ;;
      p)
        pod_name_filter="$OPTARG"
        echo $pod_name_filter
       ;;
      t)
        team="$OPTARG"
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done
  
  kubectl get pods -n shared-$team 
  pod_names=($(kubectl get pods -n shared-$team -o=name | grep "$pod_name_filter"))

  if [[ "${#pod_names[@]}" -eq 0 ]]; then
    echo "No pods found."
    return 1
  elif [[ "${#pod_names[@]}" -eq 1 ]]; then
    pod_name="${pod_names[0]}"
  else
    echo "Select a pod by number: "
    select pod_name in "${pod_names[@]}"; do
      if [[ -n "$pod_name" ]]; then
        break
      else
        echo "Invalid choice. Try again."
      fi
    done
  fi

  # Extract the pod name from the full reference
  pod_name="${pod_name##*/}"

  local container_names
  kubectl get pods -n shared-$team "$pod_name" 
  container_names=($(kubectl get  pods -n shared-$team "$pod_name" -o json | jq -r '.spec.containers[].name' | grep "$container_name_filter"))

  if [[ "${#container_names[@]}" -eq 0 ]]; then
    echo "No containers found in the selected pod."
    return 1
  elif [[ "${#container_names[@]}" -eq 1 ]]; then
    container_name="${container_names[0]}"
  else
    echo "Select a container by number: "
    select container_name in "${container_names[@]}"; do
      if [[ -n "$container_name" ]]; then
        break
      else
        echo "Invalid choice. Try again."
      fi
    done
  fi

  echo "kubectl logs -n shared-$team -f \"$pod_name\" -c \"$container_name\""
  kubectl logs -n shared-$team -f "$pod_name" -c "$container_name"
}

messaginglogs(){
  podlogs -t messaging $@
}

alias watch='watch '



## AWS
awsall(){
  aws help | awk '/AVAILABLE SERVICES/,/SEE ALSO/' | grep -E 'o [[:alnum:]-]+' | awk '{print $NF}'
}
awscommon(){
  cat ${toolsPath}/aws-top-commands.txt
}
awsselect(){
  aws_cmds=(`awscommon`)
  while getopts "a" opt; do
    case $opt in
      a)
        aws_cmds=(`awsall`)
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done

  select aws_cmd in "${aws_cmds[@]}" exit; do
    case $aws_cmd in
      exit)
        return
        break ;;
      *)
        echo $aws_cmd
        break ;;
    esac
  done
}

awsme(){
  aws sts get-caller-identity
}


alias set-ssh-key-permissions='chmod 600 ~/.ssh/id_*'



alias stripcolors='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'


## TMUX ##
alias tname="tmux display-message -p '#S'"


## repo code ##
gorepo(){
  repo=$(select-repo $@ | xargs)
  #echo "select-repo: <$repo>"
  if [  "${#repo[@]}" == 0 ]; then
    echo "Exit"
    return
  fi
  repo_path=${reposPath}/${repo}

  stat --format "%n" $repo_path  > /dev/null
  if [ ! $? -eq 0 ]; then
    echo "No repo returned..."
    return
  fi

  pushd $repo_path
}

code(){
  repo=($(select-repo $@ | xargs))
  if [  "${#repo[@]}" == 0 ]; then
    echo "Exit"
    return
  fi
  for r in "${repo[@]}"; do
    repo_path=${reposPath}/${r}

    stat --format "%n" $repo_path
    if [ ! $? -eq 0 ]; then
      echo "No repo returned..."
      return
    fi

    pushd $repo_path
    idea .
  done
}

context-code(){
  code ${REPO_CLONE_CONTEXT}
}
