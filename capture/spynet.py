#!/usr/bin/python
# -*- coding: utf-8 -*-

##-------------------
# @author: Alex <biggnou@gmail.com>
# @purpose: sniff network and log who is doing what and when
# As seen on stackoverflow and else...
##-------------------

import subprocess
import sys
import os

def main():
    check = os.getuid()
    if check != 0:
        print('This program requires root privileges. Exiting.')
        sys.exit()
    
    p = subprocess.Popen(('tcpdump', '-l'), stdout=subprocess.PIPE)
    for row in iter(p.stdout.readline, b''):
        print row.rstrip()   # process here



if __name__ == '__main__':
    main()

