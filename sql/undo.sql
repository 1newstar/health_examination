SPOOL /u1/usr/tiptop/out/undo.out;
col FILE_SIZE format a10;
col MEMBER format a50;
select sum(bytes)/1024/1024||'M' "current undo size(M)" from dba_data_files where tablespace_name='UNDOTBS1';
SPOOL OFF ;