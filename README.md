# ubuntu-termux

The script automates proot installation process and provides more flexibility, the code based from [WaHaSa](https://github.com/wahasa/Ubuntu/). Follow the instruction that the script provides.

# Installation

* Update repository lists
```
pkg update
```
* Ubuntu installation
```
curl -o ubuntu.sh https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/ubuntu.sh ; chmod +x ubuntu.sh ; ./ubuntu.sh
```
After following and sucessfully installed ubuntu, you can run ubuntu by typing `ubuntu` on termux.

* Ubuntu uninstallation
```
rm -rf ubuntu-fs .ubuntu $PREFIX/bin/ubuntu
```

# Desktop environment
To install desktop environment you need to run this inside proot, for starter xfce is easy to navigate and lightweight.

`Xfce Desktop Environment`
```
apt install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/desktopenv/xfce.sh ; chmod +x xfce.sh ; ./xfce.sh
```

`LXQt Desktop Environment`
```
apt install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/desktopenv/lxqt.sh ; chmod +x lxqt.sh ; ./lxqt.sh
```

# Installing browser
Currently in ubuntu repo there browser but it may using snap which has some issues currently.

`Firefox`
```
wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/apps/firefox-esr.sh ; chmod +x firefox-esr.sh ; ./firefox-esr.sh
```

`Chromium`
```
wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/apps/chromium.sh ; chmod +x chromium.sh ; ./chromium.sh
```

# Hardware Acceleration
This section is still under investigation.
