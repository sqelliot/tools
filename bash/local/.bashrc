#PS1='\u@\h:\W\$ '

alias ls='ls --color=auto'

function scpToEuc (){ 
  if [ "$#" -ne 2 ]; then
    echo "Usage: scpToEuc <locale> <file>" 
    return 0
  fi

  scp $2 sean.elliott3@${1}:~
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

alias gradle_upload="~/repos/fast/gradlew clean build -x test uploadArchives -PfastVersion=sean -PNEXUS_REPO_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-central/ -PGRADLE_PLUGINS_REPO=https://plugins.gradle.org/m2/ -PGRADLE_PLUGINS_REPO_USERNAME='' -PGRADLE_PLUGINS_REPO_PASSWORD='' -PRELEASE_REPO_UPLOAD_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-releases/ -PSNAPSHOT_REPO_UPLOAD_URL=http://ncl-nexus-lnx7-01.devlnk.net:8081/nexus/content/repositories/ncl-snapshots/ -Dorg.gradle.jvmargs='-Xmx2048m -Xms1024m -XX:MaxPermSize=512m'"
