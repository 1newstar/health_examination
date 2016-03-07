SPOOL $HOME/out/logfile.out;
col FILE_SIZE format a10;
col MEMBER format a50;
select 
  a.MEMBER, 
  b.BYTES/1024/1024||'Mb' as FILE_SIZE, 
  b.STATUS 
from v$logfile a 
join v$log b 
on a.GROUP# = b.GROUP#;
SPOOL OFF ;