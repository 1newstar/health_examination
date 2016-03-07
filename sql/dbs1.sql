SPOOL /u1/usr/tiptop/out/dbs1.out;
col FILE_SIZE format a10;
col MEMBER format a50;
select  a.TABLESPACE_NAME,
        a.BYTES bytes_used,
        b.BYTES bytes_free,
        b.largest,
        round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used
from    
        (
                select  TABLESPACE_NAME,
                        sum(BYTES) BYTES 
                from    dba_data_files 
                group   by TABLESPACE_NAME
        )
        a,
        (
                select  TABLESPACE_NAME,
                        sum(BYTES) BYTES ,
                        max(BYTES) largest 
                from    dba_free_space 
                group   by TABLESPACE_NAME
        )
        b
where   a.TABLESPACE_NAME=b.TABLESPACE_NAME
        and a.TABLESPACE_NAME='DBS1';
SPOOL OFF ;



