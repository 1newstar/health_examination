#!/bin/sh

#读取配置文件，得到run环境和密码


. ../config/proc_user_cnt.conf
. $TIPTOPPROFILE
. $FGLDIR/envcomp

HOST_NM=`hostname`
time1=`date +%y%m%d`
log_dir=/u1/tmt/log/monitor
mkdir $log_dir>/dev/null 2>&1
cnt_log_file=$log_dir/${HOST_NM}_proc_user_cnt.log
detail_log_file=$log_dir/${HOST_NM}_proc_user_detail_$time1.log

time=`date +%y%m%d%H%M%S`
echo "====="$time"=====">>$detail_log_file

#如果给参数是AP主机，监控process信息
if [ "$HOST_TYPE" = "AP" ]; then

fglWrt -a info user >$log_dir/fglWrt_list.tmp 2>&1

grep Server $log_dir/fglWrt_list.tmp|awk '{split($3,ip,":");print ip[1]}'>$log_dir/client_ip_list.tmp
SUS_CLIENT_CNT=0
while read line
do
  grep $line $log_dir/who_list.tmp>/dev/null 2>&1
  if [ ! $? = "0" ];then
    SUS_CLIENT_IP=$SUS_GDC_IP","$line
    echo $SUS_CLIENT_IP>> $log_dir/sus_client_ip.tmp
    SUS_CLIENT_CNT=`expr $SUS_CLIENT_CNT + 1`
  fi
done<$log_dir/client_ip_list.tmp

echo "fglWrt Information List:">>$detail_log_file
cat $log_dir/fglWrt_list.tmp>>$detail_log_file

echo "Suspect GDC Client: " >>$detail_log_file
cat $log_dir/sus_client_ip.tmp|sed 's/^,\(.*\)/\1/'>>$detail_log_file

fi

ps auwx|grep -E 'fglrun.*42r|ora_|LOCAL'|grep -v 'sh -c'|grep -v grep>$log_dir/ps_list.tmp
who>$log_dir/who_list.tmp
echo "OS Process List:">>$detail_log_file
cat $log_dir/ps_list.tmp>>$detail_log_file
echo "OS User List:">>$detail_log_file
cat $log_dir/who_list.tmp>>$detail_log_file

rm -f $log_dir/*.tmp

#--oracle 相关

#记录session相关信息
if [ "$SESSION" = "Y" ]; then 
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
echo "DB SESSION List:">> $detail_log_file
echo "SESSION|$ORACLE_SID|SPID|PROGRAM|STATUS|PROCESS|SID|SERIAL|IO|MEM|NET|SUM_TIME|SUM_PGA|USERNAME|OSEUSER|MACHINE|LOGINTIME|SQL_ID|CPU_TIME|ELAPSED_TIME|SQL_TEXT">> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'SESSION|',a.spid||'|',a.program||'|',b.status||'|',b.process||'|',b.sid||'|',b.serial#||'|',b.IO||'|',b.MEM||'|',b.NET||'|',b.sum_time||'|',b.sum_pga||'|',b.username||'|',b.osuser||'|',b.machine||'|',b.logontime||'|',c.address||'|',c.cpu_time||'|',c.elapsed_time||'|',c.sql_text from v_\$process a,(select paddr,sql_address,status,process,sid,serial#,IO,MEM,NET,sum_time,ROUND(sum_pga,2) sum_pga,username,osuser,machine,to_char(logon_time,'YYYY-MM-DD" "HH24:MM:SS') logontime from v_\$session,(select sid_io,IO,MEM,NET,sum_time,sum_pga from (select sid sid_io,round((ratio_to_report(sum(value)) OVER () * 100), 2) IO from v_\$sesstat where statistic# in (42,46,9) and sid in (select sid from v_\$Session where user# > 0) group by sid) tmpio,(select sid sid_mem,round((ratio_to_report(sum(value)) OVER () * 100), 2) MEM from  v_\$sesstat where statistic# in (20,15,226) and sid in (select sid from v_\$Session where user# > 0) group by sid) tmpmem,(select sid sid_net,round((ratio_to_report(sum(value)) OVER () * 100), 2) NET from  v_\$sesstat where statistic# in (237,240,236,239,238,241) and sid in (select sid from v_\$Session where user# > 0) group by sid) tmpnet,(select sid sid_time,sum(value) sum_time from  v_\$sesstat where statistic# in (230) and sid in (select sid from v_\$Session where user# > 0) group by sid) tmptime, (select sid sid_pga,sum(value)/1024/1024 sum_pga from  v_\$sesstat where statistic# in (25) and sid in (select sid from v_\$Session where user# > 0) group by sid) tmppga where tmpio.sid_io=tmpmem.sid_mem and tmpio.sid_io=tmpnet.sid_net and tmpio.sid_io=tmptime.sid_time and tmpio.sid_io=tmppga.sid_pga)where sid=sid_io) b,v_\$sql c where a.addr=b.paddr and  b.sql_address = c.address(+);" >> $log_dir/tsp.sql
echo "exit;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "ACTIVE" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$BINDDATA" = "Y" ]; then 
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#记录此刻所有sql的参数值
echo "DB BINDDATA List:">> $detail_log_file
echo "BINDDATA|$ORACLE_SID|SQL_ID|NA_ME|VALUE_STRING">> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'BINDDATA|',sql_id||'|',NAME||'|',value_string from v_\$sql_bind_capture where sql_id in (select sql_id from v_\$Session where user# > 0);" >> $log_dir/tsp.sql 
#sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
#sqlplus "sys/sys@topprod as sysdba" < $log_dir/tsp.sql > $log_dir/tsp.out
#cat $log_dir/tsp.out | grep "BINDDATA" | grep -v "NAME" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi


echo "DB ENV List:">> $detail_log_file

if [ "$TABSPACEIO" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#记录监控表空间的 I/O 比例
echo "TABSPACEIO|$ORACLE_SID|TABLESPACE_NAME|FILE_NAME|PHYRDS|PHYBLKRD|PHYWRTS|PHYBLKWRT" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'TABSPACEIO|',df.tablespace_name||'|',df.file_name||'|',f.phyrds ||'|',f.phyblkrd ||'|',f.phywrts ||'|', f.phyblkwrt from v_\$filestat f, dba_data_files df where f.file# = df.file_id order by df.tablespace_name;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "TABSPACEIO" | grep -v "DF.TABLESPACE_NAME" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$FILEIO" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控文件系统的 I/O 比例
echo "FILEIO|$ORACLE_SID|NAME|STATUS|BYTES|PHYRDS|PHYWRTS" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'FILEIO|', a.name ||'|',a.status||'|', a.bytes||'|', b.phyrds||'|', b.phywrts from v_\$datafile a, v_\$filestat b where a.file# = b.file#;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "FILEIO" | grep -v "A.STATUS" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$SGAHIT" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控 SGA 的命中率
echo "SGAHIT|$ORACLE_SID|LOGICALREAD|PHYSREAD|BUFFER_HIT_RATIO" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'SGAHIT|',a.value + b.value||'|' "LOGICAL_READS", c.value||'|' "phys_reads",round(100 * ((a.value+b.value)-c.value) / (a.value+b.value),2) "BUFFER_HIT_RATIO" from v_\$sysstat a, v_\$sysstat b, v_\$sysstat c where a.statistic# = 38 and b.statistic# = 39 and c.statistic# = 40;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "SGAHIT" | grep -v "LOGICAL_READS" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$SGADICTHIT" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控 SGA 中字典缓冲区的命中率
echo "SGADICTHIT|$ORACLE_SID|PARA_METER|GETS|GETMISSES|HIT_RATIO" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'SGADICTHIT|',PARAMETER||'|', gets||'|',Getmisses ||'|',round((1-(sum(getmisses)/(sum(gets)+sum(getmisses))))*100,2) "Hit_ratio" 
from v_\$rowcache where (gets+getmisses) <> 0 group by parameter, gets, getmisses;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "SGADICTHIT" | grep -v "PARAMETER" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$SGAREDOHIT" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控 SGA 重做日志的命中率
echo "SGAREDOHIT|$ORACLE_SID|NA_ME|GETS|MISSES|IMMEDIATE_GETS|IMMEDIATE_MISSES|RATIO1|RATIO2" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "SELECT 'SGAREDOHIT|',NAME||'|', gets||'|', misses||'|', immediate_gets||'|', immediate_misses||'|',ROUND(Decode(gets,0,0,misses/gets*100),2)||'|' ratio1,ROUND(Decode(immediate_gets+immediate_misses,0,0,immediate_misses/(immediate_gets+immediate_misses)*100),2) ratio2 FROM v_\$latch WHERE name IN ('redo allocation', 'redo copy');" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "SGAREDOHIT" | grep -v "NAME" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$SORTTYPE" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控内存和硬盘的排序比率
echo "SORTTYPE|$ORACLE_SID|NA_ME|VALUE" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "SELECT 'SORTTYPE|',NAME||'|', value FROM v_\$sysstat WHERE name IN ('sorts (memory)', 'sorts (disk)');" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "SORTTYPE" | grep -v "NAME" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$DICTCACHE" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out
#监控字典缓冲区
echo "DICTCACHE|$ORACLE_SID|LIB_CACHE|EXE_CUTIONS|CACHE_MISSES_WHILE_EXECUTING|ROWCACHE" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "SELECT 'DICTCACHE|',ROUND((SUM(PINS - RELOADS)) / SUM(PINS),2)||'|' "LIB_CACHE", SUM(PINS)||'|' "EXECUTIONS", SUM(RELOADS)||'|' "CACHE_MISSES_WHILE_EXECUTING" ,ROUND((SUM(b.GETS - GETMISSES - USAGE - FIXED)) / SUM(b.GETS),2) "ROWCACHE" FROM V_\$LIBRARYCACHE a,  V_\$ROWCACHE b;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "DICTCACHE" | grep -v "EXECUTIONS" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

if [ "$ROLLBACK" = "Y" ]; then
rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out 
#回滚段的争用情况
echo "ROLLBACK|$ORACLE_SID|NA_ME|WAITS|RATIO" >> $detail_log_file
echo "set wrap off" >> $log_dir/tsp.sql
echo "set linesize 9999" >> $log_dir/tsp.sql
echo "select 'ROLLBACK|',NAME||'|',waits||'|',ROUND((waits/gets),2) ratio from v_\$rollstat a,v_\$rollname b where a.usn=b.usn;" >> $log_dir/tsp.sql
sqlplus sys/$SYS_PASSWD@$ORACLE_SID as sysdba <$log_dir/tsp.sql  > $log_dir/tsp.out
cat $log_dir/tsp.out | grep "ROLLBACK" | grep -v "NAME" | sed -e 's/[[:space:]][[:space:]]*/ /g' >> $detail_log_file
fi

rm -rf $log_dir/tsp.sql
rm -rf $log_dir/tsp.out

exit 0
