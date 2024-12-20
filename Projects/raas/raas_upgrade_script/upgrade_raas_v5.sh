#!/bin/bash

# Usage: upgrade.sh <cluster-name> <host-class> <GPROD-ticket>
# Example:
# ./upgrade.sh dub1.raas-watson-eventstore-tier1-prod.grpn redislabs5-2017.12.05_21.16 GPROD-73288 1 2>&1 | tee dub1.raas-watson-eventstore-tier1-prod.grpn.log
#
# This script helps in upgrade to Redis version 5

set -vx
set -e
set -u
set -o pipefail
trap 'exit 8' ERR

cluster=$1
hostclass=$2
gprod=$3
ops_config="/home/ksatyamurthy/github_projects/ops-config"

echo "cluster: $cluster"
echo "hostclass: $hostclass"
echo "gprod: $gprod"


master=`ssh $cluster "sudo rladmin status nodes" | grep raas | grep master | awk '{ print $4"."substr($10,0,3)"1" }' | tr 'A-Z' 'a-z'`
slaves=`ssh $cluster "sudo rladmin status nodes" | grep raas | grep slave | awk '{ print $4"."substr($10,0,3)"1" }' | tr 'A-Z' 'a-z' | tr '\n' ' ' | sed -e 's/ $//'`

for i in $master $slaves
do
ssh $i 'echo Hello `hostname -f`'
done

[ -z "$4" ] && exit 4

if [[ 1 -eq $4 ]];
then

cd $ops_config
git pull --rebase
bin/set_hostclass $hostclass hosts/${master}.yml
for i in $slaves
do
bin/set_hostclass $hostclass hosts/${i}.yml
done
git add hosts/${master}.yml
for i in $slaves
do
git add hosts/${i}.yml
done
git diff
git commit -m "${gprod} upgrade to 5.4"
git pull --rebase && bin/ops-config-queue
bin/ready_to_roll ${master} ${slaves}

fi

cd ~/raas_upgrade

[ -f ./size_of_ccs.txt ] && rm -f size_of_ccs.txt

for i in $master $slaves
do
#check_quorum=`echo $i | grep quorum || true  | wc -l`
#if [[ $check_quorum -eq 0 ]]
if [[ ! $i =~ "quorum" ]]
then
    count=`ssh $i "sudo find /var/groupon/redislabs/persist/ccs/ -mmin -10 -type f -name 'ccs-redis.rdb'" | wc -l`

    # no more than 10% diff ?
    if [[ $count -ne 1 ]]
    then
      echo "Backup file ccs-redis.rdb not found on ${i}"
      exit 8
    fi
    ssh $i "sudo du /var/groupon/redislabs/persist/ccs/ccs-redis.rdb" | awk '{ print $1 }' >>size_of_ccs.txt
fi
done


mins=`cat size_of_ccs.txt | sort -n | head -1 `
maxs=`cat size_of_ccs.txt | sort -n | tail -1 `

#tvalue=`python -c "print ($maxs/$mins) < 1.1" | grep -c "False"`
#if ! [[ $tvalue -eq 1 ]] # size of the file, (max/min) < 1.1 continue,  else exit 8

if python -c "print ($maxs/$mins) < 1.1" | grep -c "False"
then
  echo "Backup file ccs-redis.rdb size is inconsistent."
  exit 8
fi

ssh $cluster "sudo rladmin tune cluster watchdog_profile cloud"

shards_no=`ssh $cluster "sudo rladmin status shards extra all" | grep "^db:" | wc -l`
shards_ok=`ssh $cluster "sudo rladmin status shards extra all" | grep "^db:" | grep "OK" | wc -l`
shards_na=`ssh $cluster "sudo rladmin status shards extra all" | grep "^db:" | grep "N/A" | wc -l`

if ! [[ $shards_no -eq $shards_ok && $shards_no -eq $shards_na ]]
then
  echo "Shards not ok, to debug run: sudo rladmin status shards extra all"
  exit 8
fi

dbs_no=`ssh $cluster "sudo rladmin status databases extra all" | grep "^db:" | wc -l`
dbs_na=`ssh $cluster "sudo rladmin status databases extra all" | grep "^db:" | grep -o "N/A" | wc -l`

if ! [[ $dbs_no -eq $((dbs_na / 4)) ]]
then
  echo "DBs not ok, to debug run: sudo rladmin status databases extra all"
  exit 8
fi


for i in $master $slaves
do
scp ./rolling.sh $i:
scp ./gradual_upgrade.sh $i:
done


for i in $master $slaves
do
ssh $i "bash ./rolling.sh"
done

sleep 2m
ssh $cluster "bash ./gradual_upgrade.sh"

