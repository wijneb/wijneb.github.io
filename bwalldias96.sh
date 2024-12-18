#!/bin/sh

source /home/bw/sel/funcsbwalldias.sh            # import benodigde bash functies
         
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

chkcont="c1:trm, c2:egf, c3:ini, c4:clk, c5:date"

main() { 
  inisetup
  [ $(atruntime) ] && startdiashow
# echo $(mydate) $trmurl                                 # shows redirected endlocation trackman
  clockrestart                                           # just to be sure
  echo "$(mydate) $(checkall) $chkcont"                  # initial check of trm, egf, ini sites, clk and date & time
  datetimerpitrm; trmmsg                                 # checks and shows rpi date time and trackman date time
  while true; do myruntime; done                         # main loop 
} 

main