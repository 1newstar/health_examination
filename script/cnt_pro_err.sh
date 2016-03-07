#!/bin/bash

#count error of program
THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
OUT_FILE_FINAL=$HOME_OUT/${THIS}_${RUN_DATE}_final.rpt

cd $TOP/log
rm -f tmp1 tmp2 tmp3 tmp4
grep -l "table or view does not exist" * | awk -F\_ '{print $3}' | awk -F\. '{print $1}' | sort -u >tmp4
ls -t |grep ^[0-9] | grep -v "_p_" >tmp1
cat tmp1 |awk -F_ '{print $3}' |awk -F. '{print $1}'  >tmp2
ls -t |grep ^[0-9] | grep -v "_p_" |awk -F_ '{print $1,$3}'|awk -F. '{print $1}'  >tmp3
rm -f $OUT_FILE
touch $OUT_FILE
for i in `cat tmp2`
 do
      grep $i $OUT_FILE
    if [ $? -eq 0 ];then
      continue
    else
     printf "$i " \\c >> $OUT_FILE
     printf `grep -c $i tmp2` \\c  >> $OUT_FILE
     num=`cat tmp3 |grep $i |grep -v grep |sed -n '1p'`
     echo " 20${num:0:6}" >>$OUT_FILE
    fi
 done
 
while read line
do 
sed -i '/'"$line"'/d' $OUT_FILE
done <tmp4

cat $OUT_FILE | sort -n -k 2 -r | column -t>> $OUT_FILE_FINAL
