#!/bin/ksh

#--2.2 (os information )系统信息

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt


echo "Now start to collect the OS information of the server!"
echo "=== 2.2 os information ===" >> ${OUT_FILE}

echo "hostname : " `hostname` >>${OUT_FILE}
echo "OS version : " `cat /etc/redhat-release` >>${OUT_FILE}
echo "OS bit : " `getconf LONG_BIT` >>${OUT_FILE}
echo "TIPTOP LANG : " `su tiptop -c 'echo $LANG'` >>${OUT_FILE}
echo "OS time : " `date '+%Y-%m-%d %H:%M:%S'` >>${OUT_FILE}
