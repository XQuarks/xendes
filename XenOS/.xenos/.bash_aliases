#!/data/data/com.termux/files/usr/bin/bash

# to login xenos
alias xenos="proot-distro login xenos --shared-tmp"

# to update termux binaries
alias update="apt update && apt upgrade -y"

# to start termux x11 and xfce4
alias desktop="termux-x11 :1 -xstartup \"dbus-launch --exit-with-session xfce4-session\""
