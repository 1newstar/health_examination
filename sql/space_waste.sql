spool $HOME/out/space_waste.out;

SELECT 
  owner, 
  segment_name table_name,
  num_rows,ROUND(bytes/1024/1024) sizeM,  
  ROUND(100*(hwm-used)/hwm, 2) waste_per,
  chain_per 
FROM 
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
WHERE ROUND(100*(hwm-used)/hwm, 2) > 25 
AND   num_rows > 1000 
AND   chain_per > 10
ORDER BY owner,waste_per DESC;

spool off;