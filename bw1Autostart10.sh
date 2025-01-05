#!/bin/sh

# reboot at 8 hr, then do first round (start feh):

cd /home/bw/sel
sh bw2SttAtBoot10.sh >> logs/bootlog 2>&1
sh bwfirst98.sh >> logs/mylog 2>&1
sh bwalldias98.sh >> logs/mylog 2>&1



#sh bw3CronFirst10.sh >> logs/bootlog 2>&1
#sh bw4CronDias10.sh >> logs/bootlog 2>&1