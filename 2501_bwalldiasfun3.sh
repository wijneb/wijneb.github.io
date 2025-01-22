#!/bin/sh

getWH(){ eval $( cat $loc/scrRes | awk -Fx '{print "export WIDTH="int($1) "\nexport HEIGHT="int($2)}' ); }

setEnvVars(){ getWH; oldini=$(cat $loc/inifile);  
    pytrm=$(cat $loc/snap.py); pyegf=$(cat $loc/snap2.py) 
    T_urls=$(echo "$oldini" | grep T_URL | awk -F= '{print $2}')
    T_pics=$(echo "$oldini" | grep T_TIT | awk -F= '{print $2}')
    E_urls=$(echo "$oldini" | grep E_URL | awk -F= '{print $2 "=" $3}')F
    E_pics=$(echo "$oldini" | grep E_TIT | awk -F= '{print $2}')
    Delays=$(echo "$oldini" | grep GENER | awk -F= '{print $2}')
    sunoff=$(echo "$oldini" | grep SUNSE | awk -F= '{print $2}')
    } # sets all environmental vars

inisetup(){
    setEnvVars # sets environment variables, can be updated;  
    iniurl="https://www.leeuwenbergh.nl/infoscreens/hal_1.ini"; egfurl="https://leeuwenbergh.e-golf4u.nl"
    trmsht=$(cat $loc/inifile | grep T_URL_01 | awk -F'"' '{print $2}')  # redirect: "https://tm-short.me/77wP26z"
    trmurl=$(curl -sI --max-time 5 -X GET $trmsht | awk -F":" '/location/{print $2":"$3}' | tr -d '\r') 2>> logs/monlog2 
    } # trm-url is url endlocation, trm-sht is een redirect url naar trm-url end location url

mydate1()      { date +"%b %d %H:%M" ; }
mydate()       { date +%d%b%H:%M ; }
mymsg()        { echo ""; echo "$(mydate) $1" ; }
statusFalse()  { mymsg "reboot in 3 min" ; sleep 180; doas /sbin/reboot ; sleep 180 ; }
timetominutes(){ time=$1; echo $((10#${time:0:2} * 60 + 10#${time:3:2})); }

showhd()     { curl -sI --max-time 5 $1 2> /dev/null; }                 # shows  header data of input url
inisiteok()  { iniflag=false; HI=$(showhd $iniurl); [ -z "$HI" ] && mymsg "no ini site" || iniflag=true && R=$HI; }
egfsiteok()  { egfflag=false; HE=$(showhd $egfurl); [ -z "$HE" ] && mymsg "no egf site" || egfflag=true && R=$HE; }
trmsiteok()  { trmflag=false; HT=$(showhd $trmurl); [ -z "$HT" ] && mymsg "no trm site" || trmflag=true && R=$HT; }
gethd()      { R=""; inisiteok;trmsiteok;egfsiteok; [ -z "$R" ]  && mymsg "no sites" && statusFalse || echo "$R"; }

inidos()     { curl -s --max-time 5 $iniurl 2> /dev/null | dos2unix; }  # shows inisite data (from windows)
ininew()     { iniflag=false; HI=$(inidos); [ -z "$HI" ] && mymsg "no inidos site data" || iniflag=true ; }
oldinifile() { oldini=$(cat $loc/inifile); }
setnewinif() { echo "$getnew" > $loc/inifile ; }
newinifile() { ininew; $iniflag && getnew=$HI || getnew=$oldini; }
chcknewini() { [ "$getnew" = "" ] && getnew=$oldini && difflag="no" || setnewinif && difflag="yes" ; }
difinifile() { [ "$oldini" = "$getnew" ] && difflag="no" || chcknewini ; }
inifchange() { [ "$difflag" = "yes" ] && mymsg "change in inifile detected" && oldinifile && setEnvVars; }
readinifle1() { oldinifile; newinifile; difinifile; inifchange ; }

readinifle() { setEnvVars; }

hdrdati1()  { hdrtime=$(datetime | awk '{print $6}' | awk -F":" '{print $1":"$2}')
              hdrdate=$(datetime | awk '{print $4,int($3)}'); hdrmins=$(timetominutes $hdrtime); }

hdrdati()   { hdrtime=$(datetime | awk '{print $6}' | awk -F":" '{print $1":"$2}')
              hdrdate=$(datetime | awk '{print $4,$3}'); hdrmins=$(timetominutes $hdrtime); }

rpidati()   { rpidate=$(TZ=UTC date +"%b %d"); rpitime=$(TZ=UTC date +"%H:%M"); rpimins=$(timetominutes $rpitime); }
deltamins() { diff=$((rpimins-$hdrmins)); [ $diff -lt 0 ] && diff=$((-diff)); echo $diff; }
datirpihdr(){ hdrdati; rpidati; [ "$hdrdate" = "$rpidate" ] &&  
            [ $(deltamins) -lt 3 ] && timedate=true || timedate=false; }

datetime()  { gethd | grep -i ^date ; } # gets date and time from header of 1 of either 3 sites (ini,egf, trm)
checkdate() { datirpihdr; $timedate || datidiff ; }  # als timedate false is dan reboot via dati diff
datidiff()  { datimsg; mymsg "date or time error, rebooting in 60s"; sleep 60; doas /sbin/reboot ; sleep 60 ; } 
datimsg()   { mymsg "$rpidate $rpitime is rpi date-GMT, hdr date-GMT is: $hdrdate $hdrtime" ; }
checkclck() { ! rc-service chronyd status | grep "started" &> /dev/null && echo "noclock?" && clrestart ; }
clrestart() { doas /sbin/rc-service chronyd restart > /dev/null ; echo -e "\n$(mydate) clockrestarted" ; }

mysunset() {
    mdn=$(date +%-m) ; dyn=$(date +%-d) ; dyn=$((dyn+1)) ; mdn=$((mdn+1))
    mysun=$(cat sun2024.csv | awk -F";" -v r=$dyn -v c=$mdn 'NR==r {print $c}') 
    sunsethr=$(echo $mysun | cut -d'/' -f2  | tr -d '"')  # sunset bv =>  16:35
    sunset=$(timetominutes $sunsethr); # echo "sunset is" $sunsethr "hrs, or" $sunset "minutes" 
    }

checksunset() { mysunset    
    offsetm=$(timetominutes $sunoff)                                 # set offset tov sunset in minutes (integer)
    nowm=$(( 60*$(date +%-H) + $(date +%-M) ))                       # tijd nu in minutes (integer)
    sunsetflag=$(echo "$((nowm+offsetm-sunset)) < 0" | bc)           # tijd+offset-sunset<0 dan flag=1 else 0
  # echo "starttijden stopt over $((sunset-nowm-offsetm)) minutes"   
    }  

Tpicmsg(){ echo -en "\n$(mydate) no trm pic $i made no trm site, trmflag is $trmflag" ; }
Epicmsg(){ echo -en "\n$(mydate) no egf pic $i made no egf site, egfflag is $egfflag" ; }

snapTrm()  { echo "$pytrm" | python - ; }
snapEgf()  { echo "$pyegf" | python - ; }

makediaT() { trmsiteok; $trmflag && snapTrm || Tpicmsg ; } # if site ok calls python script
makediaE() { egfsiteok; $egfflag && snapEgf || Epicmsg ; } # if site ok calls python script

getTpics() { Tflag=true;  stu=$T_urls; stp=$T_pics; myPics; }  # take T pics
getEpics() { Tflag=false; stu=$E_urls; stp=$E_pics; myPics; }  # take E pics 

funu()  { echo $stu | awk -v pos=$1 '{print $pos}' ; }  # hulp fun(ction) gets 1 url lctn from string
funp()  { echo $stp | awk -v pos=$1 '{print $pos}' ; }  # hulp fun(xtion) gets 1 pic name from string

myPics(){
  nr=$(echo $stu | wc -w) ; for i in $(seq $nr); do 
  URLX=$(funu $i); URLX=${URLX#\"}; URLX=${URLX%\"}; export URLX 
  PICX=$(funp $i); PICX=${PICX#\"}; PICX=${PICX%\"}; PICX=$loc/pics2/${PICX}.png; export PICX
  $Tflag && makediaT || makediaE
  done ; }  # iterates through string, gets url and pic-name and calls pyscript per url/pic-name

movpics2() { rm -rf $loc/pics/* ; cp -r $loc/pics2/* $loc/pics; rm -rf $loc/pics2/* ; }
nopics()   { mymsg "less the 2 pics in pics2?" ; }

alldias()  { getTpics; checksunset; [ $sunsetflag -eq 1 ] && getEpics
             deleted_files=$(find "$loc/pics2" -type f -name "*.png" -size -"100k" -print -delete)
             [ -n "$deleted_files" ] && echo -e "$(mydate) Deleted smaller pics: \n$deleted_files" >> $lg1
             [ $(ls $loc/pics2 | grep png | wc -w) -gt 1 ] && movpics2 || nopics ; }

ctr()      { nr=$((nr+1)); [ $nr = 6 ] && nr=1; [ $nr = 5 ] && echo -n "c$nr " || echo -n "c$nr" ; }
checkall() { ctr; trmsiteok; ctr; egfsiteok; ctr; inisiteok; ctr; checkclck; ctr; checkdate; }

mycount()  { tr=$((tr+1)); [ $tr -eq 7 ] && tr=1 ; }
atsix()    { [ $tr -ne 6 ] && echo -n "$tr " || ( [ -z $dpmsflag ] && echo $tr || echo "$tr offtime" ) ; } 

atruntime(){ [ $(date +"%-H") -ge 8 ] && [ $(date +"%-H") -lt 22 ] && echo true || echo false; }

# onceTrue(){ $bootflag || bootflag=true; }; onceFalse(){ $bootflag && bootflag=false; }
# myfun(){ x=$1; eval $x=$2; eval echo "variable /$$1 is \$$x"; }; myfun flag true

          
