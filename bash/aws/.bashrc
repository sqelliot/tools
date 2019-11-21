#!/bin/bash
# .bashrc

# self-source
awsBash=~/repos/tools/bash/aws/.bashrc
alias editAwsBash='vim ${awsBash}; source ${awsBash}'
alias sourceAwsBash='source ${awsBash}'

# keys
cint=/etc/ansible/keypairs/fcms-cint-99.pem
dev=/etc/ansible/keypairs/fcms-dev-99.pem

export PGPASSWORD=fcms_pass

function ap() {
  dt=$(date '+%d%m%Y-%H:%M:%S');
  ansible-playbook -vv $@ | tee /tmp/ansible-logs-${dt}.txt
}

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

function ec2ssh() {
  key=$(getEucaKey)
  ssh -i $key cloud-user@$1 ${@:2}
}

function ec2sshdefault() {
  key=$(getEucaKey)
  ssh -i $key cloud-user@$_sship ${@:2}
}

function curl_auth_instance(){
  curl -vk --cert /home/users/sean.elliott3/certs/valid.user.crt --key /home/users/sean.elliott3/certs/valid.user.key "https://$1:16539/fcms-admin/console/#/headers/"
}


function ec2subsystem(){
  subsystem=$1
  aws ec2 describe-instances --filter "Name=tag:Name,Values=fcms-*-99-${subsystem}*" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text
}

## cl: command lineup
function ec2lookup(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}*" "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,LaunchTime,InstanceId,Placement.AvailabilityZone] | sort_by(@,&[4])' --output table
}

function ec2me() {
  ec2lookup sean_elliott3
}

function ec2count(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --filters "Name=instance-state-name,Values=running"  --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value] | sort_by(@,&[0])' --output text | nl
}

function ec2filter(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" 
}

function elb(){
  name=$1
  aws elb describe-load-balancers --load-balancer-names ${name} --query 'LoadBalancerDescriptions[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Placement.AvailabilityZone]' --output table
}

function ec2terminate(){
  aws ec2 terminate-instances --instance-ids $@
}

function ec2terminatebyquery(){
  aws ec2 terminate-instances --instance-ids $(ec2instanceIds $1)
}

function ec2terminatebyquery() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ec2terminatebyquery <name>" 
    return 0
  fi
  ec2terminate $(ec2instanceIds $1)
}

function ec2instanceIds() {
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --query 'Reservations[].Instances[].[InstanceId]' --output text
}

function ec2instanceIps() {
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --query 'Reservations[].Instances[].[PrivateIpAddress]' --output text
}

function ec2instanceInfo() {
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,PrivateIpAddress]' --output text
}

function volume_usage(){
  sum=0
  vals=$(aws ec2 --describe-volumes --filters "Name=tag:Name,Values=*$1*" --query)
}

function elb_instances() {
  name=$1
  aws elb describe-instance-health --load-balancer-name ${name}
}

function scptoinstance (){ 
  if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage: scptoinstance <file> <ip> [dstPath]"
    return 0
  fi
  dstPath=~
  if  [ "$#" == 3 ]; then
    dstPath=$3
  fi
  key=$(getEucaKey)
  ip=$1
  file=$2
  echo "here"
  scp -q -i $key  $file cloud-user@${ip}:~ && ec2ssh ${ip} "sudo  mv ${file} ${dstPath}"
}

function ec2enilookup() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ec2enilookup <name>"
    return 0
  fi
  name=$1
  aws ec2 describe-network-interfaces --filters "Name=description,Values=*${name}*" --query NetworkInterfaces[].NetworkInterfaceId --output text
}

function ec2deleteenis() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ec2deleteenis <name>"
    return 0
  fi
  name=$1
  echo "Ok......."
  for i in $(ec2enilookup ${name});
  do 
      echo ${i}
      aws ec2 delete-network-interface --network-interface-id ${i};
  done
}

function getEucaKey() {
  if [[ -f "$dev" ]];then
      echo $dev
  else
      echo $cint
  fi
}

function ec2sshsearch() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ec2sshsearch <name>"
    return 0
  fi
  name=$1
  count=0
  _instanceNames=()
  _instanceIps=()

  info=$(ec2instanceInfo "$name*" )
  while IFS= read -r line; 
  do  
    instanceName=$(echo $line | awk '{print $1}');
    instanceIp=$(echo $line | awk '{print $2}');
    _instanceNames+=($instanceName)
    _instanceIps+=($instanceIp)
    echo -e "\t$count: \t$instanceName"
    count=$(($count+1))
  done <<< "$info"

  if [ $count == 0 ]; then
      echo "\nNo instances match $name"
      return
  elif [ $count == 1 ]; then
    read -p "ssh to instance? (y/n): " response
      if [ "$response" == "y" ]; then
         ec2ssh $instanceIp 
      fi
  else
    read -p "ssh to instance (0...$count): " response
    if [ $response -ge 0 ] && [ $response -le $count ];then
      echo
      echo "Going to (${_instanceNames[$response]})"
      ec2ssh ${_instanceIps[$response]}
    fi
  fi

  echo
  echo "Done..."

}
