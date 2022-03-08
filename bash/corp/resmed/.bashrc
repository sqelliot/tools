
bitbucket_ssh_clone=ssh://git@bitbucket.prod.dht.live

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
