#!/bin/sh

date >> mylog
echo "started fresh boot"  >> mylog

myurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"

source /home/bw/sel/venv/bin/activate            # activeer python virt env

WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
export WIDTH; export HEIGHT

mysunsets="\
Jan  31 16:39 17:25 45
Feb  28 17:27 18:19 52
Mrt  31 18:21 20:14 113
Apr  30 20:16 21:06 50
May  31 21:08 21:53 45
Jun  30 21:54 22:08 74
Jul  31 22:07 21:35 -32
Aug  31 21:33 20:31 -58
Sep  30 20:29 19:21 -65
Oct  31 19:18 17:14 -122
Nov  30 17:12 16:33 -59
Dec  31 16:32 16:39 7"

mytimetosecs() {
    hours=$(echo $time | awk -F: '{print $1}')
    minutes=$(echo $time | awk -F: '{print $2}')
    seconds=$((hours * 3600 + minutes * 60))
}

checksunset() {
    mnd=$(date +%h)                                       # maand (Sep)
    mdy=$(date +%d)                                       # dag van de maand
    thmnd=$(echo "$mysunsets" | grep "$mnd")              # get this mnd data
    dys=$(echo $thmnd | awk '{print $2}')                 # x dagen deze maand
    ss1=$(echo $thmnd | awk '{print $3}')                 # sunset 1e deze mnd
    dif=$(echo $thmnd | awk '{print $5}')                 # mnd sunset delta in min
    time=$ss1; mytimetosecs; sss=$seconds                 # sunset 1e vd mnd in seconds
    time=$sunoff; mytimetosecs; offset=$seconds           # set offeset tov sunset in seconds
    dif1=$(($dif * 60))                                   # mnd sunset delta in sec
    mfr=$(echo "scale=2 ; $mdy/$dys" | bc)                # dagvdmnd/aantaldgnmnd
    dsc=$(echo "scale=2 ; $mfr*$dif1" | bc)               # delta secs tov sunset 1e vd mnd
    ssx=$(echo "scale=2 ; $sss + $dsc" | bc)              # sunset vandaag in seconds
    now=$(( 3600*$(date +%H) + 60*$(date +%M) ))          # tijd nu in seconds
    now1=$(($now + $offset))                              # tijd nu + offset in seconds
    mysub=$(echo "scale=2 ; $now1-$ssx" | bc)             # delta tussen tijd+offset en sunset
    sunsetflag=$(echo "$mysub < 0" | bc -l)               # tijd+offset-sunset<0 dan flag=1   
    echo "over $mysub seconden geen starttijden meer"   
}

readinifile() {
    myfile=$(curl -s $myurl | dos2unix)
    T_urls=$(echo "$myfile" | grep T_URL | awk -F= '{print $2}')
    T_pics=$(echo "$myfile" | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(echo "$myfile" | grep E_URL | awk -F= '{print $2 "=" $3}')
    E_pics=$(echo "$myfile" | grep E_TIT | awk -F= '{print $2}')
    Delays=$(echo "$myfile" | grep GENER | awk -F= '{print $2}')
    sunoff=$(echo "$myfile" | grep SUNSE | awk -F= '{print $2}')
    # echo "inifile is: '$myfile'"
}

makediaE() {
    python snap2.py
}

makediaT() {
    python snap.py
}

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

getUrlsNames() {
    getUrls; getPicnames
}

makeDias() {
    for i in $(seq $xnr); do
        eval URLX=\$url$i
        eval PICX=\$pic$i
        URLX=${URLX#\"}
        URLX=${URLX%\"}
        PICX=${PICX}.png
        export URLX; #echo $URLX
        export PICX; #echo $PICX
        if [ $Tflag -eq 1 ]; then 
            # echo "doing Tmakedia"
              makediaT; 
            else
            # echo "doing Emakedia"
              makediaE
        fi
    done
}

alldias() {
    #echo "reading ini file"
    readinifile
    #echo "makedias T-flag"
    Tflag=1; Xurls="$T_urls"; Xpics="$T_pics"; getUrlsNames; makeDias 
    #echo "going to check sunset"
    checksunset
    if [ $sunsetflag -eq 1 ]; then
        #echo "makedias E-flag"
        Tflag=0; Xurls="$E_urls"; Xpics="$E_pics"; getUrlsNames; makeDias
    fi
    #echo "rm pics/*, cp pic2/* to pics; rm pics2/*" 
    rm -r pics/* ; cp -r pics2/* pics; rm -r pics2/*
}

statusTrue() { 
    # date
    # echo "Wi-Fi and chronyd up and running" 
    alldias 
}

statusFalse() { 
    date 
    echo "reboot in 900 sec" 
    sleep 900 
    doas /sbin/reboot 
}

setWifiClockFlags(){
    #test if this works, 1 is ok 0 is not ok.
    WIFI_STATUS=$(ip link show wlan0 | grep "state UP" | wc -l)
    CHRONYD_STATUS=$(rc-service chronyd status | grep "started" | wc -l)
    wificlockOK="[ \$WIFI_STATUS -eq 1 ] && [ \$CHRONYD_STATUS -eq 1 ]"
    clockOK="[ \$CHRONYD_STATUS -eq 1 ]"
}

checkWifiAndClock(){ 
    setWifiClockFlags
    if eval "$wificlockOK"; then
        statusTrue
    else
        statusFalse
    fi
}

clockrestart() {
    date; echo "restarting clock (10 sec)"
    doas /sbin/rc-service chronyd restart > /dev/null     
    # sleep 15
}

checkClock(){ setWifiClockFlags
    if !(eval "$clockOK"); then
        clockrestart
    fi
}

startdiashow() {
    if !(pgrep -x "feh") > /dev/null; then
        # date; echo "delay : $Delays starting diashow"
        feh --fullscreen --slideshow-delay $Delays -R 60 pics &
        xdotool mousemove $WIDTH $HEIGHT # muis rechtsonder
    fi
}

startsnapshotting() {
#   while true; do
        readinifile
        startdiashow       # als diashow niet al draait dan starten   
        checkClock         # if clock not ok restart clock (chronyd) 
        checkWifiAndClock  # if clock and wifi ok make pics, else reboot in 15 min
      # echo "going to sleep for 8 min"
        checkdpmsoff       # scherm uit om 2200 uur 
      # checkboottime      # reboot om 0800 uur
        sleep 480          # loop, om de 8 min nieuwe snapshots (pics)
#   done
}

checkboottime() {
    boot1=$((7*3600 + 38*60))                                    # reboot om 8 uur
    boot2=$(($boot1 + 16*60))                                    # window = 16 min
    boottime="[ \$now -ge $boot1 ] && [ \$now -lt $boot2 ]"      
    if eval $boottime; then doas /sbin/reboot; fi                # reboot if in window
}

checkdpmsoff() {
    dpms1=$((22*3600 - 9*60)); #echo "dpms1 $dpms1"                      # 22:00 dpmsoff 
    dpms2=$(($dpms1 + 16*60)); #echo "nopw $now dpms2 $dpms2"            # window = 16 min
    dpmstime="[ \$now -ge $dpms1 ] && [ \$now -lt $dpms2 ]"              
    if eval $dpmstime; then 
       sleep 1000; 
       doas /usr/local/bin/dpmsoff; 
       echo "did dpmsoff at $(date +%H):$(date +%M)" >> mylog
    fi                                                                   # wait until outside window
}

main() {
    clockrestart                                                 # just to be sure, restart clock
    strTime=$((7*3600)); endTime=$((22*3600))                    # start na reboot vanaf 7 uur, end om 22 uur
    now=$(( 3600*$(date +%H) + 60*$(date +%M) ))                 # now is also set within sunsetcheck
    runtime="[ \$now -gt $strTime ] && [ \$now -lt $endTime ]"   # now is time in sec, reset in main
    while eval $runtime; do startsnapshotting; done              # loopt tot 22 uur en start na boot om 8 uur
    while true; do sleep 540; checkboottime; done                # na 2200, check if boottime om 9 min
}                                                                # reboot om 0800 uur

#echo "done reading fuctions, starting main"

main

