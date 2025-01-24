#!/bin/sh

apk update
apk upgrade
apk add nano xterm \
  font-terminus font-awesome \
  font-dejavu openbox firefox curl \
  pcmanfm mousepad xrandr python3 \
  xfce4-terminal feh dbus py3-pip \
  dbus-x11 lightdm-gtk-greeter \
  geckodriver xf86-video-fbdev \
  xdotool

addgroup bw input
addgroup bw video

cd /home/bw/
echo "exec openbox-session" > /home/bw/.xinitrc 
mkdir .config
cp -r /etc/xdg/openbox /home/bw/.config/openbox
chown -R bw:bw /home/bw

mkdir sel
cd sel
su bw

python3 -m venv /home/bw/sel/venv
source /home/bw/sel/venv/bin/activate
pip install selenium #  --break-system-packages 

doas rc-update add lightdm 
doas rc-update add dbus 

doas rc-service dbus start 
doas rc-service lightdm start 

#/etc/doas.d/doas.conf 
#=> permit nopass root cmd /sbin/reboot
#=> permit nopass bw cmd /sbin/reboot
#=> permit nopass <user> cmd "/sbin/rc-service chronyd restart"
#in fun3.sh grep -i ^date
#in fun3 HT HI en HE ipv 3x HI
#toch venv, zonder werkt niet in cron
#doas nano /etc/lightdm/lightdm.conf
#autologin-user=bw
#autologin-session=openbox
#add firefox location to pyscript
#options = FirefoxOptions()
#options.add_argument("--headless")
#options.add_argument("--kiosk")  # Enables full-screen mode
#options.binary_location = r'/usr/bin/firefox'  



