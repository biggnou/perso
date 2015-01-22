#! /bin/bash
# @author: biggnou@gmail.com
# @purpose: wraper for du so the output is like xkcd http://www.explainxkcd.com/wiki/images/3/32/pixels-du.png
# when invoked with -s and -h, should replace G and above with "a lot"...
# any other du should work as normal

echo $* | grep -o s >/dev/null; rcs=$?
if [ $rcs == 0 ]; then # we have -s
    echo $* | grep -o h >/dev/null; rch=$?
    if [ $rch == 0 ]; then # we have -h
	du $@ | sed -e "s/^\([0-9]\+\(.\+\)\?G\)/A lot/"
	exit 0
    fi
fi

du $*
