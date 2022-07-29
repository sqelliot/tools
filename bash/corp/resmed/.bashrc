#!/bin/bash

export STASH_BB_HOST='stash.ec2.local'
export STASH_BB_PORT=7999
export STASH_BB_HOST_PORT="${STASH_BB_HOST}:${STASH_BB_PORT}"
export RMDEU_BB_IDENTIFIER='rmdeu'
export DHT_BB_IDENTIFIER='dht'
export GIT_CLONE_SSH_PREFIX='ssh://git@'

export DHT_SHON_TOKEN_PATH='~/dev/bitbucket/dht-shon-token'
export STASH_SHON_TOKEN_PATH='~/dev/bitbucket/stash-shon-token'

rmdReposPath=${reposPath}/resmed

bb_host(){
  bb_identifier=$1
  echo "bitbucket.prod.${bb_identifier}.live"
}

stashclone() {
  project=$1
  repo=$2

  git clone ssh://git@stash.ec2.local:7999/${project}/${repo}.git
}

bb-get-projects(){
  site_identifier=$1
  token=$(cat ~/dev/bitbucket/${site_identifier}-shon-token)
  host=$(bb-site-identifier-host ${site_identifier})
  curl --silent \
       -H "Accept: application/json" \
       -H "Authorization: Bearer ${token}" \
       https://${host}/rest/api/1.0/projects
}

bb-projects(){
  site_identifier=$1
  response_json=$(bb-get-projects ${site_identifier})
  echo ${response_json} | jq -r '.values[] | [.key, .name] | @tsv'  |
    while IFS=$'\t' read -r key name; do
      printf "%-8s%-20s\n" "${key}" "${name}";
    done
}


bb-site-identifier-host(){
  site_identifier=$1
  case $site_identifier in
    stash)
      host=${STASH_BB_HOST}
      ;;
    dht|rmdeu)
      host=$(bb_host ${site_identifier})
      ;;
    *)
      echo "no matching site identifier"
      ;;
  esac
  echo $host
}

## TODO: make this generic. just add hosting sites.
## use a case statement
resclone(){
  bb_identifier=$(pwd | awk -F '/' '{print $(NF-1)}')
  proj=$(basename `pwd`)
  repo=$1

  if [ "${bb_identifier}" == "stash" ]; then
    host="${STASH_BB_HOST_PORT}"
  else
    host=$(bb_host ${bb_identifier})
  fi

  res_url="${GIT_CLONE_SSH_PREFIX}${host}/${proj}/${repo}"

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
