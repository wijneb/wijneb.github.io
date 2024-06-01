#!/bin/sh
myfeh="feh --bg-scale '.background.jpg' "
mygit="https://raw.githubusercontent.com/wijneb"
menu=$mygit"/wijneb.github.io/main/menubu.xml"
myrc=$mygit"/wijneb.github.io/main/rcbu.xml"
mypic=$mygit"/backgrounds/main/backgrounds/0040.jpg"
# curl -s xxx : is silent mode, no terminal comments
curl -s $menu > .config/openbox/menu.xml
curl -s $myrc > .config/openbox/rc.xml
curl -s $mypic > .background.jpg
echo $myfeh >> .config/openbox/autostart
openbox --reconfigure
feh --bg-scale '/home/bw/.background.jpg' 
# ADD https://raw.githubusercontent.com/wijneb/wijneb.github.io/main/.initob.sh /home/$RDP_USER/
# sh /home/bw/.initob.sh
