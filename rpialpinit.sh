#!/bin/sh

apk update
apk upgrade
apk add xf86-video-fbdev nano xterm \
  font-terminus font-awesome \
  font-dejavu openbox firefox \
  pcmanfm mousepad xrandr python3 \
  xfce4-terminal feh dbus py3-pip \
  dbus-x11 lightdm-gtk-greeter geckodriver

addgroup bw input
addgroup bw video

cd /home/bw/
echo "exec openbox-session" > .xinitrc 
mkdir .config
cp -r /etc/xdg/openbox ~/.config/openbox

mkdir sel
cd sel
#python -m venv myenv
#source myenv/bin/activate
pip install selenium (--break-package)

chown -R bw:bw /home/bw

rc-update add lightdm 
rc-update add dbus 

rc-service start dbus
rc-service start lightdm


#doas nano /etc/lightdm/lightdm.conf
#autologin-user=bw
#autologin-session=openbox
#add firefox location to pyscript
#options = FirefoxOptions()
#options.add_argument("--headless")
#options.add_argument("--kiosk")  # Enables full-screen mode
#options.binary_location = r'/usr/bin/firefox'  



