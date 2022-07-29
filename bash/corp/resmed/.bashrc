
bitbucket_ssh_clone=ssh://git@bitbucket.prod.dht.live

rmdReposPath=${reposPath}/resmed

stashclone() {
  project=$1
  repo=$2

  git clone ssh://git@stash.ec2.local:7999/${project}/${repo}.git
}

resclone(){
  bb_identifier=$(pwd | awk -F '/' '{print $(NF-1)}')
  proj=$(basename `pwd`)
  repo=$1

  if [ "${bb_identifier}" == "stash" ]; then
    res_url=ssh://git@stash.ec2.local:7999/${proj}/${repo}.git
  else
    res_url=ssh://git@bitbucket.prod.${bb_identifier}.live/${proj}/${repo}
  fi

  git clone --depth 1 --no-single-branch ${res_url}
}

res-repos(){
  name="*"
  if [ -n "$1" ]; then
    name="*$1*"
  fi
  find ~/dev/repos/resmed -maxdepth 3 -mindepth 3 \( -name ".*" -prune \) -o \( -iname "${name}" -type d -print \) | awk -F '/'  '{print $(NF-2)"'/'"$(NF-1)"'/'"$NF}' | sort
}

select-res-repo(){
  name_includes=$1
  select repo in $(res-repos $name_includes) exit; do
    case $repo in
      exit)
        break ;;
      *)
        echo $repo;
        break ;;
    esac;
  done
}

res-idea(){
  repo=$(select-res-repo $1)
  repo_path=${rmdReposPath}/${repo}

  stat $repo_path 2>/dev/null >/dev/null
  if [ ! $? -eq 0 ]; then
    echo "No repo returned..."
    return
  fi

  idea $repo_path
}

#dhtclone(){
#  rmclone dht $1 $2
#}
#
#rmdeuclone(){
#  rmclone rmdeu $1 $2
#}

resmed() {

  pushd ${reposPath}/resmed
}

dht(){
  pushd ${reposPath}/resmed/dht
}

rmdeu(){
  pushd ${reposPath}/resmed/rmdeu
}

restash(){
  pushd ${reposPath}/resmed/stash
}

resmed_tree(){
  resmed
  tree -d -L 3
  popd
}

resmed_find(){
  resmed >/dev/null
  find . -maxdepth 3 -mindepth 3 -type d -name "[!.]*"
  popd >/dev/null
}


fly-login(){
  fly -t $1 login -b
}

alias fly-login-sparrow-dev='fly -t sparrow_dev login -b'
alias fly-sparrow-dev='fly -t sparrow_dev '

cf-login(){
  cf login --sso -o sparrow -s $1
}
