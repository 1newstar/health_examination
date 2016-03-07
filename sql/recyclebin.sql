SPOOL $HOME/out/recyclebin.out;

SELECT owner,COUNT(*) cnt,SUM(space*blocksize)/1024/1024 sizeM 
FROM dba_recyclebin,ts$
WHERE ts_name = name
GROUP BY owner order by cnt desc;

spool off;
