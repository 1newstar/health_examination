#!/bin/ksh -eu
#--检测系统硬件信息

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
OUT_FILE=$HOME_OUT/${SERIAL_NUM}_${THIS}_${RUN_DATE}
LOG_FILE=$HOME_LOG/${SERIAL_NUM}_${THIS}_${RUN_DATE}.log
rm -f ${OUT_FILE}*
rm -f ${LOG_FILE}*

#echo $THIS
#echo $RUN_TIME
#echo $OUT_FILE
#echo $LOG_FILE

echo "Now start to collect the hardware information of the server!"

#--CPU info


CORE_CNT=`cat /proc/cpuinfo  | grep "model name" | wc -l`
CORE_VSN=`cat /proc/cpuinfo  | grep "model name" | awk -F: '{print $2}' | sed 's/^ //' | tr -s ' ' | uniq`
LONG_BIT=`getconf LONG_BIT`

printf "#--CPU info\n" >> ${OUT_FILE}_cpuinfo.rpt
printf "主机CPU型号 : $CORE_VSN\n" >> ${OUT_FILE}_cpuinfo.rpt
printf "主机CPU核数 : $CORE_CNT\n" >> ${OUT_FILE}_cpuinfo.rpt
printf "主机CPU位数 : $LONG_BIT\n" >> ${OUT_FILE}_cpuinfo.rpt

#--Memory info

MEM_CNT=`dmidecode | grep -P -A16 "Memory\s+Device" | grep Size | grep -v Range | wc -l`
#MEM_TYPE=`dmidecode | grep -P -A16 "Memory\s+Device" | grep "Type:" | awk -F: '{print $2}' | sed 's/^ //' | tr -s ' '|uniq`
MEM_SZE=`dmidecode | grep -P -A16 "Memory\s+Device" | grep Size | grep -v Range |awk -F: '{print $2}' | sed 's/^ //'`
MEM_SPD=`dmidecode | grep -P -A16 "Memory\s+Device" | grep Speed | awk -F: '{print $2}' | sed 's/^ //'`

printf "#--Memory info\n" >> ${OUT_FILE}_meminfo.rpt
printf "主机内存数量 : $MEM_CNT\n" >> ${OUT_FILE}_meminfo.rpt
printf "各条内存大小 : \n$MEM_SZE\n" >> ${OUT_FILE}_meminfo.rpt
printf "各条内存频率 : \n$MEM_SPD\n" >> ${OUT_FILE}_meminfo.rpt

#--Network card info

NET_CNT=`kudzu --probe --class=network | grep desc | awk -F: '{print $2}' | sed 's/^ //' | sed 's/"//' | wc -l`
NET_VSN=`kudzu --probe --class=network | grep desc | awk -F: '{print $2}' | sed 's/^ //' | sed 's/"//g'`

printf "#--Network card info\n" >> ${OUT_FILE}_netinfo.rpt
printf "主机网卡数量 : $NET_CNT\n" >> ${OUT_FILE}_netinfo.rpt
printf "各块网卡信息 :\n$NET_VSN\n" >> ${OUT_FILE}_netinfo.rpt 

#--I/O info

printf "#--I/O info\n" >> ${OUT_FILE}_hdiskinfo.rpt
#time dd if=/dev/zero of=/u3/wtest.out bs=8192 count=200000 >> ${OUT_FILE}_hdiskinfo.rpt 2>>$LOG_FILE
hdparm -Tt /dev/sda >> ${OUT_FILE}_hdiskinfo.rpt 2>>$LOG_FILE

#--Gather all the hardware info to generate the final report
for file in $(ls -t ${OUT_FILE}*)
do
  cat $file >> ${OUT_FILE}.rpt
  echo "  " >> ${OUT_FILE}.rpt
done

printf "\n\n硬件报告 :\t ${OUT_FILE}.rpt\n"
exit 0