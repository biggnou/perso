#!/bin/bash

chromeid='choupette'
myuri='example.com'

chrome-on () {
    chromium-browser --app="${myuri}" 1>/dev/null & echo $! > /tmp/chromeid
}

chrome-off () {
    echo OFF
    kill -12 `cat /tmp/chromeid`
}

####
## Argument parsing.
if [ "$#" -eq 0 ]; then
    echo -e "\n\tNope.\n"
    exit 1
fi

OPTS=`getopt -o o,k,u: -l on,off,url: -- "$@"`

if [ $? != 0 ]; then
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
	-o|--on)
	    chrome-on $myuri
	    shift
	    ;;
	-k|--off)
	    chrome-off
	    shift
	    ;;
	-u|-uri)
	    myuri=$2
	    shift 2
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
