#!/bin/ksh
#BUG-520096
#Modify: 06/12/18 FUN-6C0038 By alexstar
#Modify: 06/12/18 FUN-730039 By alexstar
#Modify: 07/10/16 EXT-7A0101 By alexstar
#Modify: 08/02/25 EXT-820095 By alexstar Catch last line to avoid repetition
#Modify: 08/02/25 FUN-820063 By alexstar AP DB separate environment
#Modify: 08/04/14 EXT-840070 By JOEY:temptables
#Modify: 09/01/15 CHI-910026 By alexstar If db creatation failed,remove the setting of FGLPROFILE
#Modify: 09/02/03 CHI-920013 By alexstar 
#Modify: 09/03/02 MOD-930001 By alexstar "i" can't be used on certain AIX version
#Modify: 10/09/20 FUN-A90053 By yuge77 fixed fglprofile replace original contents

#CHI-910026---start---
fun_chkdb()
{
echo "exit"|sqlplus $1/$ans1@$ORACLE_SID|grep -iq error
if [ "$?" -eq 0 ];then
ex $FGLPROFILE <<%%
g/$1\.source =/.,.+5 d
w
q
%%
  echo "******************************************"
  echo "Error: [ DB: $1 creation failed! ]"
  echo "******************************************"
  exit
else
  echo "\n=========================================="
  echo "DB: [ $1 creation succesfully! ]"
  echo "=========================================="
  exit
fi
}
#CHI-910026---end---

if [ "$1" = ""  ] ; then
   echo "Usage: $0 dbname [1|2|3|4]"
   echo "===========For ds schema has not been altered yet============"
   echo "Ex1  : $0 ds1 1  -----> create database only"
   echo "============================================================="
   echo "===============For ds schema had been altered================"
   echo "Ex2  : $0 ds2 2  -----> create table schema(from ds user)"
   echo "Ex3  : $0 ds3 3  -----> create table schema with ds demo data"
   echo "Ex4  : $0 ds4 4  -----> create table schema with data(non-ds)"
   echo "============================================================="
   exit
fi
ans1=t
ans1a=f
while [ $ans1 != $ans1a ]
do
 echo "\n accept the password of user $1 : \c"
 stty -echo
 read ans1
 stty echo
 echo "\n Re-enter the password of user $1 : \c"
 stty -echo
 read ans1a
 stty echo
done
echo "\n"
ans3=t
ans3a=f
while [ $ans3 != $ans3a ]
do
 echo "\n accept the password of user ds : \c"
 stty -echo
 read ans3
 stty echo
 echo "\n Re-enter the password of user ds : \c"
 stty -echo
 read ans3a
 stty echo
done
echo "\n"
ans2=t
ans2a=f
while [ $ans2 != $ans2a ]
do
 echo "\n accept the password of user system : \c"
 stty -echo
 read ans2
 stty echo
 echo "\n Re-enter the password of user system : \c"
 stty -echo
 read ans2a
 stty echo
done
echo "\n"
ans4=t
ans4a=f
while [ $ans4 != $ans4a ]
do
 echo "\n accept the password of user sys : \c"
 stty -echo
 read ans4
 stty echo
 echo "\n Re-enter the password of user sys : \c"
 stty -echo
 read ans4a
 stty echo
done
echo "\n"

db=`echo $1|tr 'a-z' 'A-Z'`
ex - <<%%
a
select 'database:',username from all_users where username='$db';
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql > createdb.tmp2                                       
db2=`grep 'database:' createdb.tmp2|cut -d ' ' -f2`
rm -f createdb.tmp2 createdb.sql
if [ "$db" = "$db2" ]
   then
   echo " "
   echo "\n\033[7m $db database already exists \033[0m" 
   echo " "
   exit
fi

ans=$2
if [ "$2" = "" ]
   then
echo ''
echo "Create new TIPTOP database: $1"
echo ''
echo "===========For ds schema has not been altered yet============"
echo '(1) Create DB User Only'
echo ''
echo "=============For ds schema had been altered=================="
echo '(2) Create DB User with all table schema and basic parameter data'
echo ''
echo '(3) Create DB User with all table schema and DS demo data'
echo ''
echo '(4) Create DB User(From NON-DS USER) with all table schema and data'
echo ''
echo 'Please input your choice.........[ 1/2/3/4 0:Quit ]: \c'
read ans
 if [ "$ans" = "0" ]
    then
    exit
 fi
fi

#FUN-730039 "=" -> " = "

#CHI-910026---start--- change a to i,remove null column,add space 
#MOD-930001 i to a
#FUN-A90053 add  a empty line  below 'a'
ex - <<%%
a

dbi.database.${1}.source = "$ORACLE_SID" ## DVM320
dbi.database.${1}.username = "$1" ## DVM320
dbi.database.${1}.password = "$ans1" ## DVM320
dbi.database.${1}.schema = "$1" ## DVM320
dbi.database.${1}.ora.prefetch.rows = 1 # Add by Raymon 02/02/01
.
w! createdb.pro
q
%%

#FUN-A90053-----start
#ex $FGLPROFILE <<%%
#g/$1\.source =/.,.+5 d
#g/ds2\.source
#-1
#r createdb.pro
#w
#q
#%%
#rm -f createdb.pro
ex $FGLPROFILE <<%%
$
r createdb.pro
w
q
%%
rm -f createdb.pro
#FUN-A90053-----end
#CHI-910026---end---

dbpass=`grep ds.password $FGLPROFILE|cut -d \" -f2|sed 's/ //g'|tail -1`   #EXT-7A0101 #EXT-820095

case $ans in

1) cd $TOP/ora/work
#EXT-7A0101 ---start---
ex - <<%%
a
select property_value from database_properties
 where property_name like ('DEFAULT_TEMP_TABLESPACE');
.
w! /tmp/temp_sql.txt
q
%%
#sqlplus ds/${dbpass}@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1   #FUN-820063
sqlplus system/$ans2@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1   #FUN-820063

ex -s /tmp/tmp.txt <<%%
1
/--
1,. d
2
.,$ d
.
w! /tmp/tmp_value.txt
q
%%
temp_value=`head /tmp/tmp_value.txt`

\rm /tmp/temp_sql.txt
\rm /tmp/tmp.txt
\rm /tmp/tmp_value.txt

#EXT-7A0101 ---end---

ex - <<%%
a
conn system/$ans2@$ORACLE_SID;
create user $1 identified by $ans1                                     
       default tablespace dbs1 
       temporary tablespace $temp_value;                                               
grant create session,create table to $1;                                  
grant resource to  $1;                                                     
grant create synonym to $1;                                                     
conn sys/$ans4@$ORACLE_SID as sysdba;
grant select on sys.v_\$session to $1;
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql                                           
rm -f createdb.sql                   
fun_chkdb $1  #CHI-910026
;;
2) cd $TOP/ora/work
#up_priv ds/$ans3
exp ds/$ans3@$ORACLE_SID owner=ds rows=n file=ds.dmp direct=y log=exp_ds.log   #FUN-6C0038

#EXT-7A0101 ---start---
ex - <<%%
a
select property_value from database_properties
 where property_name like ('DEFAULT_TEMP_TABLESPACE');
.
w! /tmp/temp_sql.txt
q
%%
#sqlplus ds/${dbpass}@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1   #FUN-820063
sqlplus system/$ans2@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1  #CHI-920013 

ex -s /tmp/tmp.txt <<%%
1
/--
1,. d
2
.,$ d
.
w! /tmp/tmp_value.txt
q
%%
temp_value=`head /tmp/tmp_value.txt`

\rm /tmp/temp_sql.txt
\rm /tmp/tmp.txt
\rm /tmp/tmp_value.txt

#EXT-7A0101 ---end---

ex - <<%%
a
conn system/$ans2@$ORACLE_SID;
create user $1 identified by $ans1                                     
       default tablespace dbs1 
       temporary tablespace $temp_value;                                               
grant create session,create table to $1;                                  
grant resource to $1;                                                     
grant create synonym to $1;                                                     
conn sys/$ans4@$ORACLE_SID as sysdba;
grant select on sys.v_\$session to $1;
exit;                          
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql                                           
imp system/$ans2@$ORACLE_SID fromuser=ds touser=$1  file=ds.dmp log=imp_$1.log     #FUN-6C0038
sqlplus $1/$ans1@$ORACLE_SID < synonym.sql                                           

rm -f createdb.sql ds.dmp
#### Load tiptop system parameters #####
clear
for f in aaz_file apz_file aza_file azi_file bxz_file bgz_file ccz_file cpa_file cpr_file faa_file nmz_file oaz_file ooz_file qcz_file rmz_file sma_file mmd_file
{
ex - <<%%
a
insert into ${f} select * from ds.${f};
.
w! loadpara.sql
q
%%
echo 'Load data ... '
echo $f
sqlplus $1/$ans1@$ORACLE_SID <loadpara.sql
rm loadpara.sql
}
fun_chkdb $1  #CHI-910026
;;

3) cd $TOP/ora/work
#up_priv ds/$ans3
exp ds/$ans3@$ORACLE_SID owner=ds  file=ds.dmp direct=y log=exp_ds.log   #FUN-6C0038

#EXT-7A0101 ---start---
ex - <<%%
a
select property_value from database_properties
 where property_name like ('DEFAULT_TEMP_TABLESPACE');
.
w! /tmp/temp_sql.txt
q
%%
#sqlplus ds/${dbpass}@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1   #FUN-820063
sqlplus system/$ans2@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1  #CHI-920013 

ex -s /tmp/tmp.txt <<%%
1
/--
1,. d
2
.,$ d
.
w! /tmp/tmp_value.txt
q
%%
temp_value=`head /tmp/tmp_value.txt`

\rm /tmp/temp_sql.txt
\rm /tmp/tmp.txt
\rm /tmp/tmp_value.txt

#EXT-7A0101 ---end---

ex - <<%%
a
conn system/$ans2@$ORACLE_SID;
create user $1 identified by $ans1                                     
       default tablespace dbs1 
       temporary tablespace $temp_value;                                               
grant create session,create table to $1;                                  
grant resource to $1;                                                     
grant create synonym to $1;                                                     
conn sys/$ans4@$ORACLE_SID as sysdba;
grant select on sys.v_\$session to $1;
exit;                          
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql                                           
imp system/$ans2@$ORACLE_SID fromuser=ds touser=$1  file=ds.dmp log=imp_$1.log     #FUN-6C0038
sqlplus $1/$ans1@$ORACLE_SID < synonym.sql                                           

rm -f createdb.sql ds.dmp
fun_chkdb $1  #CHI-910026
;;

4) echo "\n è«.¼¸?¥æ.è¤.£½?.??.º«(NON-DS USER): \c"
read source

db=`echo $source|tr 'a-z' 'A-Z'`
ex - <<%%
a
select 'database:',username from all_users where username='$db';
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql > createdb.tmp2                                       
db2=`grep 'database:' createdb.tmp2|cut -d ' ' -f2`
rm -f createdb.tmp2 createdb.sql
if [ "$db" != "$db2" ]
   then
   echo " "
   echo "\n\033[7m $db database is not exists \033[0m" 
   echo " "
   exit
fi

ans5=t
ans5a=f
while [ $ans5 != $ans5a ]
do
 echo "\n accept the password of user $source : \c"
 stty -echo
 read ans5
 stty echo
 echo "\n Re-enter the password of user $source : \c"
 stty -echo
 read ans5a
 stty echo
done
echo "\n"

cd $TOP/ora/work
#up_priv $source/$ans5
exp $source/$ans5@$ORACLE_SID owner=${source}  file=${source}.dmp direct=y log=exp_${source}.log   #FUN-6C0038

#EXT-7A0101 ---start---
ex - <<%%
a
select property_value from database_properties
 where property_name like ('DEFAULT_TEMP_TABLESPACE');
.
w! /tmp/temp_sql.txt
q
%%
#sqlplus ds/${dbpass}@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1   #FUN-820063
sqlplus system/$ans2@$ORACLE_SID  < /tmp/temp_sql.txt > /tmp/tmp.txt 2>&1  #CHI-920013 

ex -s /tmp/tmp.txt <<%%
1
/--
1,. d
2
.,$ d
.
w! /tmp/tmp_value.txt
q
%%
temp_value=`head /tmp/tmp_value.txt`

\rm /tmp/temp_sql.txt
\rm /tmp/tmp.txt
\rm /tmp/tmp_value.txt

#EXT-7A0101 ---end---

ex - <<%%
a
conn system/$ans2@$ORACLE_SID;
create user $1 identified by $ans1                                     
       default tablespace dbs1 
       temporary tablespace $temp_value;                                               
grant create session,create table to $1;                                  
grant resource to $1;                                                     
grant create synonym to $1;                                                     
conn sys/$ans4@$ORACLE_SID as sysdba;
grant select on sys.v_\$session to $1;
exit;                          
.
w! createdb.sql
q
%%

sqlplus system/$ans2@$ORACLE_SID < createdb.sql                                           
imp system/$ans2@$ORACLE_SID fromuser=$source  touser=$1  file=${source}.dmp log=imp_$1.log     #FUN-6C0038
rm -f createdb.sql ${source}.dmp
fun_chkdb $1  #CHI-910026
;;

*)
echo "No such choice!"  #CHI-910026
fun_chkdb $1  #CHI-910026
exit
;;
esac