#!/bin/sh

bootflag="false"; dpmsflag="false"

myurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"

source /home/bw/sel/venv/bin/activate            # activeer python virt env

WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
export WIDTH; export HEIGHT

readinifile() {
    myfile=$(curl -s $myurl | dos2unix)
    T_urls=$(echo "$myfile" | grep T_URL | awk -F= '{print $2}')
    T_pics=$(echo "$myfile" | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(echo "$myfile" | grep E_URL | awk -F= '{print $2 "=" $3}')
    E_pics=$(echo "$myfile" | grep E_TIT | awk -F= '{print $2}')
    Delays=$(echo "$myfile" | grep GENER | awk -F= '{print $2}')
    sunoff=$(echo "$myfile" | grep SUNSE | awk -F= '{print $2}')
}

timetominutes() { time=$1; echo $((10#${time:0:2} * 60 + 10#${time:3:2})); }

mysunset() {
    mdn=$(date +%-m) ; dyn=$(date +%-d) ; dyn=$((dyn+1)) ; mdn=$((mdn+1))
    mysun=$(cat sun2024.csv | awk -F";" -v r=$dyn -v c=$mdn 'NR==r {print $c}') 
    sunsethr=$(echo $mysun | cut -d'/' -f2  | tr -d '"')  # sunset bv =>  16:35
    sunset=$(timetominutes $sunsethr); echo "sunset is" $sunsethr "hrs, or" $sunset "minutes" 
}

checksunset() {     
    offsetm=$(timetominutes $sunoff)                                 # set offset tov sunset in minutes (integer)
    nowm=$(( 60*$(date +%-H) + $(date +%-M) ))                       # tijd nu in minutes (integer)
    sunsetflag=$(echo "$((nowm+offsetm-sunset)) < 0" | bc)           # tijd+offset-sunset<0 dan flag=1 else 0
  # echo "starttijden stopt over $((nowm+offsetm-sunset)) minutes"   
}

makediaT() { python snap.py; }; makediaE() { python snap2.py; }

getUrls() {
    i=0  # Initialize counter voor urls
    for url in $Xurls; do
        i=$((i + 1))
        eval url$i=\$url
      # echo $url
    done
    xnr=$i
}

getPicnames() {
    j=0  # Initialize counter voor pics
    for pic in $Xpics; do
        j=$((j+ 1))
      # eval pic$j=\$pic
        eval pic$j="pics2/$pic"
      # echo $pic
    done
}

getUrlsNames() { getUrls; getPicnames; }

makeDias() {
    for i in $(seq $xnr); do
        eval URLX=\$url$i
        eval PICX=\$pic$i
        URLX=${URLX#\"}
        URLX=${URLX%\"}
        PICX=${PICX}.png
        export URLX; #echo $URLX
        export PICX; #echo $PICX
        if [ $Tflag -eq 1 ]; 
          then makediaT 
          else makediaE
        fi
    done
}

alldias() { # readinifile # dubbelop met snapshooting? dus kan er uit
    # Tflag=1; Xurls="$T_urls"; Xpics="$T_pics"; getUrlsNames; makeDias;  
    # checksunset # na sunset-offset geen starttijden meer, flag is dan 0
    # if [ $sunsetflag -eq 1 ]; then
        Tflag=0; Xurls="$E_urls"; Xpics="$E_pics"; getUrlsNames; makeDias
        rm -r pics/* ; cp -r pics2/* pics; rm -r pics2/*  
    # fi
}

statusTrue() { 
    # date
    # echo "Wi-Fi and chronyd up and running" 
    alldias 
}

statusFalse() { 
    date; echo "reboot in 15 min" 
    sleep 900; doas /sbin/reboot 
}

setWifiClockFlags(){
    #test if this works, 1 is ok 0 is not ok.
    WIFI_STATUS=$(ip link show wlan0 | grep "state UP" | wc -l)
    CHRONYD_STATUS=$(rc-service chronyd status | grep "started" | wc -l)
    wificlockOK="[ \$WIFI_STATUS -eq 1 ] && [ \$CHRONYD_STATUS -eq 1 ]"
    clockOK="[ \$CHRONYD_STATUS -eq 1 ]"
}

checkWifiAndClock(){ setWifiClockFlags
    if eval "$wificlockOK"; then statusTrue; else statusFalse; fi
}

clockrestart() {
    date; echo "restarting clock (10 sec)"
    doas /sbin/rc-service chronyd restart > /dev/null     
}

checkClock(){ setWifiClockFlags
    if !(eval "$clockOK"); then clockrestart; fi
}

startdiashow() {
    if !(pgrep -x "feh") > /dev/null; then
        feh --fullscreen --slideshow-delay $Delays -R 60 pics &
        xdotool mousemove $WIDTH $HEIGHT # muis rechtsonder
    fi
}

startsnapshotting() {
    readinifile
    startdiashow       # als diashow niet al draait dan starten   
    checkClock         # if clock not ok restart clock (chronyd) 
    checkWifiAndClock  # if clock and wifi ok make pics, else reboot in 15 min
    sleep 480          # loop, om de 8 min nieuwe snapshots (pics)
}

checkdpmsoff() {
    if [ "$dpmsflag" = "false" ] && [ "$bootflag" = "true" ]; 
        then /usr/local/bin/dpmsoff; dpmsflag="true"
    fi
}

checkboottime() {
    if [ $current_hour = 7 ] && [ "$bootflag" = "true" ]; 
        then doas /sbin/reboot
    fi
}

myruntime() { 
    checksunset # na sunset-offset geen starttijden meer, flag is dan 0
    current_hour=$(date +%-H)
    if [ $current_hour -ge 8 ] && [ $sunsetflag -eq 1 ]; 
        then startsnapshotting; # bootflag="true"
        else sleep 540;  # checkdpmsoff; checkboottime; 
    fi
}

main() { 
    clockrestart 
    mysunset
    while true; do myruntime; done 
}                                                                

main

