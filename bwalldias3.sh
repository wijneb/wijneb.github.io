#!/bin/sh

myfile="hal_1.ini"
myurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"

source /home/bw/sel/venv/bin/activate

WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
export WIDTH; export HEIGHT

readinifile() {
    if [ -f $myfile ]; then rm $myfile; fi; wget -q $myurl
    T_urls=$(cat $myfile | grep T_URL | awk -F= '{print $2}')
    T_pics=$(cat $myfile | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(cat $myfile | grep E_URL | awk -F= '{print $2}')
    E_pics=$(cat $myfile | grep E_TIT | awk -F= '{print $2}')
    Delays=$(cat $myfile | grep GENER | awk -F= '{print $2}')
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
    done
    xnr=$i
}

getPicnames() {
    j=0  # Initialize counter voor pics
    for pic in $Xpics; do
        j=$((j+ 1))
        eval pic$j=\$pic
    done
}

getUrlsNames() {
    getUrls; getPicnames
}

makeDias() {
    for i in $(seq $xnr); do
        eval URLX=\$url$i
        eval PICX=\$pic$i
        export URLX
        export PICX
        if [ $Tflag -eq 1 ]; then 
            makediaT; else
            makediaE
        fi
    done
}

alldias() {
    readinifile
    Tflag=1; Xurls=$T_urls; makeDias
    Tflag=0; Xurls=$E_urls; makeDias
    rm -r pics2/* ; cp -r pics/* pics2
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

checkWifiAndClock(){ setWifiClockFlags
    if eval "$wificlockOK"; then
        statusTrue
    else
        statusFalse
    fi
}

clockrestart() {
        doas /sbin/rc-service chronyd restart > /dev/null
        sleep 15
}

checkClock(){ setWifiClockFlags
    if !(eval "$clockOK"); then
        clockrestart
    fi
}

startdiashow() {
    if !(pgrep -x "feh") > /dev/null; then
        feh --fullscreen --slideshow-delay $Delays -R 60 pics2 &
        xdotool mousemove $WIDTH $HEIGHT # muis rechtsonder
    fi
}

startsnapshotting() {
    while true; do
        startdiashow       # als diashow niet al draait dan starten   
        checkClock         # if clock not ok restart clock (chronyd) 
        checkWifiAndClock  # if clock and wifi ok make all pics, else reboot in 15 min
        sleep 480          # loop, om de 8 min nieuwe snapshots (pics)
    done
}

main() {  
    clockrestart # just to be sure, restart the clock, includes sleep 15   
    startsnapshotting  # if wifi and clock are ok make all snapshots (loop)
}

main




