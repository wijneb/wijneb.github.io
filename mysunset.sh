#!/bin/sh

# time="11:22"             # als vb

offset=3600

mytimetosecs() {
    hours=$(echo $time | awk -F: '{print $1}')
    minutes=$(echo $time | awk -F: '{print $2}')
    seconds=$((hours * 3600 + minutes * 60))
}

checksunset() {
    echo "sunsetflag=1" > sunsetflag
    mnd=$(date +%h)                                                    # maand (Sep)
    mdy=$(date +%d)                                                    # dag van de maand
    dys=$(awk -v month="$mnd" '$0 ~ month {print $2}' mysunsets)       # aantal dagen deze maand
    ss1=$(awk -v month="$mnd" '$0 ~ month {print $3}' mysunsets)       # sunset time 1e deze mnd
    dif=$(awk -v month="$mnd" '$0 ~ month {print $5}' mysunsets)       # sunset mnd delta in min
    time=$ss1; mytimetosecs; sss=$seconds                              # sunset 1e vd mnd in seconds
    dif1=$(($dif * 60))                                                # mnd sunset delta in sec
    mfr=$(echo "scale=2 ; $mdy/$dys" | bc)                             # dagvdmnd/aantaldgnmnd
    dsc=$(echo "scale=2 ; $mfr*$dif1" | bc)                            # delta secs tov ss 1e vd mnd
    ssx=$(echo "scale=2 ; $sss + $dsc" | bc)                           # sunset vandaag in seconds
    now=$(( 3600*$(date +%H) + 60*$(date +%M) ))                       # tijd nu in seconds
    now1=$(($now + $offset))                                           # tijd nu + offset in seconds
    mysub=$(echo "scale=2 ; $now1-$ssx" | bc)                          # delta tussen tijd+offset en sunset
    sunsetflag=$(echo "$mysub < 0" | bc -l)                            # tijd+offset-sunset<0 dan flag=1  
    echo "sunsetflag=$sunsetflag" > sunsetflag
}


testing() {
nowhrs=$(echo "scale=2 ; $now/3600" | bc)
ssxhrs=$(echo "scale=2 ; $ssx/3600" | bc)
now1hrs=$(echo "scale=2 ; $now1/3600" | bc)

echo "now in secs is: $now en in hrs: $nowhrs"
echo "now1 is : $now1hrs"
echo "sunset in secs is: $ssx en in hrs: $ssxhrs"
echo "tijd + offset - sunset is: $mysub"
echo "sunsetflag is: $sunsetflag"
}

checksunset
testing


