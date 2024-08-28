#!/bin/sh
mygit="https://raw.githubusercontent.com/wijneb"
menu=$mygit"/wijneb.github.io/main/menubu.xml"
myrc=$mygit"/wijneb.github.io/main/rcbu.xml"
mypic=$mygit"/backgrounds/main/backgrounds/0040.jpg"
# curl -s xxx : is silent mode, no terminal comments
curl -s $menu > .config/openbox/menu.xml
curl -s $myrc > .config/openbox/rc.xml
curl -s $mypic > /home/.background.jpg
chown bw:bw /home/.background.jpg
openbox --reconfigure
feh --bg-scale '/home/.background.jpg' 
# ADD https://raw.githubusercontent.com/wijneb/wijneb.github.io/main/.initob.sh /home/$RDP_USER/
# sh /home/bw/.initob.sh

README:  rpiallfases6.tar.gz  
mkdir /home/bw/sel; cd /home/bw/sel
mygit="https://raw.githubusercontent.com/wijneb/wijneb.github.io/main/rpialpfases6.tar.gz"
wget -qO- "$mygit" | tar xz -C ./ 
of:    wget $mygit/rpialpfases6.tar.gz
       tar -xzvf rpialpfases6.tar.gz 
(as root) sh alpfase123.sh met reboots tussendoor
(as root) nano crontab -e   
0  8 * * * /sbin/reboot  
0 22 * * * /usr/local/bin/dpmsoff  
in autostart 
cd /home/bw/sel
bwalldias.sh >> mylog &
