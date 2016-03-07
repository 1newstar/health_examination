spool $HOME/out/userless_tables.out;

SELECT tr.owner,tr.table_name,tr.num_rows,ts.sizeM FROM
(SELECT owner,segment_name,SUM(bytes)/1024/1024 sizeM FROM dba_segments
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
WHERE ts.owner||ts.segment_name = tr.owner||tr.table_name
ORDER BY owner,table_name
;

spool off;