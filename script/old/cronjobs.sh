#!/bin/ksh -e

OUT_FILE=~/1.out

cd /var/spool/cron/

for file in $(ls)
do
set +e 
grep -v "\#" $file
rcode=$?
set -e

if [ $rcode = 0 ]; then
  echo " " >> $OUT_FILE
  echo "#-----------------------------------------------------------------------" >> $OUT_FILE
  echo "# $file" >> $OUT_FILE
  echo "#-----------------------------------------------------------------------" >> $OUT_FILE
  grep -v "\#" $file >> $OUT_FILE
  echo " " >> $OUT_FILE
fi

done 

exit 0