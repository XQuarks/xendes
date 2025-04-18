#!/bin/sh

# @Author: Xen Star
# @Date: 2021-09-30
# @Description: Prepare a distro for future use for cli usage

# @usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XQuarks/xendes/main/cli.sh)"
# @Uses: curl git useradd

# Type: Cli
# Description: Cli
# Version: 1.0

# supported os
# os="debian ubuntu fedora alpine"
os="debian"

# supported package managers
packages="apt dnf apk"

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

if [ ! -x "$(command -v $package)" ]; then
    echo "${red}No supported package manager found${reset}"
    exit 1
fi

# show available details
echo "${cyan}Details:${reset}"
echo "  ${cyan}OS:${reset} $os"
echo "  ${cyan}Package Manager:${reset} $package"
echo "  ${cyan}User:${reset} $(whoami)"

case $os in
    debian)
        ;;
    ubuntu)
        ;;
    fedora)
        ;;
    alpine)
        ;;
    *)
        echo "${red}Unsupported OS${reset}"
        exit 1
        ;;
esac

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

# install packages
${package} install sudo curl zsh git gh make build-essential neovim -y > /dev/null

sleep 2
exit