#!/bin/sh

cd /home/bw/sel
loc=/home/bw/sel
lg1=/home/bw/sel/monlog
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

source /home/bw/sel/bwalldiasfun3.sh            # import benodigde sh functies
source /home/bw/sel/venv/bin/activate           # activeer python virt env

chkcont="c1:trm, c2:egf, c3:ini, c4:clk, c5:date"

msgsunset(){ snstmsg="sunset: "$sunsethr; }

boottimemsg(){ [ $(date +%-H) -eq 8 ] && [ $(date +%-M) -lt 5 ] && 
               echo -n "$(mydate) $chkcont $snstmsg" ; } # initial msg after 08 hr boot only

newline1(){ [ $(date +%-M) -eq 0 ] && echo -en "\n$(mydate)" ; }
newline() { [ $(tail -n 1 $loc/mylog | wc -w) -gt 9 ] && echo -en "\n$(mydate) " >> $loc/mylog; }
 
main() { 
  inisetup               # set environment vars
  checksunset            # what is the sunset time
  msgsunset              # only after reboot show sunset time
  boottimemsg            # msg shown only after boot
  newline                # start at newline at the hour or after 9 entries on a line
  checkall               # check trm/egf/ini/clock/date&time c1c2c3c4c5
  readinifle             # try and read old or new inifile
  alldias                # try and take snapshots from trm and egf sites
  } 

$(atruntime) && main     # main only runs at runtime (between 8 and 22 hrs)


# alldias is: 1.GetsData 2.SequencesData 3.CallsPythonscriptPerPicData
# checkreboot(){ [ $(date +%-H) -eq 8 ] && [ $(date +%-M) -eq 0 ] && myreboot ; }
# atruntime()  { [ $(date +%-H) -ge 8 ] && [ $(date +%-H) -lt 22 ] && echo true || echo false; }
# noruntime()  { [ $(date +%-H) -eq 22 ] || [ $(date +%-M) -eq 0 ] && echo true || echo false; }
 