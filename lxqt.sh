#!/bin/bash
#Get the necessary components
apt-get update
apt-get install udisks2 -y
echo " " > /var/lib/dpkg/info/udisks2.postinst
apt-mark hold udisks2
apt-get install sudo -y ; dpkg-reconfigure tzdata
apt-get install lxqt qterminal -y
apt-get install tigervnc-standalone-server dbus-x11 -y
apt-get --fix-broken install
apt-get clean

#Setup the necessary files
mkdir -p ~/.vnc
echo "#!/bin/bash
export PULSE_SERVER=127.0.0.1
xrdb $HOME/.Xresources
startlxqt" > ~/.vnc/xstartup

echo "#!/bin/sh
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
rm -rf /run/dbus/dbus.pid
dbus-launch startlxqt" > /usr/local/bin/vncstart
   echo "vncserver -geometry 1600x900 -name remote-desktop :1" > /usr/local/bin/vncstart
   echo "vncserver -kill :*" > /usr/local/bin/vncstop
   chmod +x ~/.vnc/xstartup
   chmod +x /usr/local/bin/*
sleep 2
clear
echo "Please enter your vnc password"
vncstart
sleep 1
vncstop rt
sleep 5
vncstop
