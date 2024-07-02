#!/bin/sh 
# alpiobrdpc.sh

# set variables (this scope only)
    UU=bw; PW=abc; 
    OB=home/$UU/.config/openbox
    G1=https://raw.githubusercontent.com/wijneb
    G2=backgrounds/main/backgrounds
    MYPIC=$G1/$G2

#obinstall
    apk update
    apk add --no-cache openbox doas feh nano pcmanfm firefox \
    xrdp xorgxrdp xorg-server xterm terminus-font mousepad sxhkd \
    dbus dbus-x11 font-dejavu font-awesome curl xfce4-terminal

#adduser
    adduser -D $UU
    echo "$UU:$PW" | chpasswd; adduser $UU wheel 
    echo "permit persist :wheel" > /etc/doas.conf
    echo 'exec openbox-session' >> /home/$UU/.xinitrc

#getbackground
    curl -s $MYPIC/0056.jpg > /home/$UU/.paris.jpg
    curl -s $MYPIC/0040.jpg > /home/$UU/.bridge.jpg
    echo "feh --bg-scale '/home/$UU/.paris.jpg'" >> /$OB/autostart    

#obconf
    mkdir /home/$UU/.config; cp -r /etc/xdg/openbox /home/$UU/.config
    mv /$OB/menu.xml /$OB/menubu.xml; mv /$OB/rc.xml /$OB/rcbu.xml
    mv /mygithb/menubu.xml /$OB/menu.xml; mv /mygithb/rcbu.xml /$OB/rc.xml

#sxhkd
    mkdir /home/$UU/.config/sxhkd 
    cp /mygithb/sxhkdrc /home/$UU/.config/sxhkd  
    echo "sxhkd &" >> /$OB/autostart

#wrap_up
    chown -R $UU:$UU /home/$UU

