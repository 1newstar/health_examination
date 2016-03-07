SPOOL $HOME/out/q_users.out;

SELECT  username,user_id,DEFAULT_TABLESPACE  FROM dba_users 
where DEFAULT_TABLESPACE='DBS1';

col owner format a15;
col TABLE_SIZE format a10;
col INDEX_SIZE format a10;
col TOTAL format a10;
select 
tab.owner,
TRUNC(tab.tab_size ,2)||'G' TABLE_SIZE,
TRUNC(ind.ind_size ,2)||'G' INDEX_SIZE ,
TRUNC(tab.tab_size+ind.ind_size ,2)||'G' TOTAL,
TRUNC(tab.tab_size/(tab.tab_size+ind.ind_size)*100 ,2) PER 
from
(select owner,sum(bytes)/1024/1024/1024 as tab_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'TABLE%' group by owner) tab,
(select owner,sum(bytes)/1024/1024/1024 as ind_size from dba_segments
where tablespace_name='DBS1' and segment_type like 'INDEX%'group by owner) ind
where tab.owner=ind.owner 
order by TOTAL desc;

SPOOL OFF ;
