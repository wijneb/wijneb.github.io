#!/bin/sh 
# alpiobrdpc.sh

# set variables (this scope only)
    UU=bw; PW=abc; 
    OB=home/$UU/.config/openbox
    NORDIC=https://github.com/EliverLara/Nordic.git
    G0=https://dl-cdn.alpinelinux.org/alpine/edge/testing
    G1=https://raw.githubusercontent.com/wijneb
    G2=backgrounds/main/backgrounds
    echo $G0 >> /etc/apk/repositories
    MYPIC=$G1/$G2

#obinstall
    apk update
    apk add --no-cache openbox doas feh nano pcmanfm firefox \
    xrdp xorgxrdp xorg-server xterm terminus-font mousepad sxhkd \
    dbus dbus-x11 font-dejavu font-awesome curl xfce4-terminal \
    gtk+3.0 rofi tar wmutils adwaita-icon-theme adw-gtk3 xfce4

#adduser
    adduser -D $UU
    echo "$UU:$PW" | chpasswd; adduser $UU wheel 
    echo "permit persist :wheel" > /etc/doas.conf

#getbackground
    curl -s $MYPIC/0056.jpg > /home/$UU/.paris.jpg
    curl -s $MYPIC/0040.jpg > /home/$UU/.bridge.jpg  

#obconf
    mkdir /home/$UU/.config; cp -r /etc/xdg/openbox /home/$UU/.config
    mv /$OB/menu.xml /$OB/menubu.xml; mv /$OB/rc.xml /$OB/rcbu.xml
    mv /mygithb/menubu.xml /$OB/menu.xml; mv /mygithb/rcbu.xml /$OB/rc.xml
    echo "feh --bg-scale '/home/$UU/.paris.jpg'" >> /$OB/autostart      

#sxhkd
    mkdir /home/$UU/.config/sxhkd 
    cp /mygithb/sxhkdrc /home/$UU/.config/sxhkd  

# wmutils
    mkdir /home/$UU/.local
    mkdir /home/$UU/.local/bin
    tar -xzf /mygithb/mybins.tar.gz -C /home/$UU/.local/bin
    cat <<EOF > /home/$UU/.xinitrc
    export PATH="$PATH:/home/$UU/.local/bin"
    sxhkd &
    exec openbox-session
    #exec startxfce4
EOF

# theming
    mkdir /home/$UU/.config/gtk-3.0
    echo [Settings] >> /home/$UU/.config/gtk-3.0/settings.ini
    echo gtk-theme-name=Nordic >> /home/$UU/.config/gtk-3.0/settings.ini
    mkdir /home/$UU/.themes
    git clone $NORDIC /home/$UU/.themes/Nordic
    echo view_mode=1 >> /etc/xdg/pcmanfm/default/pcmanfm.conf
    echo show_hidden=1 >> /etc/xdg/pcmanfm/default/pcmanfm.conf

#wrap_up
    chown -R $UU:$UU /home/$UU
    echo "all done"

