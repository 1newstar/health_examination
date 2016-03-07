spool $HOME/out/tamptables.out;

col owner format a10;

SELECT 
  owner,
  count(*) cnt,
  TRUNC(SUM(bytes)/1024/1024,2) AS sizeM 
FROM dba_segments 
WHERE tablespace_name = 'TEMPTABS'
--HAVING count(*) > 100
GROUP BY owner
ORDER BY sizeM desc;

spool off;
