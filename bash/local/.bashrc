#PS1='\u@\h:\W\$ '

alias ls='ls --color=auto'

alias selliott='ssh selliott@elliott2-lnx7-dev.devlnk.net'
function scptoeuc (){ 
  if [ "$#" -ne 1 ]; then
    echo "Usage: scpToEuc <file>" 
    return 0
  fi

  scp $1 dev:~
}

function scphoptoeuc (){ 
  if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage: scphoptoEuc <file> <ip> [dstPath]" 
    return 0
  fi
  dstPath=~
  if  [ "$#" == 3 ]; then
    dstPath=$3
  fi
  filepath=$1
  ip=$2
  filename=$(basename ${filepath})

  scptoeuc $filepath  && ssh dev "scptoinstance ${ip} ${filename} ${dstPath}; rm ${filename}"
}

alias gov='ssh gov' 
alias cint='ssh cint'
alias dev='ssh dev'

function do_port_forward() {
  if [ "$#" -ne 4 ] ; then
    echo "Usage: port_forward <node> <ip> <port> <local_port>" 
    return 0
  fi
  node=$1
  ip=$2
  port=$3
  local_port=$port
  if  [ "$#" == 4 ]; then
    local_port=$4
  fi

  ssh ${node} -L ${local_port}:${ip}:${port}
}

function nexus_port_forward() {
  echo "do_port_forward devlnk ncl-nexus-lnx7-01.devlnk.net 8081 8081"
  do_port_forward devlnk ncl-nexus-lnx7-01.devlnk.net  8081 8081
}

function port_forward() {
  if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage: port_forward <ip> <port> [local_port]" 
    return 0
  fi
  node=dev
  ip=$1
  port=$2
  local_port=$port
  if  [ "$#" == 3 ]; then
    local_port=$3
  fi

  do_port_forward $node $ip $port $local_port
}

function ml_forward() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ml_forward <ip>" 
    return 0
  fi
  ip=$1
  port=8000

  port_forward $ip $port
}

function runremote() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: run_remote <node> <command>" 
    return 0
  fi
  node=$1
  _command=${@:2}
  
  ssh -t $node "${_command}"
}

function euca() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: run_dev <command>" 
    return 0
  fi
  
  runremote dev $@
}

