
alias lexi='gogit lexi'
alias lexiansible='gogit lexi/ansible'
if [ "$goldlnk"  == true ];
then
  alias lexiansible='gogit lexi/devops/ansible'
fi

lexi_strings=(dev training large test1 test2 test3)

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

  echo "ansible-playbook -v -i env/shared -i env/$1 ${@:2} -e 'log_path=./ansible.log'"
  ansible-playbook -v -i env/shared -i env/$1 ${@:2}

}

function lexiclone() {
  gitclone e2eisr $1
}

function lexifeaturebranch() {
  gitfeaturebranch BNCD1-$@
}

function dcgsa-ssh() {
  ec2go $@ dcgs-a
}

function lexi-remote-gitlab() {
  git remote add gitlab https://sean.elliott@git.proposal01.com/development/${PWD##*/}.git
}

function bahgo() {
  ec2go $@ bah
}

function dcgsa-lookup() {
  ec2lookup $@ "dcgs-a"
}
