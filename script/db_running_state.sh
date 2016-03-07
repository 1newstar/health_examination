#!/bin/ksh

#--4.4 数据库运行状态

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
OUT_FILE_FINAL=$HOME_OUT/${THIS}_${RUN_DATE}_final.rpt
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

echo "=== Datafile size ===" >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "col  file_name format a50" >> $HOME_OUT/tsp.sql
echo "col  file_size format a20" >> $HOME_OUT/tsp.sql
echo "select file_name, bytes/1024/1024||'M' as file_size from dba_data_files order by file_name;" >> $HOME_OUT/tsp.sql
echo "select sum(bytes/1024/1024/1024)||'G' as total_size from dba_data_files;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Archivelog size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select sum(blocks*block_size)/1024/1024||'M' as total_size from v\$archived_log;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Redolog size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "col FILE_SIZE format a10" >> $HOME_OUT/tsp.sql
echo "col MEMBER format a50" >> $HOME_OUT/tsp.sql
echo "select a.MEMBER, b.BYTES/1024/1024||'Mb' as FILE_SIZE, b.STATUS from v\$logfile a join v\$log b on a.GROUP# = b.GROUP#;" >> $HOME_OUT/tsp.sql
echo "select sum(BYTES/1024/1024)||'M' as total_SIZE from v\$log;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Temp size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "col FILE_SIZE format a10" >> $HOME_OUT/tsp.sql
echo "col MEMBER format a50" >> $HOME_OUT/tsp.sql
echo "select sum(bytes)/1024/1024||'M' as temp_size from dba_temp_files where tablespace_name='TEMP';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$" >> $OUT_FILE

echo "=== Undo size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 200" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select a.TABLESPACE_NAME,a.SIZEM||'M' as Total,b.SIZEM||'M' as Free,b.largest||'M' as Largest,round(((a.SIZEM-b.SIZEM)/a.SIZEM)*100,2)||'%' as Used,b.fragment as fragment
from 
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM from dba_data_files  group by TABLESPACE_NAME ) a,
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM , round(max(bytes)/1024/1024,2) largest,count(*) fragment from dba_free_space group by TABLESPACE_NAME ) b
where a.TABLESPACE_NAME=b.TABLESPACE_NAME order by ((a.SIZEM-b.SIZEM)/a.SIZEM) desc;" >> $HOME_OUT/tsp.sql
echo "select sum(bytes)/1024/1024||'M' as current_undo_size from dba_data_files where tablespace_name='UNDOTBS1';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$" >> $OUT_FILE

echo "=== DBS1 size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select sum(bytes)/1024/1024||'M' as current_DBS1_size from dba_data_files where tablespace_name='DBS1';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== TEMPTABS size === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select sum(bytes)/1024/1024||'M' as current_TEMPTABS_size from dba_data_files where tablespace_name='TEMPTABS';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== DBS1 used(%) === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select a.TABLESPACE_NAME,round(((a.SIZEM-b.SIZEM)/a.SIZEM)*100,2)||'%' as Used from 
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM from dba_data_files  group by TABLESPACE_NAME ) a,
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM , round(max(bytes)/1024/1024,2) largest from dba_free_space group by TABLESPACE_NAME ) b
where a.TABLESPACE_NAME=b.TABLESPACE_NAME and a.TABLESPACE_NAME='DBS1';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$" >> $OUT_FILE

echo "=== TEMPTABS used(%) === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select a.TABLESPACE_NAME,round(((a.SIZEM-b.SIZEM)/a.SIZEM)*100,2)||'%' as Used from 
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM from dba_data_files  group by TABLESPACE_NAME ) a,
( select TABLESPACE_NAME, round(sum(bytes)/1024/1024,2) SIZEM , round(max(bytes)/1024/1024,2) largest from dba_free_space group by TABLESPACE_NAME ) b
where a.TABLESPACE_NAME=b.TABLESPACE_NAME and a.TABLESPACE_NAME='TEMPTABS';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Total Plants === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 200" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select tab.owner,TRUNC(tab.tab_size ,2)*1024||'M' TABLE_SIZE,TRUNC(ind.ind_size ,2)*1024||'M' INDEX_SIZE ,TRUNC(tab.tab_size+ind.ind_size ,2)*1024||'M' TOTAL,TRUNC(tab.tab_size/(tab.tab_size+ind.ind_size)*100 ,2) PER 
from
(select owner,sum(bytes)/1024/1024/1024 as tab_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'TABLE%' group by owner) tab,
(select owner,sum(bytes)/1024/1024/1024 as ind_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'INDEX%'group by owner) ind
where tab.owner=ind.owner order by 1;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$" >> $OUT_FILE

echo "=== INUSE Plants === " >> $OUT_FILE
echo "Get it from MIS" >> $OUT_FILE

echo "=== Valid data === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select TRUNC(tab.tab_size+ind.ind_size ,2)||'G' TOTAL from
(select owner,sum(bytes)/1024/1024/1024 as tab_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'TABLE%' and segment_name not like 'TT%' group by owner) tab,
(select owner,sum(bytes)/1024/1024/1024 as ind_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'INDEX%'group by owner) ind
where tab.owner=ind.owner order by TOTAL desc;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$" >> $OUT_FILE

echo "=== Bigtables === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select b.owner,a.table_name,a.num_rows,b.bytes/1024/1024||'M' as table_size from dba_all_tables a join dba_segments b on a.owner = b.owner
and  a.table_name = b.segment_name
where (a.num_rows > 500000 or b.bytes/1024/1024 > 100)
and  a.table_name NOT LIKE '%HIS'
and  b.segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION','LOBSEGMENT') ORDER BY a.num_rows DESC;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== temp tables === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "SELECT owner,count(*) cnt,TRUNC(SUM(bytes)/1024/1024,2)||'M' AS sizeM FROM dba_segments WHERE tablespace_name = 'TEMPTABS'
--HAVING count(*) > 100
GROUP BY owner
ORDER BY sizeM desc;" >> $HOME_OUT/tsp.sql
echo "SELECT count(*) cnt FROM dba_segments WHERE tablespace_name = 'TEMPTABS';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Invalid objects === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "SELECT count(*) from dba_objects where status<>'VALID';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Recyclebin === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set wrap off" >> $HOME_OUT/tsp.sql
echo "set linesize 9999" >> $HOME_OUT/tsp.sql
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "SELECT owner,COUNT(*) cnt,SUM(space*blocksize)/1024/1024||'M' sizeM FROM dba_recyclebin,ts$ WHERE ts_name = name GROUP BY owner order by cnt desc;" >> $HOME_OUT/tsp.sql
echo "SELECT COUNT(*) cnt FROM dba_recyclebin,ts$ WHERE ts_name = name;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Flashback area === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "SHOW PARAMETER DB_RECOVERY_FILE_DEST;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Space waste === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "set linesize 200" >>  $HOME_OUT/tsp.sql
echo "SELECT owner,segment_name table_name,num_rows,ROUND(bytes/1024/1024)||'M' sizeM,ROUND(100*(hwm-used)/hwm, 2) waste_per,chain_per FROM 
  (SELECT 
     A.owner owner, A.segment_name, A.bytes, B.num_rows, 
     ( A.blocks - B.empty_blocks - 1) hwm,
     (B.avg_row_len * B.num_rows * (1 + (B.pct_free/100))/C.blocksize) + 2 used,
     ROUND(100 * B.chain_cnt/B.num_rows,2) chain_per 
   FROM 
     (SELECT 
        owner,tablespace_name,segment_name,SUM(bytes) bytes,SUM(blocks) blocks 
      FROM dba_segments 
      WHERE segment_type LIKE 'TABLE%' 
      GROUP BY owner,tablespace_name,segment_name) A,
     dba_tables B,
     ts$ C 
   WHERE 
     A.owner =B.owner and segment_name = table_name and 
     B.tablespace_name = C.name AND A.blocks > 0 AND pct_free > 0 AND 
     avg_row_len > 0 AND chain_cnt > 0 AND num_rows > 0 )
WHERE ROUND(100*(hwm-used)/hwm, 2) > 25 AND   num_rows > 1000 AND   chain_per > 10 ORDER BY owner,waste_per DESC;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Last analyzed date === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select owner, to_char(last_analyzed,'yyyymmdd') last_analyzed_date,count(*) old_analyzed from dba_tables 
where owner in (select username from all_users) and table_name like '%FILE%'
having count(*) > 100 group by owner, to_char(last_analyzed,'yyyymmdd') order by owner;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Database links === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select count(*) from DBA_OBJECTS WHERE OBJECT_TYPE LIKE 'database link';" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Triggers === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select owner,count(*) from dba_triggers group by owner;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Objects consistency === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "set linesize 200" >> $HOME_OUT/tsp.sql
echo "select  USERNAME,
        count(decode(o.TYPE#, 2,o.OBJ#,'')) Tabs,
        count(decode(o.TYPE#, 1,o.OBJ#,'')) Inds,
        count(decode(o.TYPE#, 5,o.OBJ#,'')) Syns,
        count(decode(o.TYPE#, 4,o.OBJ#,'')) Views,
        count(decode(o.TYPE#, 6,o.OBJ#,'')) Seqs,
        count(decode(o.TYPE#, 7,o.OBJ#,'')) Procs,
        count(decode(o.TYPE#, 8,o.OBJ#,'')) Funcs,
        count(decode(o.TYPE#, 9,o.OBJ#,'')) Pkgs,
        count(decode(o.TYPE#,12,o.OBJ#,'')) Trigs,
        count(decode(o.TYPE#,10,o.OBJ#,'')) Deps
from  sys.obj$ o,dba_users u where   u.USER_ID = o.OWNER# (+) group  by USERNAME order by USERNAME;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== TOP SQL === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "select * from v\$sql_plan where operation = 'TABLE ACCESS' and options = 'FULL' and cost > 1000;" >> $HOME_OUT/tsp.sql
echo "select sql_text,sql_fulltext,object_owner,object_name,'TABLE ACCESS FULL' info,p.cost from v\$sql s,v\$sql_plan p where s.sql_id=p.sql_id and operation = 'TABLE ACCESS' and options = 'FULL' and p.object_owner <> 'SYS' AND p.object_owner <> 'SYSMAN' AND p.object_owner <> 'SYSTEM' and p.cost>1000 order by cost desc;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

echo "=== Rubbish tables === " >> $OUT_FILE
rm -f $HOME_OUT/tsp.sql
rm -f $HOME_OUT/tsp.out 
echo "set pagesize 9999" >> $HOME_OUT/tsp.sql
echo "set linesize 120" >> $HOME_OUT/tsp.sql
echo "SELECT tr.owner,tr.table_name,tr.num_rows,ts.sizeM FROM
(SELECT owner,segment_name,SUM(bytes)/1024/1024||'M' sizeM FROM dba_segments
WHERE ( segment_name NOT LIKE '%_FILE' ) AND ( segment_name NOT LIKE 'APS%' ) AND
      ( segment_name NOT LIKE 'POS%' ) AND ( segment_name NOT LIKE 'TRANSMOD%' ) AND
      ( segment_name NOT LIKE 'TRANSREF%' ) AND ( segment_name NOT LIKE 'PLSQL%' ) AND
      ( segment_name NOT LIKE 'TOAD_PLAN%' ) AND ( segment_name NOT LIKE 'D_P%' ) AND
      ( segment_name NOT LIKE 'U_P%' ) AND ( segment_name NOT LIKE 'B_P%' ) AND
      ( segment_name NOT LIKE '%_HIS' ) AND 
      ( segment_name NOT IN ('ALL_SYSCOLUMNS','TEMPTABREG' )) AND 
      ( owner NOT IN ('DS_REPORT','RPS','AUD' )) AND 
( segment_name <> 'PLAN_TABLE' ) AND tablespace_name LIKE 'DBS%'
GROUP BY owner,segment_name) ts,
(SELECT owner,table_name,num_rows FROM dba_tables 
WHERE ( table_name NOT LIKE '%_FILE' ) AND ( table_name NOT LIKE 'APS%' ) AND
      ( table_name NOT LIKE 'POS%' ) AND ( table_name NOT LIKE 'TRANSMOD%' ) AND
      ( table_name NOT LIKE 'TRANSREF%' ) AND ( table_name NOT LIKE 'PLSQL%' ) AND
      ( table_name NOT LIKE 'TOAD_PLAN%' ) AND ( table_name NOT LIKE 'D_P%' ) AND
      ( table_name NOT LIKE 'U_P%' ) AND ( table_name NOT LIKE 'B_P%' ) AND
      ( table_name NOT LIKE '%_HIS' ) AND
      ( table_name NOT IN ('ALL_SYSCOLUMNS','TEMPTABREG' )) AND 
      ( owner NOT IN ('DS_REPORT','RPS','AUD' )) AND 
      ( table_name <> 'PLAN_TABLE' ) AND tablespace_name LIKE 'DBS%') tr
WHERE ts.owner||ts.segment_name = tr.owner||tr.table_name ORDER BY owner,table_name;" >> $HOME_OUT/tsp.sql
sqlplus sys/$ans4a@$ORACLE_SID as sysdba <$HOME_OUT/tsp.sql  > $HOME_OUT/tsp.out
cat $HOME_OUT/tsp.out |grep -v "SQL" |grep -v "Oracle" | grep -v "Connected" | grep -v "With" | grep -v "^$">> $OUT_FILE

sed '/---/d' $OUT_FILE > $OUT_FILE_FINAL