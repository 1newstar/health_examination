#!/bin/ksh 

cd $HOME_SQL

for file in $(ls *sql)
do
sqlplus sys/sys@topprod as sysdba < $file
done