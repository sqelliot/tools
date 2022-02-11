
bitbucket_ssh_clone=ssh://git@bitbucket.prod.dht.live

stashclone() {
  project=$1
  repo=$2

  git clone ssh://git@stash.ec2.local:7999/${project}/${repo}.git
}

resclone(){
  region=$(pwd | awk -F '/' '{print $(NF-1)}')
  proj=$(basename `pwd`)
  repo=$1

  git clone ssh://git@bitbucket.prod.${region}.live/${proj}/${repo}
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
