#PS1='\u@\h:\W\$ '

alias ls='ls --color=auto'

function scpcint (){ 
  scp $1 sean.elliott3@cint:~
}

alias gov='ssh gov' 
alias cint='ssh cint'
alias dev='ssh dev'

function port_forward() {
  if [ "$#" -ne 3 ]; then
    echo "Usage: port_forward <node> <ip> <port>" 
    return 0
  fi
  node=$1
  ip=$2
  port=$3

  ssh ${node} -L ${port}:${ip}:${port}
}
