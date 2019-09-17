#!/bin/bash
# .bashrc

# self-source
awsBash=~/repos/tools/bash/aws/.bashrc
alias editAwsBash='vim ${awsBash}; source ${awsBash}'
alias sourceAwsBash='source ${awsBash}'

export PGPASSWORD=fcms_pass
alias ap='ansible-playbook -vv'

function psqlconnect() {
  ip=$1
  echo 'Connecting to ${ip}'
  source /opt/rh/rh-postgresql96/enable && psql --host=$1 --port=5432 --username=fcms_admin --dbname=user_profile_db
}

function hspsqlconnect() {
  ip=$1
  echo 'Connecting to ${ip}'
  source /opt/rh/rh-postgresql96/enable && psql --host=$1 --port=5432 --username=fcms_hs_db --dbname=hs_db --password
}

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

## cl: command lineup
function ec2lookup(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,LaunchTime,InstanceId,Placement.AvailabilityZone] | sort_by(@,&[4])' --output table
}

function ec2count(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" --filters "Name=instance-state-name,Values=running"  --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value] | sort_by(@,&[0])' --output text | nl
}

function ec2filter(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" 
}

function elb(){
  name=$1
  aws elb describe-load-balancers --load-balancer-names *${name}* --query 'LoadBalancerDescriptions[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Placement.AvailabilityZone]' --output table
}

function ec2kill(){
  aws ec2 terminate-instances --instance-ids $@
}

function ec2instanceIds() {
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" --query 'Reservations[].Instances[].[InstanceId]' --output text
}

function ec2instanceIps() {
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" --query 'Reservations[].Instances[].[PrivateIpAddress]' --output text
}

function volume_usage(){
  sum=0
  vals=$(aws ec2 --describe-volumes --filters "Name=tag:Name,Values=*$1*" --query)
}

function elb_instances() {
  name=$1
  aws elb describe-instance-health --load-balancer-name ${name}
}
