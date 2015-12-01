#!/bin/bash

set -e
set -u

. install/common.sh

BACKUP="$HOME/.home_backup"
DOTF="$(pwd)"

if [[ $UID != 0 ]]; then
    print_rd "Please run this script with sudo:\n"
    print_rd "sudo $0 $*\n"
    exit 1
fi

print_yl "This script is going to remove many files in your home.\n"
print_yl "Are you sure you want to run it? [Y,n]"
read -p " " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo # for newline
    exit 1
fi

echo # for newline

print_bl "~~~~~~~~~~~~~~~~ Installing dependencies ~~~~~~~~~~~~~~~~\n"

. ./install/install_dependencies.sh
install_dependencies

print_gr "~~~~~~~~~~~~~ Everything has been installed ~~~~~~~~~~~~~\n"
