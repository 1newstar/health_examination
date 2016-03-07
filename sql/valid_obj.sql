spool $HOME/out/valid_objects.out;

SELECT owner,object_name,object_type,status 
FROM dba_objects where status <> 'VALID';


spool off;
