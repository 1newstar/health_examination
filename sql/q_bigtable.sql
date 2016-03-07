SPOOL q_usersize.out;
COLUMN Exec_date HEADING 'Execute datetime' JUSTIFY CENTER ; 
COLUMN FACTORY FORMAT A10 WRAP;
COLUMN TABLE   FORMAT A10 WRAP;
SELECT  to_char(sysdate,'RRRR/MM/DD HH24:MM')  Exec_date FROM dual;
SELECT * FROM
  (SELECT SUBSTR(owner,1,10) "Factory",
          SUBSTR(segment_name,1,10) "Table",
          ROUND(SUM(bytes)/1024/1024,2) "Size(M)"
   FROM  dba_segments
   WHERE ( tablespace_name = 'DBS1' OR tablespace_name = 'TEMPTABS' ) AND
         segment_type LIKE 'TAB%'
   GROUP BY owner,segment_name
   ORDER BY SUM(bytes) DESC)
WHERE rownum <= 20;
SPOOL OFF ;

