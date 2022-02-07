stashclone() {
  project=$1
  repo=$2

  git clone ssh://git@stash.ec2.local:7999/${project}/${repo}.git
}

resmed() {

  pushd ${reposPath}/resmed
}
