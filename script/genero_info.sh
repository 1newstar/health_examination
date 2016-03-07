#!/bin/ksh

#--4.1 genero环境信息

THIS=`basename $0 .ksh`
RUN_DATE=`date '+%y%m%d'`
HOME_OUT=/u1/tmt/log
OUT_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.rpt
LOG_FILE=$HOME_OUT/${THIS}_${RUN_DATE}.log

time=`date +%y%m%d%H%M%S`
echo "===== "$time"===== " >> $OUT_FILE

echo "=== Genero version ===" >> $OUT_FILE
fpi | grep Version >> $OUT_FILE

echo "=== Dev environment path ===" >> $OUT_FILE
echo `echo $FGLDIR|cut -d . -f1`.dev >> $OUT_FILE

echo "=== Run environment path ===" >> $OUT_FILE
echo $FGLDIR >> $OUT_FILE

echo "=== Gasd version ===" >> $OUT_FILE
gasd -V | grep Version >> $OUT_FILE

echo "=== Gas path ===" >> $OUT_FILE
echo $FGLASDIR >> $OUT_FILE

echo "=== Flm version ===" >> $OUT_FILE
$FLMDIR/bin/flmprg -v | grep Version >> $OUT_FILE

echo "=== Flm path ===" >> $OUT_FILE
echo $FLMDIR >> $OUT_FILE

echo "=== Dev license ===" >> $OUT_FILE
FGLDIR=`echo $FGLDIR|cut -d . -f1`.dev;export FGLDIR>> $OUT_FILE

echo "=== Run license ===" >> $OUT_FILE
fglWrt -a info license  >> $OUT_FILE

echo "=== Run license count===" >> $OUT_FILE
fglWrt -a info >> $OUT_FILE

echo "=== Borrow license ===" >> $OUT_FILE
echo "Go to see getlic.sh" >> $OUT_FILE

echo "=== Expired date ===" >> $OUT_FILE
fglWrt -a info >> $OUT_FILE

echo "=== Fglprofile path ===" >> $OUT_FILE
echo $FGLPROFILE >> $OUT_FILE