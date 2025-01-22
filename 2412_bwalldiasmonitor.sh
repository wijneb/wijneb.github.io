#!/bin/sh

source /home/bw/sel/funcsbwalldias.sh            # import benodigde bash functies

# check current date and time
# check feh (tussen 8 en 22 h) pgrep -x
# check bwalldias pgrep -f
# check voortgang in pics tov current time
# checkvoortgang van mylog tov current time
# checkavg ram tijdens pics2?

chkcont="c1:trm, c2:egf, c3:ini, c4:clk, c5:date, all tested"

mymsg()     { echo "$(mydate) $1" ; }

monreboot() { mymsg "reboot in 60 seconds"; sleep 60; doas /sbin/reboot ; }
timedateok(){ mymsg "time and date are in sync, nb time diff in GMT vs actual is 1 hr" ; }

# atruntime() { thishr=$(date +%-H); [ $thishr -gt 8 ] && [ $thishr -lt 22 ] && echo 0 ; } # is in funcs
checkfeh()  { thishr=$(date +%-H); [ $thishr -gt 8 ] && [ $thishr -lt 22 ] && mymsg "nofeh" && startdiashow ; }
prxfeh()    { pgrep -x "feh" ; }; 
prmain()    { pgrep -f "bwalldias96" ; }
getpcdt()   { ptime=$(ls -l pics | awk 'NR==2{print $8}')   ; rpitime=$(date +"%H:%M");
              pdate=$(ls -l pics | awk 'NR==2{print $6,$7}'); rpidate=$(date +"%b %d");
              [ "$rpidate" = "$pdate" ] && mymsg "recent picture date en rpi date are in sync" 
              mymsg "(rpi vs pictures) date time is $rpidate $rpitime vs $pdate $ptime" 
              pdiff=$(( $(timetominutes $rpitime) - $(timetominutes $ptime) ))
              [ $pdiff -gt 30 ] && monreboot   # na 30 min geen nieuwe pics, reboot in 60 seconds
}

main() { 
  mymsg "start monitor process"
  inisetup; mymsg "environmental vars setup"
  echo $(mydate) $trmurl                                   # shows redirected endlocation trackman
  echo "$(mydate) $(checkall) $chkcont"                    # initial check of trm, egf, ini sites, clk and date & time
  datetimerpitrm; trmmsg                                   # time&date ok then var timedate is true, trmmsg shows
  [ $timedate ]  &&  timedateok || monreboot               # monreboot then reboots in 60 seonds
  [ prxfeh ] && mymsg "fehxsup" || checkfeh                # if feh process not up starts feh
  [ prmain ] && mymsg "mainsup" || monreboot               # if bwalldias96 process not up then reboot in 60 seconds
  [ $(atruntime) ] && getpcdt
} 

main
