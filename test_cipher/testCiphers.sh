#!/usr/bin/env bash

# OpenSSL requires the port number.
if [[ "$#" == "0" ]]; then
    SERVER=docs.bmc.com:443
elif [[ "$#" == "1" ]]; then
    SERVER=$1
else
    echo Nope.
    exit 1
fi

DELAY=1
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

echo Obtaining cipher list from $(openssl version).
echo Testing $SERVER :

for cipher in ${ciphers[@]}; do
    echo -n Testing $cipher...
    result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
    if [[ "$result" =~ ":error:" ]] ; then
        error=$(echo -n $result | cut -d':' -f6)
        echo NO \($error\)
    elif [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
        echo YES
    else
        echo UNKNOWN RESPONSE
        echo $result
    fi
    sleep $DELAY
done
