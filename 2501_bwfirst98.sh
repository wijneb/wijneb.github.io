#!/bin/sh

cd /home/bw/sel
loc="/home/bw/sel"
lg1="$loc/delpics"

ADPS="bwalldias98"             # let op als je filenaam wijzigt
kADP="killed alldias process" 
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

mydate()  { date +%d%b%H:%M ; }
devnull() { "$@" > /dev/null 2>&1 ; }
getWH() { eval $( xrandr 2>&1 | grep "0.00" | awk -Fx '{print "WIDTH="int($1) "\nHEIGHT="int($2)}' ) ; }  
setEnv(){ export DISPLAY=:0; export XAUTHORITY=/home/bw/.Xauthority; }
mymsg()         { echo ""; echo "$(mydate) $1 " ; }
myreboot()      { mymsg "reboot in 3 min" ; sleep 180; doas /sbin/reboot ; sleep 180; }  # reboot takes some time :-)
checkreboot()   { [ $(date +%-H) -eq 8 ] && [ $(date +%-M) -eq 0 ] && myreboot ; }
checkprevious() { devnull pgrep -f $ADPS || (pkill -f $ADPS && mymsg $kADP) ; }
atruntime()     { [ $(date +"%-H") -ge 8 ] && [ $(date +"%-H") -lt 22 ] && echo true || echo false; }
getDelays()     { Delays=$(cat $loc/inifile | grep GENER | awk -F= '{print $2}') ; }
startFeh()      { feh --fullscreen --slideshow-delay $Delays -R 60 pics 2>> logs/monlog & }
moveMouse()     { /usr/bin/xdotool mousemove $WIDTH $HEIGHT ; } # muis rechtsonder
startdiashow()  { devnull pgrep -x feh || ( $(atruntime) && getWH && 
                  getDelays && startFeh && moveMouse && mymsg "started diashow from bwfirst98" && echo -n "$(mydate) " ) ; }

nofeh()         { devnull pgrep -x feh && pkill -x feh ; }
orstopdiashow() { devnull [ $(date +%-H) -eq 22 ] && [ $(date +%-M) -eq 0 ] && nofeh && xset +dpms ; return 0; }
main()          { setEnv; checkreboot; checkprevious; startdiashow; orstopdiashow; }

main


