#!/bin/sh

#--2.5系统日志

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
LOG_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.log

time=`date +%y%m%d%H%M%S`
echo "===== "$time"===== " >> $OUT_FILE

echo "=== Hardware log ===" >> $OUT_FILE
dmesg | grep -iE 'err|warn|fault' >> $OUT_FILE

echo "=== Ftp log ===" >> $OUT_FILE
grep -iE 'err|warn|fault' /var/log/xferlog* >> $OUT_FILE

echo "=== Cron log ===" >> $OUT_FILE
grep -iE 'err|warn|fault' /var/log/cron* >> $OUT_FILE

echo "=== Web log ===" >> $OUT_FILE
for file in $(ls /var/log/httpd/*error*)
do
echo "################################################" >> $OUT_FILE
echo "#$file"                                           >> $OUT_FILE
echo "################################################" >> $OUT_FILE
cat $file                                               >> $OUT_FILE
echo " "                                                >> $OUT_FILE
done

echo "=== Samba log ===" >> $OUT_FILE
sambapro=`ps -ef | grep smb | grep -v grep`
    if [ -z $sambapro ]; then
        echo "Samba was not start." >> $OUT_FILE

    else 
        echo $sambapro >> $OUT_FILE
    fi

grep -ihE 'err|warn|fault' /var/log/samba/* >> $OUT_FILE 2>>$LOG_FILE