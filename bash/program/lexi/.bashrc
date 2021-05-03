
alias lexi='gogit lexi'
alias lexiansible='gogit lexi/ansible'
alias lexidev='gogit lexi/development'
if [ "$goldlnk"  == true ];
then
  alias lexiansible='gogit lexi/devops/ansible'
fi

lexi_strings=(dev training large test1 test2 test3)

function lexissh() {
  ssh -i ~/.ssh/lexi-admin-devlnk lexi-admin@$1
}

lexi-dev(){
  lexissh lexi-dev-$1
}

lexiop() {
  lexissh lexi-$1-20200701
}

function lexi_jenkins_port_forward() {
  devlnk_port_forward 10.93.23.63 8080
}

function aplexi() {
  inventory=./env/$1
  if [ ! -d "$inventory" ]; then
    echo "$inventory is not an inventory directory"
    return
  fi

  # remove old ansible logs
  find /tmp -maxdepth 1 -name "ansible-sean*.log"  -type f -mtime +5 -delete

  ANSIBLE_LOG_DATE=$(date +'%Y-%m-%d-%H%M')
  export ANSIBLE_LOG_PATH="/tmp/ansible-sean-${ANSIBLE_LOG_DATE}.log"

  echo "ansible-playbook -v -i env/shared -i env/$1 ${@:2} "
  ansible-playbook -vv -i env/shared -i env/$1 ${@:2}

}

function lexiclonebackend() {
  git clone git@gitlab.devlnk.net:ike/backend/$1.git
}

function lexiclonefrontend() {
  git clone git@gitlab.devlnk.net:ike/frontend/$1.git
}

function lexifeaturebranch() {
  gitfeaturebranch BNCD1-$@
}

function dcgsa-ssh() {
  ec2go $@ dcgs-a
}

function lexi-remote-gitlab() {
  git remote add gitlab https://sean.elliott@git.proposal01.com/development/${PWD##*/}.git
  git remote -v
}

function bahgo() {
  ec2go $@ bah
}

function dcgsa-lookup() {
  ec2lookup -p "dcgs-a" "$@"
}

alias gitlab='ssh ec2-user@10.24.2.28'

lexi-script-chmod(){
   git update-index --chmod=+x deploy/cd2_findAndUploadApps.sh
}

lexi_bucket='proposal1gov-devops1-software-20180730'
