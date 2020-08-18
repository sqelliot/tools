
alias lexi='gogit lexi'
alias lexiansible='gogit lexi/ansible'
function lexissh() {
  ssh -i ~/.ssh/lexi-admin-devlnk lexi-admin@$1
}

function lexi_jenkins_port_forward() {
  devlnk_port_forward 10.93.23.63 8080
}

function aplexi() {
  echo "ansible-playbook -i env/shared -i env/$1 ${@:2}"
  ansible-playbook -i env/shared -i env/$1 ${@:2}

}
