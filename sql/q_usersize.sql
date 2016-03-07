SPOOL q_usersize.out;
COLUMN Exec_date HEADING 'Execute datetime' JUSTIFY CENTER ; 
SELECT  to_char(sysdate,'RRRR/MM/DD HH24:MM')  Exec_date FROM dual;
SELECT	n.owner Factory,
        n.SizeM "DataSize(M)",
        d.SizeM "TempSize(M)"
FROM
  (SELECT owner,ROUND(SUM(bytes)/1024/1024,2) SizeM FROM dba_segments
   WHERE tablespace_name = 'DBS1'
   GROUP BY owner) n,
  (SELECT owner,ROUND(SUM(bytes)/1024/1024,2) SizeM FROM dba_segments
   WHERE tablespace_name = 'TEMPTABS'
   GROUP BY owner) d
WHERE n.owner = d.owner(+)
ORDER BY n.owner;
SPOOL OFF ;

