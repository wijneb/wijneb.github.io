#!/bin/sh

#  #  #    # opstart files, opstarten vanaf OBautostart in .config folder

cd /home/bw/sel

hom="/home/bw/sel"

mydate()   { date +%d%b%H:%M ; }

mymsg()    { echo "$(mydate) $1 " ; }

devnull()  { "$@" > /dev/null 2>&1 ; }

#  #  #    # Disable screensaver, blanking and power management (DPMS)

bootMsg()  { mymsg "just rebooted, this msg is from OBautostart" ; }
atBoot()   { $(atruntime) && xset s off && xset s noblank && xset -dpms && bootMsg; }
atruntime(){ [ $(date +"%-H") -ge 8 ] && [ $(date +"%-H") -lt 22 ] && echo true || echo false; }

#getWH()    { eval $( cat $hom/scrRes | awk -Fx '{print "WIDTH="int($1) "\nHEIGHT="int($2)}' ) ; }
#getWH1()   { eval $( xrandr 2>&1 | grep "0.00" | awk -Fx '{print "WIDTH="int($1) "\nHEIGHT="int($2)}' ) ; } 
#startFeh() { Delays=$( cat inifile | grep GENER | cut -d= -f2 )
#             feh --fullscreen --slideshow-delay $Delays -R 60 pics 2>> $hom/logs/monlog & }
#moveMouse(){ /usr/bin/xdotool mousemove $WIDTH $HEIGHT ; } # muis rechtsonder
#startdias(){ devnull pgrep -x feh || ( $(atruntime) && getWH && 
#             startFeh && moveMouse && mymsg "started diashow from OBautostart" ) ; }

getRes()   { resFile=$(cat $hom/scrRes); Res=$(echo $(xrandr 2>&1 | tail -n 1) | cut -d' ' -f1); } # 1920x1080
setScrRes(){ getRes; [ $? -ne 0 ] || [ "$resFile" = "$Res" ] || echo "$Res" > $hom/scrRes ; }

changeIni(){ [ "$oldini" = "$newini" ] || [ "$newini" = "" ] || setIni ; }
setIni()   { echo "$oldini" > $hom/buInifiles/$(mydate)inifile; echo "$newini" > $hom/inifile ; }
readIni()  { oldini=$(cat inifile); iniurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"
             newini=$( curl -s --max-time 5 $iniurl 2> /dev/null | dos2unix ); xexit=$?
             [ $xexit -eq 0 ] && changeIni ; }

main()     { atBoot; setScrRes; readIni; }

main

