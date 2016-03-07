#!/bin/ksh -ex

export HOME=/u1/usr/tiptop
OUTPUT=$HOME/web_error_log.txt
> $OUTPUT


cd /var/log/httpd

for file in $(ls /var/log/httpd/*error*)
do
echo "################################################" >> $OUTPUT
echo "#$file"                                           >> $OUTPUT
echo "################################################" >> $OUTPUT
cat $file                                               >> $OUTPUT
echo " "                                                >> $OUTPUT
done



exit