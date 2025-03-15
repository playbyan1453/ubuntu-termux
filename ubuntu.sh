#!/data/data/com.termux/files/usr/bin/bash

pkg install root-repo x11-repo
pkg install proot pulseaudio -y
termux-setup-storage

echo "Fetching available codenames..."
available_codenames=$(curl -s https://partner-images.canonical.com/oci/ | grep -oP '(?<=href=")[^/]+/(?=")' | grep -v 'Parent' | sort | sed 's/\/$//')
clear

echo "Available versions from https://partner-images.canonical.com/oci/:"
echo "$available_codenames" | sed 's/^/- /'

read -n 1 -s -r -p "Press any key to continue"

while true; do
    read -p "Ubuntu codename: " ubuntu
    # Check if the entered codename is in the list
    if echo "$available_codenames" | grep -Fx "$ubuntu" > /dev/null; then
        while true; do
            read -p "$(echo -e "Are you sure you want to install '$ubuntu'? [y/N]: ")" confirm
            case "$confirm" in
                [Yy]*)
                    echo -e "Confirmed. Proceeding with installation of '$ubuntu'..."
                    break 2
                    ;;
                [Nn]*|"")
                    echo -e "Installation cancelled. Please select a different codename."
                    break
                    ;;
                *)
                    echo -e "Invalid input. Please enter 'y' or 'n'."
                    ;;
            esac
        done
    else
        echo "'$ubuntu' not found in available codenames. Please try again."
    fi
done

folder="ubuntu-fs"
if [ -d "$folder" ]; then
    first=1
    echo "Skipping downloading"
fi
tarball="ubuntu-rootfs.tar.gz"
if [ "$first" != 1 ]; then
    if [ ! -f "$tarball" ]; then
        echo "Downloading Rootfs, this may take a while based on your internet speed."
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
                echo "Unknown architecture!"
                exit 1 ;;
        esac
        # Ensure $ubuntu is set
        if [ -z "$ubuntu" ]; then
            echo "Ubuntu codename not specified."
            exit 1
        fi
        curl -o "$tarball" "https://partner-images.canonical.com/oci/${ubuntu}/current/ubuntu-${ubuntu}-oci-${archurl}-root.tar.gz" || {
            echo "Download failed, exiting..."
            exit 1
        }
    fi
    cur=$(pwd)
    mkdir -p "$folder"
    cd "$folder" || exit 1
    echo "Decompressing Rootfs, please be patient..."
    proot --link2symlink tar -xf "${cur}/${tarball}" || {
        echo "Failed to decompress $tarball."
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
echo "Writing launch script"
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
    echo ""
    echo "Setting up Ubuntu..."
    echo ""
echo "#!/bin/bash
touch ~/.hushlogin
apt update && apt upgrade -y
apt install apt-utils dialog nano -y
cp /etc/skel/.bashrc .
rm -rf ~/.bash_profile
exit" > $folder/root/.bash_profile
bash $linux
    clear
    echo ""
    echo "You can now start Ubuntu with 'ubuntu' script next time"
    echo ""
rm ubuntu.sh
