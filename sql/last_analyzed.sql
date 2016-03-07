spool $HOME/out/last_analyzed.out;

select owner, to_char(last_analyzed,'yyyymmdd'),count(*) old_analyzed  
from dba_tables 
where 
owner  in ('DS','DS1','DS2','DS3','DS4','DS5','DS6','DS7','DS8','DS9','DS10')
and table_name like '%FILE%'
having count(*) > 100
group by owner, to_char(last_analyzed,'yyyymmdd')
order by owner
;

spool off;