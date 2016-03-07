SPOOL q_tbsFREE.out;
COLUMN Exec_date HEADING 'Execute datetime' JUSTIFY CENTER ; 
SELECT  to_char(sysdate,'RRRR/MM/DD HH24:MM')  Exec_date FROM dual;
select	a.TABLESPACE_NAME,
	a.SIZEM "Total(M)",
	b.SIZEM "Free(M)",
	b.largest "Largest(M)",
	round(((a.SIZEM-b.SIZEM)/a.SIZEM)*100,2) "Used(%)"
from 	
	(
		select 	TABLESPACE_NAME,
			round(sum(bytes)/1024/1024,2) SIZEM 
		from 	dba_data_files 
		group 	by TABLESPACE_NAME
	)
	a,
	(
		select 	TABLESPACE_NAME,
			round(sum(bytes)/1024/1024,2) SIZEM ,
			round(max(bytes)/1024/1024,2) largest 
		from 	dba_free_space 
		group 	by TABLESPACE_NAME
	)
	b
where 	a.TABLESPACE_NAME=b.TABLESPACE_NAME
order 	by ((a.SIZEM-b.SIZEM)/a.SIZEM) desc;
SPOOL OFF ;
