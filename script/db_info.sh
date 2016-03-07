#!/bin/ksh

#--4.3 数据库环境信息

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
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

echo "=== DB connection mode ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameter shared_servers;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out | grep -i "shared_servers" | awk '{print $3}' >> $OUT_FILE

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
echo "select  * from V\$SGA_TARGET_ADVICE;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

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
echo "select  PGA_TARGET_FOR_ESTIMATE/1024/1024 as PGA_TARGET, PGA_TARGET_FACTOR,ESTD_PGA_CACHE_HIT_PERCENTAGE as c3,ESTD_OVERALLOC_COUNT as c4 from v\$PGA_TARGET_ADVICE;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== db_cache_size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters db_cache_size;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== db_cache_size advice ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select size_for_estimate, estd_physical_read_factor, estd_physical_reads  from v\$db_cache_advice;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== shared_pool_size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters shared_pool_size;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== shared_pool_size advice===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "SELECT shared_pool_size_for_estimate, shared_pool_size_factor, estd_lc_time_saved, estd_lc_time_saved_factor FROM v\$shared_pool_advice;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== large_pool_size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters large_pool_size;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== log buffer cache ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters log_buffer;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== java_pool_size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters java_pool_size;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== processes ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameters processes;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== If archivelog or not ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select name,log_mode from v\$database;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Archivelog destination ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "archive log list;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out | grep -i "Archive destination" | awk '{print $3}' >> $OUT_FILE

echo "=== PASSWORD_LIFE_TIME ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "select LIMIT FROM dba_profiles WHERE profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== deferred_segment_creation ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "show parameter deferred_segment_creation;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== tnsnames.ora ===" >> $OUT_FILE
echo "`hostname` server:" >> $OUT_FILE
cat $ORACLE_HOME/network/admin/tnsnames.ora |grep -v "\#" >> $OUT_FILE 2>>$LOG_FILE

echo "=== listener.ora ===" >> $OUT_FILE
echo "`hostname` server:" >> $OUT_FILE
cat $ORACLE_HOME/network/admin/listener.ora |grep -v "\#" >> $OUT_FILE 2>>$LOG_FILE

echo "=== sqlnet.ora ===" >> $OUT_FILE
echo "`hostname` server:" >> $OUT_FILE
cat $ORACLE_HOME/network/admin/sqlnet.ora |grep -v "\#" >> $OUT_FILE 2>>$LOG_FILE

echo "=== Listener state ===" >> $OUT_FILE
echo "`hostname` server:" >> $OUT_FILE
lsnrctl status >> $OUT_FILE