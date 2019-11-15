#PS1='\u@\h:\W\$ '

alias ls='ls --color=auto'

function scptoeuc (){ 
  if [ "$#" -ne 1 ]; then
    echo "Usage: scpToEuc <file>" 
    return 0
  fi

  scp $1 sean.elliott3@dev:~
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

  scptoeuc $filepath  && ssh dev "scptoinstance ${ip} ${filename} ${dstPath} && rm ${filename}"
}

alias gov='ssh gov' 
alias cint='ssh cint'
alias dev='ssh dev'

function port_forward() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: port_forward <ip> <port>" 
    return 0
  fi
  node=dev
  ip=$1
  port=$2

  ssh ${node} -L ${port}:${ip}:${port}
}

function ml_forward() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: ml_forward <node> <ip>" 
    return 0
  fi
  node=$1
  ip=$2
  port=8000

  ssh ${node} -L ${port}:${ip}:${port}
}

function runCommandOnDev() {
  if [ "$#" -lt 1 ]; then
    echo "Usage: run_command_on <command>" 
    return 0
  fi
  node=dev
  _command=$@
  
  ssh $node "${_command}"
}

alias gradle_upload="~/repos/fast/gradlew clean build -x test uploadArchives -PfastVersion=sean -PNEXUS_REPO_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-central/ -PGRADLE_PLUGINS_REPO=https://plugins.gradle.org/m2/ -PGRADLE_PLUGINS_REPO_USERNAME='' -PGRADLE_PLUGINS_REPO_PASSWORD='' -PRELEASE_REPO_UPLOAD_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-releases/ -PSNAPSHOT_REPO_UPLOAD_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-snapshots/ -Dorg.gradle.jvmargs='-Xmx2048m -Xms1024m -XX:MaxPermSize=512m'"
