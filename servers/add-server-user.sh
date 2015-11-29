#!/bin/bash

## REQUIREMENTS
#
# 1. You need an ssh key generated on your lab machine
# 2. You need every servers to have your ssh key on
#    To do this, generate the ssh key with ssh-keygen and copy it:
#        $ ssh-keygen -t rsa -b 4096 -C "your_email_address"
#        $ ssh-copy-id rad_admin@cezanne.inf.ed.ac.uk
#    Repeat the last command for all the servers
# The password for rad_admin can be found in the wiki
#
###############

SERVERS="cezanne.inf.ed.ac.uk
goya.inf.ed.ac.uk
degas.inf.ed.ac.uk
dali.inf.ed.ac.uk"


user2servers ()
{

    for s in $SERVERS
    do
        ssh rad_admin@$s -tt << EOF
sudo adduser --disabled-password --gecos "" $1
sudo adduser $1 sudo
sudo adduser $1 adm
sudo adduser $1 lpadmin
sudo adduser $1 sambashare
echo "$1:pass" | sudo chpasswd
exit
EOF
    done
}

get_new_username()
{
    read username
    echo "$username" # returns username
}

## MAIN ()

printf "New admin username: "
new_user=$(get_new_username)
echo ""

user2servers $servers_passwd $new_user

exit 0
