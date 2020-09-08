
alias lexi='gogit lexi'
alias lexiansible='gogit lexi/ansible'
function lexissh() {
  ssh -i ~/.ssh/lexi-admin-devlnk lexi-admin@$1
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

  echo "ansible-playbook -i env/shared -i env/$1 ${@:2}"
  ansible-playbook -i env/shared -i env/$1 ${@:2}

}

function lexifeaturebranch() {
  gitfeaturebranch BNCD1-$@
}

function dcgsa-ssh() {
  ec2go $@ dcgs-a
}
