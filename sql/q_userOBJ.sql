q_userOBJ.sql
--# User Objects
--# USER OBJECT NOTES:
--#
--# Username - Owner of the object(s) 
--# Tabs - Table(s) 
--# Inds - Index(es) 
--# Syns - Synonym(s) 
--# Views - Views(s) 
--# Seqs - Sequence(s) 
--# Procs - Procedure(s)
--# Funcs - Function(s)
--# Pkgs - Packages(s)
--# Trigs - Trigger(s)
--# Deps - Dependencies 
--# 
set linesize 150;
SPOOL q_userOBJ.out;
COLUMN Exec_date HEADING 'Execute datetime' JUSTIFY CENTER ; 
select  USERNAME,
        count(decode(o.TYPE#, 2,o.OBJ#,'')) Tabs,
        count(decode(o.TYPE#, 1,o.OBJ#,'')) Inds,
        count(decode(o.TYPE#, 5,o.OBJ#,'')) Syns,
        count(decode(o.TYPE#, 4,o.OBJ#,'')) Views,
        count(decode(o.TYPE#, 6,o.OBJ#,'')) Seqs,
        count(decode(o.TYPE#, 7,o.OBJ#,'')) Procs,
        count(decode(o.TYPE#, 8,o.OBJ#,'')) Funcs,
        count(decode(o.TYPE#, 9,o.OBJ#,'')) Pkgs,
        count(decode(o.TYPE#,12,o.OBJ#,'')) Trigs,
        count(decode(o.TYPE#,10,o.OBJ#,'')) Deps
from    sys.obj$ o,
        dba_users u
where   u.USER_ID = o.OWNER# (+)
group   by USERNAME
order   by USERNAME;
SPOOL OFF ;