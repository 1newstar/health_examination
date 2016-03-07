#!/bin/sh

#--2.4 系统安全

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
LOG_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.log

time=`date +%y%m%d%H%M%S`
echo "===== "$time"===== " >> $OUT_FILE

echo "=== whether old passwd ===" >> $OUT_FILE

echo "=== User Permission ===" >> $OUT_FILE
cat /etc/passwd | awk -F: '{if ($3==0) {print $1"\t"$3}}' >> $OUT_FILE

echo "=== Nonstandard Group ===" >> $OUT_FILE
cat /etc/group >> $OUT_FILE

echo "=== Server trust relationship ===" >> $OUT_FILE
cat /etc/hosts >> $OUT_FILE 2>>$LOG_FILE
cat /etc/hosts.equiv >> $OUT_FILE 2>>$LOG_FILE
cat $HOME/.rhosts >> $OUT_FILE 2>>$LOG_FILE

echo "=== User login ip ===" >> $OUT_FILE
echo "1)user last login ip:">>$OUT_FILE
lastlog | grep -v "Never logged in"| awk '{print $3}' | cut -d"." -f1-3 | sort -u >>$OUT_FILE
echo "2)user loging ip:">>$OUT_FILE
last | awk '{print $3}' | cut -d"." -f1-3 | sort -u >>$OUT_FILE
echo "3)root login ip this month:">>$OUT_FILE
last | grep "root" | grep "May" | awk '{print $3}' | cut -d"." -f1-3 | sort -u >>$OUT_FILE
echo "4)user login ip this month:">>$OUT_FILE
last | grep "May" | awk '{print $3}' | cut -d"." -f1-3 | sort -u >>$OUT_FILE

echo "=== Cron jobs ===" >> $OUT_FILE
cd /var/spool/cron
for file in $(ls)
do
echo "################################################" >> $OUT_FILE
echo "#$file"                                           >> $OUT_FILE
echo "################################################" >> $OUT_FILE
cat $file                                               >> $OUT_FILE
echo " "                                                >> $OUT_FILE
done

echo "=== Service state ===" >> $OUT_FILE
ps -ef | grep -iE 'sshd|httpd|crond|vsftpd|gasd|xinetd|tnslsnr' >> $OUT_FILE

echo "=== Boot option ===" >> $OUT_FILE
echo "################################################" >> $OUT_FILE
echo "#rc.local"                                           >> $OUT_FILE
echo "################################################" >> $OUT_FILE
cat /etc/rc.local >> $OUT_FILE 2>>$LOG_FILE
level=`cat /etc/inittab | grep initdefault | grep -v "\#" | awk -F\: '{print $2}'`
echo "################################################" >> $OUT_FILE
echo "#rc${level}.d"                                           >> $OUT_FILE
echo "################################################" >> $OUT_FILE
ls /etc/rc.d/rc${level}.d/ | grep -v "K" >> $OUT_FILE 2>>$LOG_FILE

echo "=== Listen Port ===" >> $OUT_FILE
nmap localhost >> $OUT_FILE