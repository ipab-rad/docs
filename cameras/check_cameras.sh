#!/bin/bash

# Requires fping 
#   (sudo apt-get install fping)

set -u

starting=100

counter=$starting
while [ $counter -le 165 ]
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