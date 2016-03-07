#########################################################################
# File Name: information.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2016年03月06日 星期日 17时57分03秒
#########################################################################
#!/bin/bash
#!/bin/bash
echo "Network Info:"`lspci |grep Ethernet`
echo "IP:"`ifconfig |grep "inet addr"|grep -v 127.0.0.1|awk '{print $2}'|awk -F ':' '{print $2}'`
echo "Product Name:"`dmidecode |grep Name`
echo "CPU Numbers:"`dmidecode |grep -i cpu|awk -F ':' '{print $2}'|wc -l`
echo "Disk Info:"`fdisk -l|grep "Disk"|awk -F ',' '{print " ",$1}'`
#echo "Memory Info:"
#dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v No
echo "Memory numbers:"`dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v No|wc -l`
echo "Total Memory(G):"$((`free -m|grep Mem|awk '{print $2}'`/1000))
echo "Disk used%:"`df -h|awk -v OFS='\t' '{print $6,$5}'`
echo  "00 00 * * * nmon -r -d -m /hadoop/monitor/log -s 60 -c 1440 -F `hostname`__`date +'%Y%m%d'`.nmon 2>&1"  >> /var/spool/cron/root
