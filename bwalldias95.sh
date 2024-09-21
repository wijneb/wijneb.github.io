#!/bin/sh

bootflag="false"; dpmsflag="false"

myurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"

source /home/bw/sel/venv/bin/activate            # activeer python virt env

WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
export WIDTH; export HEIGHT

zomerwintertijd='
    zomer&wintertijd2024 ; 2024-03-30 ; 2024-10-27 
    zomer&wintertijd2025 ; 2025-03-29 ; 2025-10-26
    zomer&wintertijd2026 ; 2026-03-28 ; 2026-10-25
    zomer&wintertijd2027 ; 2027-03-27 ; 2027-10-31
'

readinifile() {
    myfile=$(curl -s $myurl | dos2unix)
    T_urls=$(echo "$myfile" | grep T_URL | awk -F= '{print $2}')
    T_pics=$(echo "$myfile" | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(echo "$myfile" | grep E_URL | awk -F= '{print $2 "=" $3}')
    E_pics=$(echo "$myfile" | grep E_TIT | awk -F= '{print $2}')
    Delays=$(echo "$myfile" | grep GENER | awk -F= '{print $2}')
    sunoff=$(echo "$myfile" | grep SUNSE | awk -F= '{print $2}')
}

mysunset() {  
    year=$(date +%Y) ; todaynr=$(date +%-j) ; amp=137 ; avg=1131  # (UTC +1, wintertijd)
    WT=$(echo "$zomerwintertijd" | awk -F";" -v year="$year" '$0 ~ year {print $3}')
    ZT=$(echo "$zomerwintertijd" | awk -F";" -v year="$year" '$0 ~ year {print $2}')
    WTD=$(date -d $WT +%-j); ZTD=$(date -d $ZT +%-j)  # winter- en zomertijd in dagnr
    sns1() { # sns1 is een hulpfunctie tbv zomer/wintertijd en tbv offset tov kortste dag
        if [ $dyn -gt $ZTD ] && [ $dyn -lt $WTD ]; then avg=1191; else avg=1131; fi # summertime
        if [ $dyn -gt 355 ]; then dyn=$dyn-355; fi  # 21 december kortste dag, offset=10dgn
    }
    sns() { dyn=$1; sns1; echo "scale=2; $avg-$amp*c(2*3.14*($dyn+10)/365)" | bc -l; }
    sunset=$(sns $todaynr) ; sunset1=$(echo "scale=2; $sunset / 60" | bc -l) 
}   #sunset is sunset in minuts, sunset1=sunset in hrs


timetominutes() { time=$1; echo $((10#${time:0:2} * 60 + 10#${time:3:2})); }

checksunset() {     
    offsetm=$(timetominutes $sunoff)                      # set offset tov sunset in minutes
    nowm=$(( 60*$(date +%-H) + $(date +%-M) ))            # tijd nu in minutes
    now1m=$(($nowm + $offsetm))                           # tijd nu + offset in minutes
    mysubm=$(echo "scale=2 ; $now1m-$sunset" | bc)        # delta tussen tijd+offset en sunset in minutes
    sunsetflag=$(echo "$mysubm < 0" | bc)                 # tijd+offset-sunset<0 dan flag=1 
  # echo "over $mysubm minutes geen starttijden meer"   
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
    Tflag=1; Xurls="$T_urls"; Xpics="$T_pics"; getUrlsNames; makeDias;  
    checksunset # na sunset-offset geen starttijden meer, flag is dan 0
    if [ $sunsetflag -eq 1 ]; then
        Tflag=0; Xurls="$E_urls"; Xpics="$E_pics"; getUrlsNames; makeDias
    fi; rm -r pics/* ; cp -r pics2/* pics; rm -r pics2/*
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
    current_hour=$(date +%-H)
    if [ $current_hour -ge 8 ] && [ $current_hour -lt 22 ]; 
        then startsnapshotting; bootflag="true"
        else checkdpmsoff; checkboottime; sleep 540
    fi
}

main() { 
    clockrestart 
    mysunset
    echo $(date) "sunset in decimal hours:" $sunset1 
    while true; do myruntime; done 
}                                                                

main

