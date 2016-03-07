TTYID=`tty | awk -F"/" '{print $4}'`
GENERO_USERS=/tmp/genero_users.$TTYID

echo "License        Users        Available"
echo "-------        -----        ---------"

FGLDIR=/u1/genero/fgl
fglWrt -a info users 2> $GENERO_USERS
INFO_USERS=`cat $GENERO_USERS | grep Users | awk -F":" '{print $2}'`
INFO_LICENSE=`cat $GENERO_USERS | grep License | awk -F":" '{print $2}'`
CURRENT=`echo $INFO_USERS | awk -F"/" '{print $1}'`
TOTAL=`echo $INFO_USERS | awk -F"/" '{print $2}'`
AVAILABLE=`expr $TOTAL - $CURRENT`
echo $INFO_LICENSE " " $INFO_USERS "        " $AVAILABLE
TOTAL1=$TOTAL
CURRENT1=$CURRENT

FGLDIR=/u1/genero/fgl.tmp
fglWrt -a info users 2> $GENERO_USERS
INFO_USERS=`cat $GENERO_USERS | grep Users | awk -F":" '{print $2}'`
INFO_LICENSE=`cat $GENERO_USERS | grep License | awk -F":" '{print $2}'`
CURRENT=`echo $INFO_USERS | awk -F"/" '{print $1}'`
TOTAL=`echo $INFO_USERS | awk -F"/" '{print $2}'`
AVAILABLE=`expr $TOTAL - $CURRENT`
echo $INFO_LICENSE " " $INFO_USERS "          " $AVAILABLE
TOTAL2=$TOTAL
CURRENT2=$CURRENT

FGLDIR=/u1/genero/fgl.tmp2
fglWrt -a info users 2> $GENERO_USERS
INFO_USERS=`cat $GENERO_USERS | grep Users | awk -F":" '{print $2}'`
INFO_LICENSE=`cat $GENERO_USERS | grep License | awk -F":" '{print $2}'`
CURRENT=`echo $INFO_USERS | awk -F"/" '{print $1}'`
TOTAL=`echo $INFO_USERS | awk -F"/" '{print $2}'`
AVAILABLE=`expr $TOTAL - $CURRENT`
echo $INFO_LICENSE " " $INFO_USERS "          " $AVAILABLE
TOTAL3=$TOTAL
CURRENT3=$CURRENT

if [ $TOTAL1 -gt $CURRENT1 ] ; then
  echo "License #1 is available"
  FGLDIR=/u1/genero/fgl
  unset GENERO_USERS TTYID INFO_USERS INFO_LICENSE CURRENT TOTAL AVAILABLE 
  unset TOTAL1 TOTAL2 TOTAL3 CURRENT1 CURRENT2 CURRENT3
  return 
fi

if [ $TOTAL2 -gt $CURRENT2 ] ; then
  echo "License #2 is available"
  FGLDIR=/u1/genero/fgl.tmp
  fglWrt -a info 2>&1|tail -n 1
  unset GENERO_USERS TTYID INFO_USERS INFO_LICENSE CURRENT TOTAL AVAILABLE 
  unset TOTAL1 TOTAL2 TOTAL3 CURRENT1 CURRENT2 CURRENT3
  return
fi

if [ $TOTAL2 -gt $CURRENT2 ] ; then
  echo "License #3 is available"
  FGLDIR=/u1/genero/fgl.tmp2
  fglWrt -a info 2>&1|tail -n 1
  unset GENERO_USERS TTYID INFO_USERS INFO_LICENSE CURRENT TOTAL AVAILABLE
  unset TOTAL1 TOTAL2 TOTAL3 CURRENT1 CURRENT2 CURRENT3
  return
fi
