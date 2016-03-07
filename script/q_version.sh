#!/bin/ksh

#--4.3 数据库环境信息

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/usr/tiptop/out
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
LOG_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.log

ans4=t
ans4a=f
while [ $ans4 != $ans4a ]
do
 echo "\n accept the password of user sys : \c"
 stty -echo
 read ans4
 stty echo
 echo "\n Re-enter the password of user sys : \c"
 stty -echo
 read ans4a
 stty echo
done
echo "\n"

time=`date +%y%m%d%H%M%S`
echo "===== "$time"===== " >> $OUT_FILE

echo "=== Instance_name ===" >> $OUT_FILE
echo $ORACLE_SID >> $OUT_FILE

echo "=== Database type === " >> $OUT_FILE

echo "=== DB version ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select * from v\$version;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out | grep "Disconnected" | awk '{print $10}' >> $OUT_FILE

echo "=== DB character set ===" >> $OUT_FILE
echo $NLS_LANG >> $OUT_FILE

echo "=== DB HOME ===" >> $OUT_FILE
echo $ORACLE_HOME >> $OUT_FILE

echo "=== DB BASE ===" >> $OUT_FILE
echo $ORACLE_BASE >> $OUT_FILE

echo "=== Data store mode ===" >> $OUT_FILE

echo "=== SGA size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameter sga_max_size;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out | grep -i "sga_max_size" | awk '{print $4}' >> $OUT_FILE

echo "=== SGA advice size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select  * from V$SGA_TARGET_ADVICE;;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out  >> $OUT_FILE

echo "=== PGA size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameter pga;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out | grep -i "pga_aggregate_target" | awk '{print $4}' >> $OUT_FILE

echo "=== PGA advice size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select  PGA_TARGET_FOR_ESTIMATE as PGA_TARGET, PGA_TARGET_FACTOR,ESTD_PGA_CACHE_HIT_PERCENTAGE as c3,ESTD_OVERALLOC_COUNT as c4 from V$PGA_TARGET_ADVICE;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out >> $OUT_FILE

sqlplus 'sys/sys as sysdba' <<EOF
set echo off;
set feedback off;
set heading off;
set termout off;　
SPOOL /u1/usr/tiptop/ora_version.txt
select * from v\$version;
show parameter sga_max_size;
select  * from V\$SGA_TARGET_ADVICE;
show parameter pga;
select  PGA_TARGET_FOR_ESTIMATE as PGA_TARGET
       ,PGA_TARGET_FACTOR
       ,ESTD_PGA_CACHE_HIT_PERCENTAGE as c3
       ,ESTD_OVERALLOC_COUNT as c4
from V\$PGA_TARGET_ADVICE;
select name,log_mode from v\$database;
archive log list;
SPOOL OFF;
exit;
EOF

cat  /u1/usr/tiptop/ora_version.txt | grep "Database" 
echo "#################################################"
echo "Character set: " $NLS_LANG
echo "#################################################"
echo "Oracle home: " $ORACLE_HOME
echo "#################################################"
echo "Oracle base: " $ORACLE_BASE
echo "#################################################"
echo "Data store: " 
echo "#################################################"



