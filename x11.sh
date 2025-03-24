#!/bin/sh

# @author: Xen Star
# @date: 2021-09-30
# @description: Prepare a distro for future use for desktop usage

# @usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XQuarks/xendes/main/x11.sh)"
# @uses: curl git useradd

# Type: X11
# Description: X11
# Version: 1.0

# supported os
# os="debian ubuntu fedora alpine"
os="debian"

# supported package managers
packages="apt dnf apk"

# set -e

# color variable
red=$(tput setaf 1) green=$(tput setaf 2)
yellow=$(tput setaf 3) blue=$(tput setaf 4)
pink=$(tput setaf 5) cyan=$(tput setaf 6)
white=$(tput setaf 7) reset=$(tput sgr0)

if [ $(id -u) -ne 0 ]; then
    echo "${red}Run this script as root${reset}"
    exit 1
fi

# get the os
if [ ! -f /etc/os-release ]; then
    . /etc/os-release
    os=$ID

    if [ $ID_LIKE ]; then
        os=$ID_LIKE
    fi
fi

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

# update packages
echo "Updating packages..."

${package} update && ${package} upgrade -y > /dev/null

# add user
read -p "Do you want add a new user? (y/n) [n]: " add_user
if [ $add_user = "y" ]; then
    read -p "Enter username: " username
    useradd -m -s /bin/zsh $username

    if [ $? -eq 0 ]; then
        echo "Default password is the same as the username [$username]."

        echo "$username:$username" | chpasswd
        echo "$username  ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/$username
    else
        echo "Failed to add user $username."
    fi
fi

# # install packages
# ${package} install sudo dbus-x11 xwayland xfce4 xfce4-terminal pulseaudio curl zsh git gh make build-essential neovim -y > /dev/null

# # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# if [ $add_user = "y" ]; then
#     su - $username -c "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
# fi

sleep 2
exit