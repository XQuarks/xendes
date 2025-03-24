#!/bin/bash

alias myip="curl ip-api.com"

# to update xenos binaries
alias update="apt update && apt upgrade -y"

# to start termux x11 and xfce4
alias desktop="termux-x11 :1 -xstartup \"dbus-launch --exit-with-session xfce4-session\""
