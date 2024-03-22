#!/bin/bash

export STASH_BB_HOST='stash.ec2.local'
export STASH_BB_PORT=7999
export STASH_BB_HOST_PORT="${STASH_BB_HOST}:${STASH_BB_PORT}"
export GITHUB_HOST='github'
export RMDEU_BB_IDENTIFIER='rmdeu'
export DHT_BB_IDENTIFIER='dht'
export GIT_CLONE_SSH_PREFIX='ssh://git@'
rmdReposPath=${reposPath}/rmd

export github_resmed_path=${rmdReposPath}/github

export DHT_SHON_TOKEN_PATH='~/dev/bitbucket/dht-shon-token'
export STASH_SHON_TOKEN_PATH='~/dev/bitbucket/stash-shon-token'


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
  git_host_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${git_host_identifier})

  echo "https://ptfe.prod.${git_host_identifier}.live/app/resmed/workspaces/${repo_name}"
}

browse-workspace(){
  firefox $(workspace-link-from-path)
}

browse-repo(){
  wslview $(repo-link-from-path)

}

browse-branch(){
  isgit || return 1
  source_branch="refs/heads/$(gitbranch)"
  firefox "$(repo-link-from-path)/compare/diff?sourceBranch=$(echo $source_branch | sed 's/\//%2F/g')"
}

search-workspace(){
  repo_path=`pwd`
  if [ -n "$1" ]; then
    repo_path=$1
  fi

  repo_name=$(basename ${repo_path})
  project_name=$(echo `pwd` | awk -F '/' '{print $(NF-1)}')
  git_host_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${git_host_identifier})

  firefox "https://ptfe.prod.${git_host_identifier}.live/app/resmed/workspaces?search=${repo_name}"
}

repo-link-from-path(){
  repo_path=`pwd`

  repo_name=$(basename ${repo_path})
  project_name=$(echo `pwd` | awk -F '/' '{print $(NF-1)}')
  git_host_identifier=$(echo `pwd` | awk -F '/' '{print $(NF-2)}')

  host=$(bb-site-identifier-host ${git_host_identifier})

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
      host=${STASH_BB_HOST_PORT}
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
  git_host_identifier=$(pwd | awk -F '/' '{print $(NF-1)}')
  proj=$(basename `pwd`)
  repo=$1
  clone_command='gh clone'


  result=0
  case $git_host_identifier in
    stash|dht)
      host=`bb-site-identifier-host $git_host_identifier`
      clone_command='git clone'
      res_url="${GIT_CLONE_SSH_PREFIX}${host}/${proj}/${repo}"
      echo "res_url: $res_url"
      git clone $res_url
      result=$?
      ;;
    github)
      host="${GITHUB_HOST}"
      proj=resmed
      res_url=resmed/$repo
      gh repo clone resmed/$repo
      result=$?
      ;;
  esac

  if [ "${result}" -ne 0 ]; then
    echo "clone failed..."
    return 1
  fi
      

  export REPO_CLONE_CONTEXT=${repo}
  pushd $repo
  read -p "Open in IntelliJ? (y/n) " answer

  if [[ "$answer" == "y" ]]; then
        code "$repo"
      else
            echo "Skipping IntelliJ launch."
  fi
}

## GENERIC
repos(){
  local use_full_path=0
#  while getopts "f" opt; do
#    case $opt in
#      f)  
#        use_full_path=0
#        ;;
#      \?) 
#        echo "not a recognized flag"
#        ;;
#      :)  
#        echo "Option -$OPTARG requires an argument." >&2
#        exit 1
#        ;;
#    esac
#   done
#   shift $((OPTIND-1))

  local file_pattern="${1:-*}"
  local dir_name="${2:-*}"
  
  find ${reposPath} -maxdepth 4  -mindepth 4 -type d ! -name '.*' -name "*${file_pattern}*" -path "*/$dir_name/*" \
    | if [ ${use_full_path} -eq 0 ]; then sed "s|^$reposPath||"; else cat; fi \
    | sort

}



select-repo(){
  repos_list=($(repos $@  | xargs))
  if [ "${#repos_list[@]}" -eq 1 ]; then
    echo "${repos_list[0]}"
    return

  fi

  select repo in "${repos_list[@]}" all exit; do
    case $repo in
      exit)
        break ;;
      all)
        echo "${repos_list[@]}"
        break ;;
      *)
        echo $repo;
        break ;;
    esac;
  done
}



rmd() {

  pushd ${rmdReposPath}
}

rmdgh(){
  pushd ${rmdReposPath}/github
}
alias github='rmdgh'

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

alias myokta='firefox https://resmed.okta.com'
alias mcs='cd ${reposPath}/rmd/github/mcs'
ghclone() {
  gh repo clone resmed/$1
}


alias messagingpods='kubectl get pods -n shared-messaging'



## saml2aws configure
configure-saml2aws(){
  profile=$1
  url=$2
  region="${3:-us-west-2}"

  saml2aws configure \
    --idp-account="${profile}" \
    --profile="${profile}" \
    --url=$url \
    --username=sean.elliott@resmed.com \
    --idp-provider=Okta \
    --mfa=Auto \
    --session-duration=28800 \
    --skip-prompt \
    --region=$region 
}

init-sam2aws-configs(){
  echo "nonprod-global"
  configure-saml2aws nonprod-global https://resmed.okta.com/home/amazon_aws/0oa4hc1t74n8BBFxv2p7/272
  echo "prod-global"
  configure-saml2aws prod-global https://resmed.okta.com/home/amazon_aws/0oa4hbysofL5S7RbG2p7/272
  echo "nonprod-eu"
  configure-saml2aws nonprod-eu https://resmed.okta.com/home/amazon_aws/0oabej0gdfNbZ4j7u2p7/272 eu-central-1
}
