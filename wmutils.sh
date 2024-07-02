#!/bin/sh
# wmutils

MYREPO=https://dl-cdn.alpinelinux.org/alpine/edge/testing
echo $MYREPO >> /etc/apk/repositories
apk add wmutils adwaita-icon-theme adw-gtk3 xfce
mkdir /home/bw/.local/bin
tar -xzf /mygthb/mybins.tar.gz -C /home/bw/.local/bin

cat <<EOF > .xinitrc
export PATH="$PATH:/home/bw/.local/bin"
sxhkd &
#exec openbox-session
exec startxfce4
EOF

echo "wmutils.sh done"

