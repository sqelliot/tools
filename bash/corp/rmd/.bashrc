#!/bin/bash

export STASH_BB_HOST='stash.ec2.local'
export STASH_BB_PORT=7999
export STASH_BB_HOST_PORT="${STASH_BB_HOST}:${STASH_BB_PORT}"
export RMDEU_BB_IDENTIFIER='rmdeu'
export DHT_BB_IDENTIFIER='dht'
export GIT_CLONE_SSH_PREFIX='ssh://git@'

export DHT_SHON_TOKEN_PATH='~/dev/bitbucket/dht-shon-token'
export STASH_SHON_TOKEN_PATH='~/dev/bitbucket/stash-shon-token'

rmdReposPath=${reposPath}/rmd

bb_host(){
  bb_identifier=$1
  echo "bitbucket.prod.${bb_identifier}.live"
}

stashclone() {
  project=$1
  repo=$2

  git clone ssh://git@stash.ec2.local:7999/${project}/${repo}.git
}

workspace-link-from-path(){
  repo_path=`pwd`
  if [ -n "$1" ]; then
    repo_path=$1
  fi

  repo_name=$(basename ${repo_path})
  project_name=$(echo `pwd` | awk -F '/' '{print $(NF-1)}')
  bb_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${bb_identifier})

  echo "https://ptfe.prod.${bb_identifier}.live/app/resmed/workspaces/${repo_name}"
}

browse-workspace(){
  browse $(workspace-link-from-path)
}

browse-repo(){
  browse $(repo-link-from-path)

}

browse-branch(){
  source_branch="refs/heads/$(gitbranch)"
  browse "$(repo-link-from-path)/compare/diff?sourceBranch=$(echo $source_branch | sed 's/\//%2F/g')"
}

search-workspace(){
  repo_path=`pwd`
  if [ -n "$1" ]; then
    repo_path=$1
  fi

  repo_name=$(basename ${repo_path})
  project_name=$(echo `pwd` | awk -F '/' '{print $(NF-1)}')
  bb_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${bb_identifier})

  browse "https://ptfe.prod.${bb_identifier}.live/app/resmed/workspaces?search=${repo_name}"
}

repo-link-from-path(){
  repo_path=`pwd`

  repo_name=$(basename ${repo_path})
  project_name=$(echo `pwd` | awk -F '/' '{print $(NF-1)}')
  bb_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${bb_identifier})

  echo "https://${host}/projects/${project_name}/repos/${repo_name}"
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
  echo "Cloning from ${res_url}"

  git clone --depth 1 --no-single-branch ${res_url}
  
  export REPO_CLONE_CONTEXT=${repo}
}

## GENERIC
repos(){
  name="*"
  if [ -n "$1" ]; then
    name="*$1*"
  fi
  find ${reposPath} -maxdepth 4 -mindepth 4 \( -name ".*" -prune \) -o \( -iname "${name}" -type d -print \) | awk -F '/'  '{print $(NF-3)"'/'"$(NF-2)"'/'"$(NF-1)"'/'"$NF}' | sort
}

res-repos(){
  name="*"
  if [ -n "$1" ]; then
    name="*$1*"
  fi
  find ${rmdReposPath} -maxdepth 3 -mindepth 3 \( -name ".*" -prune \) -o \( -iname "${name}" -type d -print \) | awk -F '/'  '{print $(NF-2)"'/'"$(NF-1)"'/'"$NF}' | sort
}

select-res-repo(){
  name_includes=$1
  
  ## easiesr to do the res-repos call twice than store
  count=$(res-repos $name_includes | wc -l)
  if [ $count -eq 1 ]; then
    echo $(res-repos $name_includes)
    return
  fi

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

select-repo(){
  name_includes=$1
  
  ## easiesr to do the res-repos call twice than store
  count=$(repos $name_includes | wc -l)
  if [ $count -eq 1 ]; then
    echo $(repos $name_includes)
    return
  fi

  select repo in $(repos $name_includes) exit; do
    case $repo in
      exit)
        break ;;
      *)
        echo $repo;
        break ;;
    esac;
  done
}

goto-repo(){
  repo=$(select-repo $1)
  #echo "select-repo: <$repo>"
  if [ ! -n "${repo}" ]; then
    echo "Exit"
    return 
  fi
  repo_path=${reposPath}/${repo}

  stat -c "%n" $repo_path  > /dev/null
  if [ ! $? -eq 0 ]; then
    echo "No repo returned..."
    return
  fi

  pushd $repo_path
}

code(){
  repo=$(select-repo $1)
  if [ ! -n "${repo}" ]; then
    echo "Exit"
    return 
  fi
  repo_path=${reposPath}/${repo}

  stat -c "%n" $repo_path 
  if [ ! $? -eq 0 ]; then
    echo "No repo returned..."
    return
  fi

  idea $repo_path
}

context-code(){
  code ${REPO_CLONE_CONTEXT}
}


rmd() {

  pushd ${rmdReposPath}
}

dht(){
  pushd ${rmdReposPath}/dht
}

rmdeu(){
  pushd ${rmdReposPath}/rmdeu
}

restash(){
  pushd ${rmdReposPath}/stash
}

rmd_tree(){
  rmd
  tree -d -L 3
  popd
}

rmd_find(){
  rmd >/dev/null
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
