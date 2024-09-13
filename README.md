# ubuntu-termux

Ubuntu In Termux without proot-distro, code based from [WaHaSa](https://github.com/wahasa/Ubuntu/). Current version is unsing Ubuntu Oracular, you can change the version by editing the ubuntu to other version that available in [oci](https://partner-images.canonical.com/oci/) website.

# Installation

* Update repository lists
```
pkg update ; pkg upgrade -y
```
* Ubuntu installation
```
pkg install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/main/ubuntu.sh ; chmod +x ubuntu.sh ; ./ubuntu.sh
```
To run Ubuntu just type `ubuntu` on termux

* Ubuntu uninstallation
```
rm -rf ubuntu-fs .ubuntu $PREFIX/bin/ubuntu
```

# Desktop environment
To install desktop environment there is a lot of variety, for starter xfce is easy to navigate and lightweight.

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
