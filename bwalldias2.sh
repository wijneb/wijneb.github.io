#!/bin/sh

url1=https://leeuwenbergh.e-golf4u.nl/app/narrowcasting/teetime/dag?course_id=2 
url2=https://leeuwenbergh.e-golf4u.nl/app/narrowcasting/teetime/dag?course_id=3 
url3=https://leeuwenbergh.e-golf4u.nl/app/narrowcasting/teetime/dag?course_id=23

pic1=pics2/hole1.png
pic2=pics2/hole10.png
pic3=pics2/hole13.png

WIDTH=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $1}')
HEIGHT=$(xrandr 2>/dev/null | grep "0.00" | awk -Fx '{print $2}' | awk '{print $1}')
export WIDTH
export HEIGHT

source /home/bw/sel/venv/bin/activate

makediaE() {
    python snap2.py
}

makediaT() {
    python snap.py
}

alldias() {
    for i in $(seq 3); do
        eval URLX=\$url$i
        eval PICX=\$pic$i
        export URLX
        export PICX
        makediaE
    done
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
        feh --fullscreen --slideshow-delay 10 -R 60 pics2 &
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




