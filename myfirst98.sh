#!/bin/sh

cd /home/bw/sel
loc="/home/bw/sel"
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

getWH1(){
    export DISPLAY=:0
    export XAUTHORITY=/home/bw/.Xauthority # needed to make it work in cron environment
    WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
    HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
    }

getWH(){ eval $( export DISPLAY=:0; export XAUTHORITY=/home/bw/.Xauthority; 
         WH=$(xrandr 2>/dev/null | grep "0.00"); echo $WH | awk -Fx '{split($2, a, " "); 
         print "WIDTH="int($1) "\nHEIGHT="int(a[1])}' ) ; } # special trick from within subshell

mymsg()         { echo "$(date +"%b %d %H:%M") $1 " ; }

myreboot()      { mymsg "reboot in 1 min" ; sleep 60; doas /sbin/reboot ; }

checkreboot()   { [ $(date +%-H) -eq 8 ] && [ $(date +%-M) -eq 0 ] && myreboot ; }

checkprevious() { pkill -f bwalldias98 > /dev/null && mymsg "killed alldias process" ; }

atruntime()     { [ $(date +"%-H") -ge 8 ] && [ $(date +"%-H") -lt 22 ] && echo true || echo false; }

getDelays()     { Delays=$(cat $loc/inifile | grep GENER | awk -F= '{print $2}') ; }

startFeh()      { feh --fullscreen --slideshow-delay $Delays -R 60 pics 2>> monlog & ; }

moveMouse()     { /usr/bin/xdotool mousemove $WIDTH $HEIGHT ; } # muis rechtsonder

startdiashow()  { pgrep -x feh > /dev/null || ( $(atruntime) && getWH && 
                  getDelays && startFeh && moveMouse && mymsg "started diashow" ) ; }

nodpms()        { /usr/local/bin/dpmsoff ; } 

nofeh()         { pkill -x feh ; }

orstopdiashow() { [ $(date +%-H) -eq 22 ] && [ $(date +%-M) -eq 0 ] && nodpms && nofeh ; }

main()          { checkreboot; checkprevious; startdiashow; orstopdiashow; }

main


