#!/data/data/com.termux/files/usr/bin/bash

# Define color palette
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Reset color

echo -e "${CYAN}Installing required packages...${NC}"
pkg install root-repo x11-repo
pkg install proot pulseaudio -y
termux-setup-storage
clear

echo -e "${CYAN}Fetching available codenames...${NC}"
available_codenames=$(curl -s https://partner-images.canonical.com/oci/ | grep -oP '(?<=href=")[^/]+/(?=")' | grep -v 'Parent' | sort | sed 's/\/$//')
clear

echo -e "${GREEN}Available versions from ${CYAN}https://partner-images.canonical.com/oci/:${NC}"
printf "${YELLOW}- ${NC}%s\n" $available_codenames

read -n 1 -s -r -p "Press any key to continue..."$'\n'

while true; do
    read -p "$(echo -e "${GREEN}Ubuntu codename: ${NC}")" ubuntu
    # Check if the entered codename is in the list
    if echo "$available_codenames" | grep -Fx "$ubuntu" > /dev/null; then
        while true; do
            read -p "$(echo -e "${YELLOW}Are you sure you want to install '$ubuntu'? (y/n): ${NC}")" confirm
            case "$confirm" in
                [Yy]*)
                    echo -e "${GREEN}Proceeding with installation of '$ubuntu'...${NC}"
                    break 2
                    ;;
                [Nn]*|"")
                    echo -e "${CYAN}Please select a different codename.${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}Invalid input${NC}. Please enter 'y' or 'n'."
                    ;;
            esac
        done
    else
        echo -e "${RED}'$ubuntu' not found in available codenames${NC}. Please try again."
    fi
done

folder="ubuntu-fs"
if [ -d "$folder" ]; then
    first=1
    echo -e "${YELLOW}Skipping downloading!${NC}"
fi
tarball="ubuntu-rootfs.tar.gz"
if [ "$first" != 1 ]; then
    if [ ! -f "$tarball" ]; then
        echo -e "${CYAN}Downloading Rootfs${NC}, this may take a while based on your internet speed."
        case "$(dpkg --print-architecture)" in
            aarch64)
                archurl="arm64" ;;
            arm*)
                archurl="armhf" ;;
            ppc64el)
                archurl="ppc64el" ;;
            x86_64)
                archurl="amd64" ;;
            *)
                echo -e "${RED}Unknown architecture!${NC}"
                exit 1 ;;
        esac
        # Ensure $ubuntu is set
        if [ -z "$ubuntu" ]; then
            echo -e "${RED}Ubuntu codename not specified.${NC}"
            exit 1
        fi
        wget -O "$tarball" "https://partner-images.canonical.com/oci/${ubuntu}/current/ubuntu-${ubuntu}-oci-${archurl}-root.tar.gz" || {
            echo -e "${RED}Download failed, exiting...${NC}"
            exit 1
        }
    fi
    cur=$(pwd)
    mkdir -p "$folder"
    cd "$folder" || exit 1
    echo -e "${CYAN}Decompressing Rootfs, please be patient...${NC}"
    proot --link2symlink tar -xf "${cur}/${tarball}" || {
        echo -e "${RED}Failed to decompress${NC} $tarball."
        exit 1
    }
    cd "$cur" || exit 1
fi

echo "ubuntu" > "$cur/$folder/etc/hostname"
echo "127.0.0.1 localhost" > "$cur/$folder/etc/hosts"
echo "nameserver 8.8.8.8" > "$cur/$folder/etc/resolv.conf"

mkdir -p $folder/binds
bin=.ubuntu
linux=ubuntu
echo -e "${CYAN}Writing launch script${NC}"
cat > $bin <<- EOM
#!/bin/bash
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
cd \$(dirname \$0)
## Unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $folder/binds)" ]; then
    for f in $folder/binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /dev/null:/proc/sys/kernel/cap_last_cap"
command+=" -b /proc"
command+=" -b \$TMPDIR:/tmp"
command+=" -b $folder/root:/dev/shm"
## Uncomment the following line to have access to the home directory of termux
# command+=" -b \$HOME:/root"
## Uncomment the following line to mount /sdcard directly to /
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

# Fixing shebang of $linux"
termux-fix-shebang $bin
# Making $linux executable"
chmod +x $bin
# Removing image for some space"
rm $tarball

echo "export PULSE_SERVER=127.0.0.1" >> $folder/etc/skel/.bashrc
echo '#!/bin/bash
bash .ubuntu' > $PREFIX/bin/$linux
chmod +x $PREFIX/bin/$linux
clear
    echo -e "${CYAN}Setting up Ubuntu...${NC}"
echo "#!/bin/bash
touch ~/.hushlogin
apt update && apt upgrade -y
apt install apt-utils dialog nano -y
cp /etc/skel/.bashrc .
rm -rf ~/.bash_profile
exit" > $folder/root/.bash_profile
bash $linux
    clear
    echo -e "${NC}You can now start Ubuntu with 'ubuntu' script next time"
rm ubuntu.sh
