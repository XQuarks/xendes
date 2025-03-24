#!/bin/sh

# @Author: Xen Star
# @Date: 2021-09-30
# @Description: Install a distro using proot-distro

# @for termux
# @usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XQuarks/xendes/main/xinit.sh)" [cli/x11]
# @uses: proot-distro curl ping id

# supported distros
# distros="debian ubuntu fedora alpine"

# supported package managers
packages="apt dnf apk"

# set -e

# color variable
red=$(tput setaf 1) green=$(tput setaf 2)
yellow=$(tput setaf 3) blue=$(tput setaf 4)
pink=$(tput setaf 5) cyan=$(tput setaf 6)
white=$(tput setaf 7) reset=$(tput sgr0)

if [ $(id -u) -eq 0 ]; then
    echo "${red}Do not run this script as root${reset}"
    exit 1
fi

# check if internet connection is available
ping -c 1 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    printf "${red}No internet connection${reset}\n"
    exit 1
fi

read -p "Enter the type of installation [cli/x11] [x11]: " type
if [ -z "$type" ]; then
    type="x11"
fi

# verify the type of installation
case $type in
    cli)
        ;;
    x11)
        ;;
    *)
        echo "${red}Invalid type of installation${reset}"
        exit 1
        ;;
esac

# get package manager
for package in $packages; do
    if [ -x "$(command -v $package)" ]; then
        break
    fi
done

if [ -z "$package" ]; then
    echo "${red}No supported package manager found${reset}"
    exit 1
fi

echo "${yellow}Setting up storage...${reset}"
termux-setup-storage

# update packages & package installations
echo "${yellow}Installing packages...${reset}"

${package} update && ${package} upgrade -y > /dev/null 2>&1
${package} install proot-distro -y > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "${red}Failed to install the proot-distro${reset}"
    exit 1
fi

if [ -z "$(command -v proot-distro)" ]; then
    echo "${red}proot-distro not found${reset}"
    exit 1
fi

if [ $type = "x11" ]; then
    ${package} install x11-repo -y > /dev/null 2>&1
    ${package} install xorg-xrandr termux-x11-nightly pulseaudio -y > /dev/null 2>&1
fi

# end of installation
echo "${green}Installation completed${reset}"

XROOT="$PREFIX/var/lib/proot-distro/installed-rootfs"

# utility functions
reset_distro() {
    local distro=$1
    
    echo "${yellow}Resetting ${distro}...${reset}"

    read -p "Do you want to backup the distro? [y/n] [y]: " backup
    if [ $backup -ne "n" ]; then
        proot-distro backup $distro --output-file $XROOT/$distro-backup > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "${green}Backup completed${reset}: $XROOT/${distro}-backup"
        else
            echo "${red}Backup failed${reset}"
        fi
    fi

    proot-distro reset $distro > /dev/null 2>&1

    return $?
}

# create the distro
echo "${yellow}Creating the distro...${reset}"

# distro information
read -p "Enter the name of the distro [debian]: " distro
if [ -z "$distro" ]; then
    distro="debian"
fi

case $distro in
    debian)
        ;;
    ubuntu)
        ;;
    fedora)
        ;;
    alpine)
        ;;
    *)
        echo "${red}Unsupported distro${reset}"
        exit 1
        ;;
esac

read -p "Enter the new name of the distro $distro [$distro]: " XENOS
if [ -z "$XENOS" ]; then
    XENOS=$distro
fi

if [ ! -d $XROOT/$XENOS ]; then
    if [ ! -d $XROOT/$distro ]; then
        proot-distro install $distro > /dev/null 2>&1
    else
        reset_distro $distro
    fi
else
    read -p "The distro $XENOS already exists. Do you want to reset it? [y/n] [y]: " reset
    if [ $reset -ne "n" ]; then
        reset_distro $XENOS
    fi
fi

if [  $? -ne 0 ]; then
    echo "${red}Failed to create the distro${reset}"
    exit 1
else
    echo "${green}Distro has been created${reset}"

    if [ $distro != $XENOS -a -e $XROOT/$distro-backup ]; then
        read -p "Do you want to restore the backup? [y/n] [y]: " restore
        if [ $restore -ne "n" ]; then
            proot-distro restore $XROOT/$distro-backup > /dev/null 2>&1
        fi
    fi
fi

# curl -sSL https://raw.githubusercontent.com/XQuarks/xendes/main/${type}.sh

# end of distro creation
echo "${green}Distro created successfully${reset}"

# start the distro
echo "${yellow}Initializing the distro...${reset}"

proot-distro login $XENOS

if [ $? -ne 0 ]; then
    echo "${red}Failed to initialize the distro${reset}"
    exit 1
fi

echo "${green}Starting the distro${reset}"

proot-distro login $XENOS

if [ $? -ne 0 ]; then
    echo "${red}Failed to start the distro${reset}"
    exit 1
fi

sleep 2
exit