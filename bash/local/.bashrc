# maven path
#export M2_HOME=/common/COTS/apache-maven-3.3.9
#export M2=$M2_HOME/bin
#export PATH=$PATH:$JAVA_PATH
#export PATH=$PATH:$M2


# terminal display
PS1='\u@\h:\W\$ '

#alias gradle='~/repos/fast/gradlew'

# self-source
#devlnkBash='/tools/bash/devlnk/.bashrc'


# ssh into dev99 public subnet
#alias dev99='ssh sean.elliott3@10.93.20.95'
alias ls='ls --color=auto'
alias cint='ssh cint'
alias dev='ssh dev'


function scpcint (){ 
  scp $1 sean.elliott3@cint:~
}

alias govaccess='ssh gov' 
function govscp() {
  scp $1 sean.elliott3@${govIP}:~
}
