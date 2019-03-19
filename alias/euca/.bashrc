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
self='/tools/alias/euca/.bashrc'
alias editEucaBash='vim ~/${self}; source ~/${self}'


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

function ipLookup(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,Placement.AvailabilityZone]' --output table
}
