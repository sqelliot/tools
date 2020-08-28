source ${programPath}/lexi/.bashrc

function editProgramBash() {
  vim ${programPath}/$1/.bashrc; sourceBash ${programPath}/$1/.bashrc
}

