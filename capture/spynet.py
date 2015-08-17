#!/usr/bin/python
# -*- coding: utf-8 -*-

##-------------------
# @author: Alex <biggnou@gmail.com>
# @purpose: sniff network and log who is doing what and when
# As seen on stackoverflow and else...
##-------------------

from optparse import OptionParser
import subprocess
import sys
import os

def tcpdump(iface, filters):
    p = subprocess.Popen(['tcpdump', '-l', '-i', iface, filters], stdout=subprocess.PIPE)
    for row in iter(p.stdout.readline, b''):
        print row.rstrip()   # process here

def main():
    check = os.getuid()
    if check != 0:  # check if user is root, since we're running tcpdump
        print('This program requires root privileges. Exiting.')
        sys.exit()

    parser = OptionParser()
    parser.add_option("-i", "--iface", dest="iface", default="eth0", help="Which interface? [default: %default]")
    parser.add_option("-f", "--filters", dest="filters", default="tcp port 80 or 443", help="Specify filter capture [default: %default]")

    (options, args) = parser.parse_args()
    
    iface = options.iface
    filters = options.filters

    tcpdump(iface, filters)


if __name__ == '__main__':
    main()

