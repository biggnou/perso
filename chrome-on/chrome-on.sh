#!/bin/bash

chromeid='choupette'
myuri='https://nagios.zerospam.ca/nagios2'

chrome-on () {
    echo ON
    chromium-browser --app="${myrui}"
    echo $! > /tmp/chromeid
}

chrome-off () {
    echo OFF
    kill -12 `cat /tmp/chromeid`
}

OPTS=`getopt -o o,k -l on,off -- "$@"`

if [ $? != 0 ]; then
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
	-o|--on)
	    chrome-on
	    shift
	    ;;
	-k|--off)
	    chrome-off
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
