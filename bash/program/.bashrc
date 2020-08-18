source ${programPath}/lexi/.bashrc

function editProgramBash() {
  vim ${programPath}/$1/.bashrc; source ${programPath}/$1/.bashrc
}

