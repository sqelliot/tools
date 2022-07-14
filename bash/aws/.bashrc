#!/bin/bash
# .bashrc

# ssh history path
ssh_prev=~/.ssh_previous

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
function myssh() {
  previous_ssh $1
  ssh $1 ${@:2}
}

function ec2prevssh() {
  myssh $(last_ssh_ip)
}

## cl: command lineup
function ec2lookup(){
  name="*"
  profile="${AWS_PROFILE:-default}"
  states="running,stopped,stopping,starting"
  sort_column=0
  while true ; do
    case "$1" in
      -n)
        shift
        name=$1
        shift
        ;;
      -p)
        shift
        profile=$1
        shift
        ;;
      -s)
        shift
        states=$1
        shift
        ;;
      --sort)
        shift
        sort_column=$1
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  echo "ec2lookup -n $name -p $profile -s $states"

  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*${name}*" "Name=instance-state-name,Values=${states}" \
    --query "Reservations[].Instances[].[Tags[?Key==\`Name\`]|[0].Value,State.Name,PrivateIpAddress,PublicIpAddress,LaunchTime,InstanceId,Placement.AvailabilityZone,InstanceType] | sort_by(@,&[${sort_column}])" \
    --output table \
    --region "us-west-2" \
    --profile $profile
}

function ec2me() {
  user=$(whoami | sed 's/[^A-Za-z0-9\_-]/_/g')
  ec2lookup -n $user
}

function ec2count(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --filters "Name=instance-state-name,Values=running"  --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value] | sort_by(@,&[0])' --output text | nl
}

function ec2filter(){
  name=$1
  profile='default'
  if [ "$#" == 2 ]; then
    profile=$2
  fi
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --profile $profile
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
  aws ec2 describe-instances --filters "Name=tag:Name,Values=*${name}" --query 'Reservations[].Instances[].[InstanceId]' --output text --profile "${AWS_PROFILE:-default}"
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
  scp -q -i $key  $file cloud-user@${ip}:~ && myssh ${ip} "sudo  mv ${file} ${dstPath}"
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
        myssh ${instanceIps[$response]}
      fi
  else
    index=$(($count-1))
    read -p "ssh to instance (0...$index): " response
    # exit for positive integer value
    if ! [[ $(isWholeNumber $response) == 0 ]]; then
      echo "Exiting ${FUNCNAME[0]}..."
      return
    fi
    if [ $response -ge 0 ] && [ $response -lt $count ];then
      echo
      echo "Going to (${instanceNames[$response]})"
      ##myssh ${instanceIps[$response]}
      myssh ${instanceIps[$response]}
    fi
  fi

  echo
  echo "${FUNCNAME[0]} done..."

}

function ec2go () {
  ec2ssh -n $@
}
