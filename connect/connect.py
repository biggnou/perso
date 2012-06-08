#!/usr/bin/python
# -*- coding: utf-8 -*-

##-------------------
#
# @author: Alex <biggnou@gmail.com>
# @purpose: simple drop-in replacement to network manager for home wifi.
#
##-------------------

import sys
import os
from optparse import OptionParser

def ifaceup(iface):
    cmd = "/usr/sbin/wpa_supplicant -B -Dwext -i %(interface)s -c %(confile)s" % {"interface" : iface, "confile" : '/root/.linuxonly.conf'}
    os.system(cmd)

def ifacedown(iface):
    os.system('killall wpa_supplicant')
    os.system('killall dhcpcd')
    os.system('/etc/rc.d/ntpd stop')
    cmd = "ip link set %s down" % (iface)
    os.system(cmd)

def dropboxup():
    os.system('/etc/rc.d/dropboxd start')

def dropboxdown():
    os.system('/etc/rc.d/dropboxd stop')

def ifacedhcp(iface):
    cmd = "/usr/sbin/dhcpcd %s" % (iface)
    os.system(cmd)

def sysntp():
    os.system('/etc/rc.d/ntpd start')

def sysmount():
    print('mounting samoasan')
    os.system('mount -o user=alex -t cifs //samoasan/video /mnt/samoasan')

def sysumount():
    os.system('umount /mnt/samoasan')

def macchanger(iface):
    cmd = "macchanger -A %s" % (iface)
    os.system(cmd)

def main():
    check = os.getuid()
    if check != 0:
        print('This program requires root privileges. Go fuck out, player.')
        sys.exit()

    parser = OptionParser(version="%prog 0.8-b")
    parser.add_option("-i", "--iface", dest="iface", default="wlan0", help="Which interface? [default: %default]")
    parser.add_option("-a", "--all", action="store_true", default=False,  help="Do everything: up, dhcp and ntp")
    parser.add_option("-u", "--up", action="store_true", default=False, help="Bring iface up")
    parser.add_option("-d", "--down", action="store_true", default=False, help="Bring iface down")
    parser.add_option("--dhcp", action="store_true", default=False, help="Do dhcp request (using dhcpcd)")
    parser.add_option("-n", "--ntp", action="store_true", default=False , help="Start ntp deamon")
    parser.add_option("-m", "--mount", action="store_true", default=False , help="Mount SamoaSan")
    parser.add_option("--umount", action="store_true", default=False , help="Umount SamoaSan")
    parser.add_option("-k", "--killall", action="store_true", default=False , help="Umount, release dhcp lease and bring iface down.")
    parser.add_option("--mac", action="store_true", default=False, help="Change the MAC address of iface. Works only if iface is down.")
    parser.add_option("--dropboxup", action="store_true", default=False, help="Launch Drop Box daemon (user: alex).")
    parser.add_option("--dropboxdown", action="store_true", default=False, help="Kill Drop Box Daemon (user: alex).")

    (options, args) = parser.parse_args()
    
    iface = options.iface

    if options.iface and len(args) != 0:
        parser.error('Woot?!??')

    #if len(options) == 0:
    #    parser.error("Gimme a flag, please, don't be rude!")

    #if options.killall and len(options) != 1:
    #    parser.error("--killall is exclusive, ya can't ask what ya asked. RMFM!")

    if options.all:
        ifaceup(iface)
        ifacedhcp(iface)
        sysntp()
        os.system('cowsay -b "Job done"')

    if options.up:
        ifaceup(iface)

    if options.down:
        ifacedown(iface)

    if options.dhcp:
        ifacedhcp(iface)
    
    if options.ntp:
        sysntp()

    if options.mount:
        sysmount()
        os.system('cowsay -p "Mooovies"')

    if options.umount:
        sysumount()
        os.system('cowsay -p "Mooovies"')

    if options.killall:
        sysumount()
        ifacedown(iface)
        os.system('cowthink -t "Time to sleep"')

    if options.mac:
        macchanger(iface)
        os.system('cowthink -w "Cheater..."')

    if options.dropboxup:
        dropboxup()

    if options.dropboxdown:
        dropboxdown()



if __name__ == '__main__':
    main()
