#!/usr/bin/env python3

"""
No arguments required.
"""

import paramiko 
import os
import sys
import time

f=open(os.devnull,'w')
sys.stderr=f

k = paramiko.RSAKey.from_private_key_file("/Users/ksatyamurthy/.ssh/id_rsa")
c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

shell_script="""

download_encap iptables-1.4.13 >/dev/null 2>&1
export PATH="$PATH:/usr/local/sbin/:/sbin/:/packages/encap/iptables-1.4.13/sbin"

while [[ `sudo iptables -L INPUT --line-numbers --numeric | grep REJECT | wc -l ` -ne 0  ]]
do
value=`sudo iptables -L INPUT --line-numbers --numeric | grep REJECT | head -1 | awk '{ print $1 }'`
sudo iptables -D INPUT $value

if [[ "$?" -eq 0 ]]; then
    echo "REJECT rule deleted"
fi

done

"""

all_hosts=['orders-memcache1.snc1','orders-memcache3.snc1','accounting-memcache1.snc1','accounting-memcache2.snc1','accounting-memcache3.snc1','finch-redis1.snc1','finch-redis2.snc1','finch-redis3.snc1','finch-redis4.snc1','goods-memcache.snc1','goods-memcache1.snc1','goods-memcache3.snc1','geo-taxonomy-memcached1.dub1','geo-taxonomy-memcached1.sac1','geo-taxonomy-memcached1.snc1','geo-taxonomy-memcached2.dub1','geo-taxonomy-memcached2.sac1','geo-taxonomy-memcached2.snc1','geo-taxonomy-memcached3.dub1','geo-taxonomy-memcached3.snc1','geo-taxonomy-memcached4.dub1','geo-taxonomy-memcached4.snc1','itier-getaways-extranet-memcache-app1.sac1','itier-getaways-extranet-memcache-app2.sac1','booking-engine-3rd-party-memcached1.dub1','booking-engine-3rd-party-memcached1.sac1','booking-engine-3rd-party-memcached1.snc1','booking-engine-3rd-party-memcached2.dub1','booking-engine-3rd-party-memcached2.sac1','booking-engine-3rd-party-memcached2.snc1','booking-engine-api-memcached1.sac1','booking-engine-api-memcached1.snc1','booking-engine-api-memcached2.sac1','booking-engine-api-memcached2.snc1','booking-engine-appointments-memcached1.dub1','general-redis2.snc1','badges-redis2.dub1']

print(f"""hostname|stdout|stderr|return_code""")

for hostx in all_hosts:
    try:
        c.connect( hostname = hostx, username = "ksatyamurthy", pkey = k, timeout=20)
        stdin , stdout, stderr = c.exec_command(shell_script)
        cmd_output1=stdout.read().decode()
        return_code1=stdout.channel.recv_exit_status()
        err_output1=stderr.read().decode()
        stdin.close()
        c.close()

        # to remove duplicate hostnames, rename to localhost
        # tmpstring=cmd_output1.rstrip('\n').replace('\n',',').replace('|','')
        # tmpset=set(tmpstring.split(','))
        # if(hostx in tmpset):
        #     # print("INFO: same hostname")
        #     tmpset.remove(hostx)
        #     tmpset.add('localhost')
        # tmplist=list(tmpset)
        # tmplist.sort()
        # cmd_output2=','.join(tmplist)

        cmd_output2=cmd_output1.rstrip('\n').replace('\n',',').replace('|','')
        err_output2=err_output1.replace('\n','').replace('|','')


        print(f"""{hostx}|{cmd_output2}|{err_output2}|{return_code1}""")
        # time.sleep(1)
    except Exception as e:
        print(f"""{hostx}|-|{e}|255""")


