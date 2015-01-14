#!/bin/bash
# Note: the script will *purposely* then go to the
# back up folder if run from the home directory.

set -e # errors yeah

BACKUP="$HOME/.home_backup"
THIS_USER=`logname`
DATA="/data/$THIS_USER"


if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "This script is going to remove many files in your home."
read -p "Are you sure you want to run it? [y,n] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo # for newline
echo "Backupping home config files..."
if [ ! -d "$BACKUP" ]; then
    mkdir -v $BACKUP
else
    rm -rf $BACKUP
    mkdir -v $BACKUP
fi
mv -v $HOME/* $BACKUP

echo "Creating data dirs"
sudo mkdir -v $DATA
sudo chown -Rv $THIS_USER:$THIS_USER $DATA

mkdir $DATA/Desktop \
    $DATA/Documents \
    $DATA/Downloads \
    $DATA/Git \
    $DATA/Music \
    $DATA/Pictures \
    $DATA/ROS

echo "Linking folders"
ln -sv $DATA/Desktop $HOME/Desktop
ln -sv $DATA/Documents $HOME/Documents
ln -sv $DATA/Downloads $HOME/Downloads
ln -sv $DATA/Git $HOME/Git
ln -sv $DATA/Music $HOME/Music
ln -sv $DATA/Pictures $HOME/Pictures
ln -sv $DATA/ROS $HOME/ROS

echo "Done!"
exit 0
