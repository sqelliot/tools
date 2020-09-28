#!/bin/bash
# .bashrc

# keys
cint=/etc/ansible/keypairs/fcms-cint-99.pem
dev=/etc/ansible/keypairs/fcms-dev-99.pem

export PGPASSWORD=fcms_pass

# ssh history path
ssh_prev=~/.ssh_previous

function ap() {
  dt=$(date '+%d%m%Y-%H:%M:%S');
  ansible-playbook -vv $@
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

function previous_ssh() {
  echo $1 > $ssh_prev
}

function last_ssh_ip() {
  last_ip=$(head -n 1 ${ssh_prev})

  echo $last_ip
}

function last_ssh_host(){
  echo $(nslookup $(last_ssh_ip))
}
function ec2ssh() {
  previous_ssh $1
  ssh $1 ${@:2}
}

function ec2prevssh() {
  ec2ssh $(last_ssh_ip)
}

## cl: command lineup
function ec2lookup(){
  name=$1
  profile='default'
  if [ "$#" == 2 ]; then
    profile=$2
  fi
  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*${name}*" "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,LaunchTime,InstanceId,Placement.AvailabilityZone] | sort_by(@,&[4])' \
    --output table \
    --profile $profile
}

function ec2me() {
  user=$(whoami | sed 's/[^A-Za-z0-9\_-]/_/g')
  ec2lookup $user
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

function ec2terminatebyquery() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <name>" 
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
  profile='default'
  if [ "$#" == 2 ]; then
    profile=$2
  fi
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,PrivateIpAddress]' --output text --profile "$profile"
}

function volume_usage(){
  sum=0
  vals=$(aws ec2 --describe-volumes --filters "Name=tag:Name,Values=*$1*" --query)
}

function elb_instances() {
  name=$1
  aws elb describe-instance-health --load-balancer-name ${name}
}

function scptoinstance() { 
  if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage: ${FUNCNAME[0]} <file> <ip> [dstPath]"
    return 0
  fi
  dstPath=~
  if  [ "$#" == 3 ]; then
    dstPath=$3
  fi
  key=$(getEucaKey)
  ip=$2
  file=$1
  echo "here"
  scp -q -i $key  $file cloud-user@${ip}:~ && ec2ssh ${ip} "sudo  mv ${file} ${dstPath}"
}

function ec2enilookup() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <name>"
    return 0
  fi
  name=$1
  aws ec2 describe-network-interfaces --filters "Name=description,Values=*${name}*" --query NetworkInterfaces[].NetworkInterfaceId --output text
}

function ec2deleteenis() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <name>"
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

function ec2ssh() {
  noprompt=false
  while true ; do
    case "$1" in
      -n)
        noprompt=true
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  if [ "$#" -lt 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <name>"
    return 0
  fi
  name=$1
  profile=$2
  declare -a instanceNames=()
  declare -a instanceIps=()

  info=$(ec2instanceInfo "$name*" "$profile" )
  while IFS= read -r line; 
  do  
    count=$(($count+1))
    instanceName=$(echo $line | awk '{print $1}');
    instanceIp=$(echo $line | awk '{print $2}');
    instanceNames+=($instanceName)
    instanceIps+=($instanceIp)
  done <<< "$info"

  declare -a count=${#instanceNames[@]}
  echo "Number of instances found: ${count}"
  if [ $count == 0 ]; then
      echo "No instances match $name"
      return
  fi

  for i in $(seq 0 $(($count-1))); do
    echo -e "\t$i: ---------- ${instanceNames[$i]}"
  done

  if [ $count == 1 ]; then
      response="y"
      if [ ! $noprompt ]; then
        read -p "ssh to instance? (y/n): " response
      fi
      if [[ "${response,,}" == "y" || $response == 0 ]]; then
        echo "Going to (${instanceNames[$response]})"
        ec2ssh ${instanceIps[$response]}
      fi
  else
    index=$(($count-1))
    read -p "ssh to instance (0...$index): " response
    # exit for positive integer value
    if ! [[ $(isWholeNumber $response) == 0 ]]; then
      echo "Exiting ${FUNCNAME[0]}..."
      return
    fi
    if [ $response -ge 0 ] && [ $response -le $count ];then
      echo
      echo "Going to (${instanceNames[$response]})"
      ##ec2ssh ${instanceIps[$response]}
      ec2ssh ${instanceIps[$response]}
    fi
  fi

  echo
  echo "${FUNCNAME[0]} done..."

}

function ec2go () {
  ec2ssh -n $@
}
