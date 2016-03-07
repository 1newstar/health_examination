#!/bin/ksh -eu

cd $TOP/log
OUT_DIR=~

#--initio the output file
TMP_FILE=$OUT_DIR/result_tmp.out
RPT_FILE=$OUT_DIR/result_rpt.csv
rm -f $TMP_FILE
rm -f $RPT_FILE

for FILE in $(ls)
do

LOG_NAME=${FILE%%.*}
PRC_NAME=${LOG_NAME##*_}
PRC_DATE=${LOG_NAME%%_*}


set +e
  grep '\<'"$PRC_NAME"'\>' $RPT_FILE > /dev/null 2>&1
  rcode=$?
set -e

if [ $rcode != 0 ]; then
  PRC_DATE_NEW=`echo $PRC_DATE | sed 's/\(..\)\(..\)\(..\)/20\1-\2-\3/'`
  echo "$PRC_NAME,1,$PRC_DATE_NEW" >> $RPT_FILE
else
  PRC_CNT_OLD=`grep $PRC_NAME $RPT_FILE | cut -d"," -f2`
  PRC_DATE_OLD=`grep $PRC_NAME $RPT_FILE | cut -d"," -f3`
  ((PRC_CNT_NEW=PRC_CNT_OLD+1))

  if [ $PRC_DATE_OLD -lt $PRC_DATE ]; then
    PRC_DATE_NEW=`echo $PRC_DATE | sed 's/\(..\)\(..\)\(..\)/20\1-\2-\3/'`
  else
    PRC_DATE_NEW=`echo $PRC_DATE_OLD | sed 's/\(..\)\(..\)\(..\)/20\1-\2-\3/'`
  fi

    sed '/^'"$PRC_NAME"'/c\'"$PRC_NAME"','"$PRC_CNT_NEW"','"$PRC_DATE_NEW"'' $RPT_FILE > $TMP_FILE
    mv $TMP_FILE $RPT_FILE
fi

done

sed '1i\Process_name,Error_cnt,Last_error_date' $RPT_FILE > $TMP_FILE
mv $TMP_FILE $RPT_FILE

exit 0
