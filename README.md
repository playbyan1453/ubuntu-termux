# ubuntu-termux

Ubuntu In Termux without proot-distro, code based from [wahasa](https://github.com/wahasa/Ubuntu/)

# Installation

* Update repository lists
```
pkg update -y
```
* Ubuntu installation
```
pkg install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/dev/ubuntu.sh ; chmod +x ubuntu.sh ; ./ubuntu.sh
```
To run Ubuntu just type `ubuntu` on termux

# Desktop environment
To install desktop environment there is a lot of variety, for starter xfce is easy to navigate and lightweight.

`Xfce Desktop Environment`
```
apt install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/dev/desktopenv/xfce.sh ; chmod +x xfce.sh ; ./xfce.sh
```

`LXQt Desktop Environment`
```
apt install wget -y ; wget https://raw.githubusercontent.com/playbyan1453/ubuntu-termux/dev/desktopenv/lxqt.sh ; chmod +x lxqt.sh ; ./lxqt.sh
```
