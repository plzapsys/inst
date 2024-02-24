#IP=$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')
PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
LOCAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
TIME1=$(date -I)
TIME2=$(date +%H:%M:%S)
RAM=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
LOAD=$(uptime | awk -F'[a-z]:' '{ print $2}')
DISK=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)\n", $3,$2,$5}')
CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')
UPTIME=$(uptime | awk -F'( |,|:)+' '{if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"days,",h+0,"hours,",m+0,"minutes."}')
echo ""
echo "This server has installed PLZAP."
# echo "Public Log in https://$PUBLIC_IP:7080"
# echo "Local Log in https://$LOCAL_IP:7080"
echo ""
echo "Current Server time : $TIME1 $TIME2."
echo "Current Load average:$LOAD"
echo "Current CPU usage   : $CPU."
echo "Current RAM usage   : $RAM."
echo "Current Disk usage  : $DISK."
echo "System uptime       : $UPTIME"
echo ""