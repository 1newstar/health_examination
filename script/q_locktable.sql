column "Locked Object" format a16 trunc;
column "Tiptop User" format a11 trunc;
column "4glP" format a5 trunc;
column "OraP" format a5 trunc;
column "Terminal" format a8 trunc;
column "sid" format a4 trunc;
column "serial" format a5 trunc;
column "username" format a10 trunc;
column "machine" format a10 trunc;

SELECT 
SUBSTR(all_objects.owner||'.'||object_name,1,16) "Locked Object"
,SUBSTR(os_user_name,1,10) "Tiptop User"
,SUBSTR(v$locked_object.process,1,6) "4glP"
,SUBSTR(v$process.spid,1,6) "OraP"
,v$session.terminal "Terminal"
,SUBSTR(v$session.sid,1,4) "sid"
,SUBSTR(v$session.serial#,1,5) "serial"
,v$session.machine
  FROM v$locked_object,all_objects,v$session,v$process
 WHERE v$locked_object.object_id=all_objects.object_id
   AND v$locked_object.SESSION_ID=v$session.SID
   AND v$session.paddr=v$process.addr
/
