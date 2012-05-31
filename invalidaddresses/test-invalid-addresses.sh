#! /bin/bash

echo -e "\n\tDomaine a tester ?"
read DOMAINE
echo -e "\n\tTransport du domaine ?"
read TRANSPORT
echo -e "\n\tPort de livraison ?"
read PORT
echo

( echo HELO zerospam.ca
sleep 2
echo "MAIL FROM: <noc@zerospam.ca>"
sleep 2
echo -e "RCPT TO: <eiubrhibgeygub8347g28bf@$DOMAINE>"
sleep 5
echo QUIT
sleep 2
echo exit ) | tee /dev/tty | telnet "$TRANSPORT" "$PORT"

