#!/bin/sh
         
setEnvVars(){ oldini=$(cat inifile); snapTrm=$(cat snap.py); snapEgf=$(cat snap2.py) 
    T_urls=$(echo "$oldini" | grep T_URL | awk -F= '{print $2}')
    T_pics=$(echo "$oldini" | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(echo "$oldini" | grep E_URL | awk -F= '{print $2 "=" $3}')
    E_pics=$(echo "$oldini" | grep E_TIT | awk -F= '{print $2}')
    Delays=$(echo "$oldini" | grep GENER | awk -F= '{print $2}')
    sunoff=$(echo "$oldini" | grep SUNSE | awk -F= '{print $2}')
}

inisetup(){
    setEnvVars # sets local file environment variables, can be updated; makes early startdiashow in main mogelijk 
    iniurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"; egfurl="https://leeuwenbergh.e-golf4u.nl"
    trmsht=$(cat inifile | grep T_URL_01 | awk -F'"' '{print $2}')  # is een redirect: "https://tm-short.me/77wP26z"
    trmurl=$(curl -s -I -X GET $trmsht | awk -F":" '/location/{print $2":"$3}' | tr -d '\r'); }  # is endurllocation

timetominutes(){ time=$1; echo $((10#${time:0:2} * 60 + 10#${time:3:2})); }

mydate(){ date +"%b %d %H:%M" ; }
mymsg() { echo "$(mydate) $1" ; }

showhd(){ echo "$(curl -sI --max-time 5 $1 2> /dev/null)"; }               # input is url en laat dan de header zien
gethds(){ HI=$(showhd $iniurl); HE=$(showhd $egfurl); HT=$(showhd $trmurl); } # gets headers van urls, ini egf en trm
gethd() { gethds; R=$HI && [ -z "$R" ] && R=$HT && [ -z "$R" ] && R=$HE; 
        [ -z "$R" ] && mymsg "no sites" && statusFalse;  echo "$R"; } # if no reboot then var R has header

inisiteok() { iniflag=0; [ -z "$(showhd $iniurl)" ] && iniflag=1 || mymsg "no ini site"; }
egfsiteok() { egfflag=0; [ -z "$(showhd $egfurl)" ] && egfflag=1 || mymsg "no egf site"; }
trmsiteok() { trmflag=0; [ -z "$(showhd $trmurl)" ] && trmflag=1 || mymsg "no trm site"; }

#inisiteok()    { inihead=$(curl -sI --max-time 5 $iniurl 2> /dev/null); [ $? = 0 ] && iniflag=0 || iniflag=1 ; }
#trmsiteok()    { trmhead=$(curl -sI --max-time 5 $trmurl 2> /dev/null); [ $? = 0 ] && trmflag=0 || trmflag=1 ; }
#egfsiteok()    { egfhead=$(curl -sI --max-time 5 $egfurl 2> /dev/null); [ $? = 0 ] && egfflag=0 || egfflag=1 ; }

oldinifile()   { oldini=$(cat inifile); }
setnewinif()   { echo "$getnew" > inifile ; }
newinifile()   { inisiteok; [ $iniflag = 1 ] && getnew=$oldini || getnew=$(curl -s $iniurl | dos2unix); }
chcknewini()   { [ "$getnew" = "" ] && getnew=$oldini && difflag="no" || setnewinif && difflag="yes" ; }
difinifile()   { [ "$oldini" = "$getnew" ] && difflag="no" || chcknewini ; }
initomylog()   { [ "$difflag" = "yes" ] && mymsg "change in inifile detected" ; }
readinifile()  { oldinifile; newinifile; difinifile; oldinifile; setEnvVars; initomylog ; }

datetimerpihdr(){ # this checks if rpi time and date are equal to trm time and date and thus if internet is ok
    hdrtime=$(datetime | awk '{print $6}' | awk -F":" '{print $1":"$2}')
    hdrdate=$(datetime | awk '{print $4,int($3)}');  
    rpidate=$(date +"%b %d");  rpitime=$(TZ=UTC date +"%H:%M");  
    [ "$(TZ=UTC date +'%b %d %H:%M')" = "${hdrdate} ${hdrtime}" ] && timedate=true || timedate=false
    [ "$(date +'%H')" = "00" ] && timedate=true ; } # 23:00 UTC gaat t fout omdat rpi dan al nieuwe dag begint

datetime() { gethd | grep date ; } # gets date and time from header of 1 of either 3 sites (ini,egf, trm)
checkdate(){ datetimerpihdr; $timedate || datidiff ; }  # als timedate false is dan reboot via dati diff
datidiff() { datimsg; mymsg "date or time error, rebooting in 60s"; sleep 60; doas /sbin/reboot ; } 
datimsg()  { mymsg "$rpidate $rpitime is rpi date-GMT, trm date-GMT is: $hdrdate $hdrtime" ; }
checkclck(){ ! rc-service chronyd status | grep "started" &> /dev/null && echo "noclock?" && clockrestart ; }

checksunset() {
    mnd=$(date +%-h)                                      # maand (Sep)
    mdy=$(date +%-d)                                      # dag van de maand
    thmnd=$(echo "$mysunsets" | grep "$mnd")              # get this mnd data
    dys=$(echo $thmnd | awk '{print $2}')                 # x dagen deze maand
    ss1=$(echo $thmnd | awk '{print $3}')                 # sunset 1e deze mnd
    dif=$(echo $thmnd | awk '{print $5}')                 # mnd sunset delta in min
    ssm=$(timetominutes $ss1)                             # sunset 1e vd maand in minutes
    offsetm=$(timetominutes $sunoff)                      # set offset tov sunset in minutes 
    mfr=$(echo "scale=2 ; $mdy/$dys" | bc)                # dagvdmnd/aantaldgnmnd
    dscm=$(echo "scale=2 ; $mfr*$dif" | bc)               # delta minutes tov sunset 1e vd mnd
    ssxm=$(echo "scale=2 ; $ssm + $dscm" | bc)            # sunset vandaag in minutes
    nowm=$(( 60*$(date +%-H) + $(date +%-M) ))            # tijd nu in minutes
    now1m=$(($nowm + $offsetm))                           # tijd nu + offset in minutes
    mysubm=$(echo "scale=2 ; $now1m-$ssxm" | bc)          # delta tussen tijd+offset en sunset in minutes
    sunsetflag=$(echo "$mysubm < 0" | bc)                 # tijd+offset-sunset<0 dan flag=1 
  # echo "over $mysubm minutes geen starttijden meer"   
}

snapTrm()      { echo "$pytrm" | python - ; }
snapEgf()      { echo "$pyegf" | python - ; }
getUrlsNames() { getUrls; getPicnames; }

# makediaT()     { python snap.py; }; 
# makediaE()     { python snap2.py; }

makediaT() { trmsiteok; [ $trmflag = 0 ] && python snap.py || echo -en "\n$(mydate) no trm pic $i made no trm site " ; } 
makediaE() { egfsiteok; [ $egfflag = 0 ] && python snap2.py || echo -en "\n$(mydate) no egf pic $i made no egf site  " ; }

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

getTpics(){ Tflag=1; Xurls="$T_urls"; Xpics="$T_pics"; getUrlsNames; makeDias; }
getEpics(){ Tflag=0; Xurls="$E_urls"; Xpics="$E_pics"; getUrlsNames; makeDias; }
movpics2(){ rm -r pics/* ; cp -r pics2/* pics; rm -r pics2/* ; }
nopics()  { mymsg "less the 2 pics in pics2?" ; }

alldias() { getTpics; checksunset; [ $sunsetflag -eq 1 ] && getEpics
            deleted_files=$(find "pics2" -type f -name "*.png" -size -"100k" -print -delete)
            [ -n "$deleted_files" ] && echo -e "$(mydate) Deleted smaller pics: \n$deleted_files" >> monlog
            [ $(ls pics2 | grep png | wc -w) -gt 1 ] && movpics2 || nopics ; }

ctr()          { nr=$((nr+1)); [ $nr = 6 ] && nr=1; [ $nr = 5 ] && echo -n "c$nr " || echo -n "c$nr" ; }
clockrestart() { doas /sbin/rc-service chronyd restart > /dev/null ; echo -e "\n$(mydate) clockrestarted" ; }
statusFalse()  { mymsg "reboot in 15 min" ; sleep 900; doas /sbin/reboot ; }
checkall()     { ctr; checktrmn; ctr; checkeglf; ctr; checkinif; ctr; checkclck; ctr; checkdate; }


#mycheck()      { ( [ -z $tr ] || [ $tr = 6 ] ) && echo "$1" ; }
#curlmsg()  { echo "$(mydate) no curl from $1 site" ; }
#checktrmn(){ trmsiteok; [ trmflag = 1 ] && curlmsg "trackman" && statusFalse ; }
#checkeglf(){ egfsiteok; [ egfflag = 1 ] && curlmsg "egolf" ; }
#checkinif(){ inisiteok; [ iniflag = 1 ] && curlmsg "ini" ; }
#checkdate(){ days=$(( ($(date -d $(date +%Y-%m-%d) +%s) - $(date -d $(cat yesterday) +%s)) / 86400 ))
#             [ $days -lt 1 ] && statusFalse ; [ $days -gt 1 ] && mycheck "$(mydate) daysdiff is: $days" ; }

startdiashow() {
    if !(pgrep -x "feh") > /dev/null; then
        feh --fullscreen --slideshow-delay $Delays -R 60 pics 2>> monlog &
        xdotool mousemove $WIDTH $HEIGHT # muis rechtsonder
    fi
}

startsnapshotting() { 
    checkall
    atsix                                        
    readinifile; 
    startdiashow                              # als diashow niet al draait dan starten   
    alldias     
    sleep 480                                 # loop, om de 8 min nieuwe snapshots (pics)
}

mycount()       { tr=$((tr+1)); [ $tr -eq 7 ] && tr=1 ; }
atsix()         { [ $tr -ne 6 ] && echo -n $tr || ( [ -z $dpmsflag ] && echo $tr || echo "$tr offtime" ) ; } 
# atsix()       { ! [ $tr = 6 ] && echo -n "$tr " || ( [ -z $dpmsflag ] && echo $tr || echo "$tr offtime" ) ; }
checkdpmsoff()  { [ -z $dpmsflag ] && [ $current_hour -ne 7 ] && dpmsflag="true" && /usr/local/bin/dpmsoff ; }
checkboottime() { [ $current_hour = 6 ] && (   $bootflag ) && bootflag=false
                  [ $current_hour = 7 ] && ( ! $bootflag ) && doas /sbin/reboot ; }

checkboottime1(){ [ $current_hour = 6 ] && [ -z $bootflag ] && bootflag=false
                  [ $current_hour = 7 ] && (  ! $bootflag ) && doas /sbin/reboot ; }

                
myruntime() {  
    current_hour=$(date +%-H); mycount; [ $tr = 1 ] && echo -n "$(mydate) "
    if [ $current_hour -ge 8 ] && [ $current_hour -lt 22 ]; then startsnapshotting;              
        else atsix; checkboottime; checkdpmsoff; sleep 480; 
    fi
}
















            