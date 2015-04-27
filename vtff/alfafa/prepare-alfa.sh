#!/bin/bash

if [ $# = 0 ]; then
    iface='wlan1'
    echo -e "\nNo iface given, setting to default ${iface}\n"
else
    iface=$1
fi

echo Set BO
iw reg set BO
echo Mac power
iwconfig $iface txpower 25
echo MAC changer
macchanger -A $iface
echo Done.
