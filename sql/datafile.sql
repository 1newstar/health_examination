SPOOL $HOME/out/datafile.out;
col  file_name format a50;
col  file_size format a10;
select 
  file_name, 
  bytes/1024/1024||'M' as file_size 
from dba_data_files 
order by file_name;
SPOOL OFF ;