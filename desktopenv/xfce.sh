#!/bin/bash
# Get the necessary components
apt-get update
apt-get install udisks2 -y
echo " " > /var/lib/dpkg/info/udisks2.postinst
apt-mark hold udisks2
apt-get install sudo tzdata -y
apt-get install xfce4 xfce4-terminal -y
apt-get install tigervnc-standalone-server dbus-x11 -y
apt-get --fix-broken install
apt-get clean

# Setup the necessary files
mkdir -p ~/.vnc
echo "#!/bin/bash
export PULSE_SERVER=127.0.0.1
xrdb $HOME/.Xresources
startxfce4" > ~/.vnc/xstartup

echo "#!/bin/sh
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
rm -rf /run/dbus/dbus.pid
dbus-launch startxfce4" > /usr/local/bin/vncstart
   echo "vncserver -geometry 1280x720 -name remote-desktop :1" > /usr/local/bin/vnc-start
   echo "vncserver -kill :*" > /usr/local/bin/vnc-stop
   chmod +x ~/.vnc/xstartup
   chmod +x /usr/local/bin/*

   clear
   echo ""
   echo "VNC Server address will run at 127.0.0.1:5901"
   echo "Start VNC Server, run vnc-start"
   echo "Stop  VNC Server, run vnc-stop"
   echo ""
rm xfce.sh
