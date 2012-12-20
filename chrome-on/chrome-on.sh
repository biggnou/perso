#!/bin/bash

chromeid='choupette'
myuri='example.com'

chrome-on () {
    chromium-browser --login-profile="test" --app=${1} &>/dev/null & echo $! > /tmp/chromeid
#    firefox -new-window ${1} & echo $! > /tmp/firefoxid
}

chrome-off () {
    echo OFF
    cat /tmp/chromeid
#    kill -12 `cat /tmp/chromeid`
}

####
## Argument parsing.
if [ "$#" -eq 0 ]; then
    echo -e "\n\tNope.\n"
    exit 1
fi

OPTS=`getopt -o o:,k -l on:,off -- "$@"`

if [ $? != 0 ]; then
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
	-o|--on)
	    chrome-on $2
	    shift 2
	    ;;
	-k|--off)
	    chromeid=`cat /tmp/chromeid`
	    echo $chromeid
#	    chrome-off $chromeid
	    rm /tmp/chromeid
	    shift
	    ;;
	\?)
	    echo "Invalid option: $OPTARG"
	        ;;
	:)
	    echo "Option $OPTARG requires an argument."
	        ;;
        --) shift; break;;
    esac
done
