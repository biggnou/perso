#! /bin/bash
# syntax: createuser.sh [username password]

# should be root
if [[ "$UID" != 0 ]];then
    echo -e "You need root privileges to run this script. Please retry with \"sudo\".\n"
    exit 1
fi

# we are root. Do we have arguments?
if [[ "$#" != 2 ]]; then # no? ask for them
    echo -n "We need a user name. Please provide one: "
    read user
    read -s -p "Please provide a password for this user: " passwd
    echo
else # yes? let's go!
    user=$1
    passwd=$2
fi

# we are root and we have arguments we need. Let's assume we are good to go and proceed
adduser $user
echo "$user:$passwd" | chpasswd
chage -d 0 $user
