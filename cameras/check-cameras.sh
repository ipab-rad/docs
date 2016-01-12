#!/bin/bash

# Requires fping 
#   (sudo apt-get install fping)

if [ $(dpkg-query -W -f='${Status}' fping 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "The script requires the package 'fping'. To install it: "
    echo "sudo apt-get install fping"
    exit
fi

set -u

starting=100

counter=$starting
while [ $counter -le 163 ]
do
    camera="inspacecam$counter.inf.ed.ac.uk"
    echo -n "Testing $camera..."
    fping -c 1 -t300 $camera > /dev/null 2>&1;
    if [ $? -eq 0 ]; then
        echo -e "\e[32mSUCCESSFUL\e[0m"
    else
	echo -e "\e[1m\e[31mFAILED!\e[0m"
    fi
    ((counter++))
done
