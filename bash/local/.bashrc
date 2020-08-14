#PS1='\u@\h:\W\$ '

alias ls='ls --color=auto'

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

function scpmytop() {
  
  scp $1 devlnk:~/repos/conlib/top
}

alias gov='ssh gov' 
alias cint='ssh cint'
alias dev='ssh dev'

function ecl_port_forward() {
  cl_port=11443
  rlc_query=36000
  rlc_order=36100
  cl_opers=37000
  cl_query=36050
  cft3=ecl-corefulltest3-lnx7-dev
  cft=ecl-corefulltest-lnx7-dev

  ssh devlnk  -L ${cl_port}:ecl-corefulltest-lnx7-dev:${cl_port} -L ${rlc_query}:${cft3}:${rlc_query} -L ${rlc_order}:${cft3}:${rlc_order} -L ${cl_opers}:${cft}:${cl_opers} -L ${cl_query}:${cft}:${cl_query} 
}
function ecl_http_port_forward() {
  cl_port=11443
  rlc_query=36005
  rlc_order=36105
  cl_opers=37005
  cl_query=36055
  ip=ecl-corefulltest3-lnx7-dev

  ssh devlnk  -L ${cl_port}:ecl-corefulltest-lnx7-dev:${cl_port} -L ${rlc_query}:${ip}:${rlc_query} -L ${rlc_order}:${ip}:${rlc_order} -L ${cl_opers}:${ip}:${cl_opers} -L ${cl_query}:${ip}:${cl_query} 
}

function fg_port_forward() {

  ssh devlnk  -L 34000:elliott2-lnx7-dev:34000
}

function do_port_forward() {
  if [ "$#" -lt 3 ] ; then
    echo "Usage: ${FUNCNAME[0]} <node> <ip> <port> <local_port>" 
    return 0
  fi
  node=$1
  ip=$2
  port=$3
  local_port=$port
  if  [ "$#" == 4 ]; then
    local_port=$4
  fi

  ssh -t ${node} -L ${local_port}:${ip}:${port} "watch  echo 'Congratulations\!\!\! You are port forwarding to [${ip}:${port}], using [${node}] as an intermediary connector. Please use [localhost:${local_port}] to access your remote service'"
}

function nexus_port_forward() {
  do_port_forward devlnk ncl-nexus-lnx7-01.devlnk.net  8081 8082
}

function jenkins_port_forward() {
  url='ncl-jenkins.devlnk.net'
  port='8080'
  do_port_forward devlnk  ncl-jenkins.devlnk.net 8080 8080
}

function devlnk_self_port_forward() {
  if [ "$#" -lt 1 ] ; then
    echo "Usage: ${FUNCNAME[0]} <port> [local_port]" 
    return 0
  fi
  echo "$@"
  port=$1
  local_port=$port
  if [ "$#" == 2 ] ; then
    local_port=$2
  fi

  do_port_forward devlnk $DEVLNK $port $local_port
}

function devlnk_port_forward() {
  if [ "$#" -ne 2 ] ; then
    echo "Usage: ${FUNCNAME[0]} <ip> <port>" 
    return 0
  fi
  ip=$1
  port=$2

  do_port_forward devlnk $ip $port
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

function lexi_jenkins_port_forward() {
  devlnk_port_forward 10.93.23.63 8080
}
