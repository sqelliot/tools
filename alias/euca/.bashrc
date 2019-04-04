#!/bin/bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# self-source
eucaBash='/tools/alias/euca/.bashrc'
alias editEucaBash='vim ~/${eucaBash}; source ~/${eucaBash}'
alias sourceEucaBash='source ~/${eucaBash}'

# source the shared .basrhc
shared='/tools/alias/shared/.bashrc'
source ~/${shared}


alias which='which '
export PGPASSWORD=fcms_pass
#sudo yum install rh-postgres96
#source /opt/rh/rh-postgresql96/enable

function psqlconnect() {
  ip=$1
  echo 'Connecting to ${ip}'
  source /opt/rh/rh-postgresql96/enable && psql --host=$1 --port=5432 --username=fcms_admin --dbname=user_profile_db
}


alias editBashrc='vim ~/.bashrc; echo '\''SOURCE THAT FILE'\''; source ~/.bashrc'

alias ap='ansible-playbook -vv'




function cintssh() {
  ssh -i /etc/ansible/keypairs/fcms-cint-99.pem cloud-user@$1
}

function devssh() {
  ssh -i /etc/ansible/keypairs/fcms-dev-99.pem cloud-user@$1
}


function curl_auth_instance(){
  curl -vk --cert /home/users/sean.elliott3/certs/valid.user.crt --key /home/users/sean.elliott3/certs/valid.user.key "https://$1:16539/fcms-admin/console/#/headers/"
}


function all_subsystem_instances_by_name(){
  subsystem=$1
  aws ec2 describe-instances --filter "Name=tag:Name,Values=fcms-*-99-${subsystem}*" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text
}

function clinstlookup(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Placement.AvailabilityZone]' --output table
}

function clinstfilter(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" 
}

function celb(){
  name=$1
  aws elb describe-load-balancers --load-balancer-names *${name}* --query 'LoadBalancerDescriptions[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Placement.AvailabilityZone]' --output table
}

function clkillinst(){
  aws ec2 terminate-instances --instance-ids $@
}
