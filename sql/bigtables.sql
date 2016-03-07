SPOOL $HOME/out/bigtables.out;

col owner format a15;
col segment_name format a15;
col num_rows format a15;
col table_size format a15;
select 
    b.owner,
    a.table_name,
    a.num_rows,
    b.bytes/1024/1024||'M' as table_size
from dba_all_tables a
join dba_segments b
on   a.owner = b.owner
and  a.table_name = b.segment_name
where (a.num_rows > 500000 or b.bytes/1024/1024 > 100)
and  a.table_name NOT LIKE '%HIS'
and  b.segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION','LOBSEGMENT')
ORDER BY owner,table_size DESC;

SPOOL OFF;