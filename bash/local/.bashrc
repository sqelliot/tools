# maven path
export M2_HOME=/common/COTS/apache-maven-3.3.9
export M2=$M2_HOME/bin

export JAVA_HOME=/common/COTS/java/release/jdk1.8.0_66/jdk1.8.0_66-x64
export JAVA_PATH=/$JAVA_HOME/bin
export PATH=$PATH:$JAVA_PATH
export PATH=$PATH:$M2
#export GRADLE_USER_HOME=/home/users/selliott/project-git-selliott/gradle/
#export GRADLE=/home/users/selliott/project-git-selliott/gradle/gradle-5.3.1/bin/
#export PATH=$PATH:$GRADLE_USER_HOME
#export PATH=$PATH:$GRADLE
#export GRADLE4=/home/users/selliott/project-git-selliott/gradle/gradle-4.2.1/bin/
#export PATH=$PATH:$GRADLE4


# terminal display
PS1='\u@\h:\W\$ '

alias gradle='~/repos/fast/gradlew'

# self-source
devlnkBash='/tools/bash/devlnk/.bashrc'


# source the shared .basrhc
shared='/tools/bash/shared/.bashrc'
source ~/${shared}


alias intellij=/opt/selliott/idea-IC-181.5087.20/bin/idea.sh
alias repos='cd /project/git/selliott/dev/'
PATH=$PATH:/opt/selliott/sublime_text_3



# ssh into dev99 public subnet
#alias dev99='ssh sean.elliott3@10.93.20.95'
alias ls='ls --color=auto'
alias rel12='ssh -i ~/keys/m868-fcms.pem cloud-user@10.93.23.182'

alias rel-12b='ssh -i ~/keys/fcms-rel-devops.pem -p 1122 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 20" cloud-user@fcms-rel-bastion-000821152832.elb.cdc-west-2.devlnk.net'
export cint99IP=10.93.23.161
alias cint='ssh cint'
export devIP=10.93.21.16
alias dev='ssh dev'
alias devmgmt='ssh sean.elliott3@fcms-dev99-inf-mgmt-000821152832.elb.cdc-west-2.devlnk.net'
function scpcint (){ 
  scp $1 sean.elliott3@cint:~
}

alias ll='ls -l'


export rel13IP='10.93.22.31'
alias rel-13='ssh sean.elliott3@${rel13IP}'

# GOVCLOUD
export govIP=10.93.20.240
alias govaccess='ssh sean.elliott3@${govIP}'
function govscp() {
  scp $1 sean.elliott3@${govIP}:~
}

alias scpspring='scp /home/users/selliott/.m2/repository/com/baesystems/auth/service/applications/spring-reverse-proxy/99.99.T-SNAPSHOT/spring-reverse-proxy-99.99.T-SNAPSHOT.jar sean.elliott3@${cint99IP}:'

#function clone_fcms(){
#
#  # default to ncl project
#  if [ -z $2 ];
#  then
#   echo 'Default to ncl...\n'


alias editBashrc='vim ~/.bashrc; source ~/.bashrc'



