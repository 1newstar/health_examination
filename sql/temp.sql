SPOOL /u1/usr/tiptop/out/temp.out;
col FILE_SIZE format a10;
col MEMBER format a50;
select sum(bytes)/1024/1024||'M' "temp size(M)" from dba_temp_files where tablespace_name='TEMP';
SPOOL OFF ;