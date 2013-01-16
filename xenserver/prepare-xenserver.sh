#!/bin/sh
# @author: biggnou
# @purpose: script qui initialise les XenServers a mon gout.

## Constantes
OFFICE=`getent hosts host.example.com | cut -d' ' -f1`
VPN="192.168.0.0/16"
IPTCONF="/etc/sysconfig/iptables"

## HOWTO: on a deux arrays pour les usernames et les clefs SSH. Il faut que les clefs de ces arrays correspondent.
## Ca sera plus beau avec un script python, mais bash est sexy.
# usernames
ADMINUNAMES[0]="a"
ADMINUNAMES[1]="b"
ADMINUNAMES[2]="c"
# clefs SSH
ADMINKEYS[0]="ssh-rsa a"
ADMINKEYS[1]="ssh-rsa b"
ADMINKEYS[2]="ssh-rsa c"

## Basic check for arrays lenght
if [[ ${#ADMINUNAMES[@]} != ${#ADMINKEYS[@]} ]]; then
    echo -e "\n\tThere is a problem with admins uname/ssh-keys hashes.\n\tFix this in order to use this script.\n"
    exit 12
fi


fixall () {
    ## Fix yum: add fc6 extras
    if [ ! -f /etc/yum.repos.d/fc6extras.repo ]; then
	cat > /etc/yum.repos.d/fc6extras.repo <<EOF
[fc6-extras]
name=Fedora Core 6 Extras
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=extras-6&arch=\$basearch
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-extras
gpgcheck=0
EOF
    fi

    ## Install generic stuff
    yum --enablerepo=base install vim-enhanced emacs
    yum --enablerepo=fc6-extras install ulogd

    ## fix ulog daemon
    sed -i 's/^loglevel=.\+$/loglevel=3/g' /etc/ulogd.conf
    chkconfig ulogd on
    service ulogd start

    ## Simple but usable vimrc
    cat > /root/.vimrc <<EOF
syntax on
se ts=4
se expandtab
se shiftwidth=4
EOF

    ## Always use the pretty vi
    if [ -e /usr/bin/vim ]; then
	rm /bin/vi
	ln -s /usr/bin/vim /bin/vi
    fi

    ## Now, always use emacs because vi sucks
    cat > /usr/bin/em <<EOF
#!/bin/sh

exec emacs -nw "\$@"
EOF

    chmod 0700 /usr/bin/em

    # Good defaults for emacs ;)
    cat > /root/.emacs <<EOF
(global-font-lock-mode t)
(setq inhibit-splash-screen t)
(setq-default c-basic-offset 4)
(setq-default tab-width 8)
(show-paren-mode)
(setq indent-tabs-mode nil)
(display-time)
(setq backup-directory-alist '(("." . "~/.emacsbak")))
(setq require-final-newline t)
(menu-bar-mode -1)
(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))
(put 'upcase-region 'disabled nil)
(load-library "cmuscheme")
(setq fortune-file "/usr/share/games/fortunes")
(setq custom-file "~/.emacs-custom.el")
(load custom-file)
(column-number-mode t)
(add-hook 'java-mode-hook
      '(lambda ()
         (setq indent-tabs-mode nil)
         (setq c-basic-offset 4)))

(add-hook 'php-mode-hook
      '(lambda ()
         (setq indent-tabs-mode nil)
         (setq c-basic-offset 4)
         (setq require-final-newline t)
         (define-key c-mode-map "\C-j" 'c-indent-new-comment-line)))

(global-set-key (kbd "C-c c") 'comment-region)
(global-set-key (kbd "C-c u") 'uncomment-region)

(add-hook 'css-mode-hook
      '(lambda ()
         (setq indent-tabs-mode nil)
         (setq css-indent-offset 2)))

(add-hook 'latex-mode-hook
      '(lambda ()
         (auto-fill-mode)))

(put 'downcase-region 'disabled nil)

(defun po-wrap ()
  "Filter current po-mode buffer through \`msgcat' tool to wrap all lines."
  (interactive)
  (if (eq major-mode 'po-mode)
      (let ((tmp-file (make-temp-file "po-wrap."))
            (tmp-buf (generate-new-buffer "*temp*")))
        (unwind-protect
            (progn
              (write-region (point-min) (point-max) tmp-file nil 1)
              (if (zerop
               (call-process
                "msgcat" nil tmp-buf t (shell-quote-argument tmp-file)))
              (let ((saved (point))
                (inhibit-read-only t))
                (delete-region (point-min) (point-max))
                (insert-buffer tmp-buf)
                (goto-char (min saved (point-max))))
            (with-current-buffer tmp-buf
              (error (buffer-string)))))
          (kill-buffer tmp-buf)
          (delete-file tmp-file)))))
EOF

    cat > /root/.emacs-custom.el << EOF
(custom-set-variables
 '(c-basic-offset 4)
 '(compilation-window-height 10)
 ;; '(confirm-kill-emacs (quote y-or-n-p))
 '(custom-file "~/.emacs-custom.el")
 '(dsssl-sgml-declaration "<!DOCTYPE style-sheet PUBLIC \"-//James Clark//DTD DSSSL Style Sheet//EN\">
")
 '(kill-read-only-ok t)
 '(nil nil t)
 '(safe-local-variable-values (quote ((test-case-name . twisted\.mail\.test\.test_imap) (encoding . utf-8))))
 '(scheme-mit-dialect nil))
(custom-set-faces
 '(cursor ((t (:background "#ffffff")))))
EOF

    ## secure the webserver
    if mv /opt/xensource/www/XenCenter.msi /opt/xensource/www/XenCenter.msi.disabled ; then
	echo -e "\nMoved /opt/xensource/www/XenCenter.msi"
    fi
    if mv /opt/xensource/www/XenCenter.iso /opt/xensource/www/XenCenter.iso.disabled ; then
	echo -e "\nMoved /opt/xensource/www/XenCenter.iso"
    fi
    cat > /opt/xensource/www/Citrix-index.html <<EOF
<html>
  <title>VMWare ESXi v2.1.0-haha.com</title>
  <body>Go away.</body>
</html>
EOF

    ## Prepare /root/.ssh/authorized_keys
    cat > /root/.ssh/authorized_keys <<EOF
EOF

    ## Prepare sshd_config
    cat > /etc/ssh/sshd_config <<EOF
Protocol 2
SyslogFacility AUTHPRIV
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
GSSAPIAuthentication no
GSSAPICleanupCredentials yes
UsePAM yes
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL
X11Forwarding yes
# Subsystem   sftp    /usr/libexec/openssh/sftp-server
EOF

    # Restart sshd
    echo -e "\n\tRestarting ssh service:\n"
    service sshd restart

    ## Correct iptables
    sed -i 's/^IPTABLES_MODULES=".\+$/IPTABLES_MODULES=""/g' /etc/sysconfig/iptables-config

    cat > $IPTCONF <<EOF
# rules as per `basename $0`
# rolled on: `date`
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:RH-Firewall-1-INPUT - [0:0]
:HTTPS-FOR-XENCENTER - [0:0]
:LOGNDROP - [0:0]
-A INPUT -j RH-Firewall-1-INPUT
-A INPUT -j HTTPS-FOR-XENCENTER
-A INPUT -j LOGNDROP
-A FORWARD -j RH-Firewall-1-INPUT
# loopback is the queen
-A RH-Firewall-1-INPUT -i lo -j ACCEPT
# Established
-A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# allow ping
-A RH-Firewall-1-INPUT -p icmp --icmp-type any -j ACCEPT
# # 50 (ESP) & 51 (AH): IPSec traffic (NOT NEEDED)
# -A RH-Firewall-1-INPUT -p 50 -j ACCEPT
# -A RH-Firewall-1-INPUT -p 51 -j ACCEPT
# # Dns Multicast (NOT NEEDED)
# -A RH-Firewall-1-INPUT -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT
# # Ipp and CUPS (NOT NEDDED)
# -A RH-Firewall-1-INPUT -p udp -m udp --dport 631 -j ACCEPT
# -A RH-Firewall-1-INPUT -p tcp -m tcp --dport 631 -j ACCEPT
# # ha-cluster (NOT NEEDED yet)
# -A RH-Firewall-1-INPUT -m state --state NEW -m udp -p udp --dport 694 -j ACCEPT
# nagios ntp monitor
-A RH-Firewall-1-INPUT -m state --state NEW -m udp -p udp --dport 123 -j ACCEPT
# SSH
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
## https is needed for XenCenter
-A HTTPS-FOR-XENCENTER -m state --state NEW -m tcp -p tcp -s $OFFICE --dport 443 -j ACCEPT
-A HTTPS-FOR-XENCENTER -m state --state NEW -m tcp -p tcp -s $VPN --dport 443 -j ACCEPT
# Log and Drop
-A LOGNDROP -p tcp -j ULOG --ulog-prefix "Denied TCP: "
-A LOGNDROP -p udp -j ULOG --ulog-prefix "Denied UDP: "
-A LOGNDROP -p icmp -j ULOG --ulog-prefix "Denied ICMP: "
-A LOGNDROP -j DROP
COMMIT
EOF

    echo -e "\n\tRestarting iptables:\n"
    service iptables restart
    service iptables status

}

manageusers () {
    ## prepare individual users
    for (( i=0; i<=$((${#ADMINUNAMES[@]}-1)); i++ )); do # iterate through all available unames
	grep ${ADMINUNAMES[$i]} /etc/passwd 1>/dev/null
	if [[ $? == 0 ]]; then # the user already exists, only update the SSH key
	    echo -e "\n\t${ADMINUNAMES[$i]} already exists; skipping user creation but updating SSH key:"
	    echo ${ADMINKEYS[$i]} > /home/${ADMINUNAMES[$i]}/.ssh/authorized_keys
            [ $? -eq 0 ] && echo -e "\t\tSSH public key updated for ${ADMINUNAMES[$i]}!\n" || echo -e "\n\tFAILED to update ${ADMINUNAMES[$i]} authorized_keys!\n"
	else # user do not exists, create it, set a default password and plug the SSH key
	    echo -e "\n\tUser ${ADMINUNAMES[$i]} not found; creating it right away;"
	    pass=$(perl -e 'print crypt($ARGV[0], "password")' defaultsecretpassword)
	    useradd -m -p $pass ${ADMINUNAMES[$i]}
	    [ $? -eq 0 ] && echo -e "\t\tUser ${ADMINUNAMES[$i]} has been added to system!" || echo -e "\n\tFAILED to add a user ${ADMINUNAMES[$i]}!\n"
	    mkdir /home/${ADMINUNAMES[$i]}/.ssh
	    echo ${ADMINKEYS[$i]} > /home/${ADMINUNAMES[$i]}/.ssh/authorized_keys
	    chown -R ${ADMINUNAMES[$i]}: /home/${ADMINUNAMES[$i]}/.ssh
	    [ $? -eq 0 ] && echo -e "\t\tSSH public key implanted for user ${ADMINUNAMES[$i]}!\n" || echo -e "\n\tFAILED to create ${ADMINUNAMES[$i]} authorized_keys!\n"
	fi
    done

    ## preparer sudoer file
    # create ADMINS group
    grep -E '^MYADMINS ALL=' /etc/sudoers 1>/dev/null
    if [ $? -eq 0 ]; then
	echo -e "\n\tSudoers file already prepared!"
    else
	echo -e "\nMYADMINS ALL=NOPASSWD: /bin/su\n" >> /etc/sudoers
	[ $? -eq 0 ] && echo -e "\n\tFile /etc/sudoers updated!" || echo -e "\n\tA PROBLEM OCCURED while updating /etc/sudoers!!!"
    fi
    # create the first sudoer
    echo -e "User_Alias MYADMINS = ${ADMINUNAMES[0]}, \c" > /tmp/admins
    # then populate with all users but the last one
    for (( i=1; i<=$((${#ADMINUNAMES[@]}-2)); i++ )); do
	echo -e "${ADMINUNAMES[$i]}, \c" >> /tmp/admins
	echo $admins
    done
    # add the last one without comma
    echo -e "${ADMINUNAMES[${#ADMINUNAMES[@]}-1]}" >> /tmp/admins
    # remove the old line
    sed -i 's/^User_Alias MYADMINS =.\+//' /etc/sudoers
    # create temporary new file
    cat /etc/sudoers /tmp/admins > /tmp/sudoers
    # move the new file at the right place, chmod it and remove temporary file
    mv /tmp/sudoers /etc/sudoers
    chmod 0440 /etc/sudoers
    rm /tmp/admins

}

manageon () {
    echo -e "\nMode manage ON (opening port 443)\n"
    iptables -D INPUT -j HTTPS-FOR-XENCENTER 2> /dev/null
    iptables -I INPUT -j HTTPS-FOR-XENCENTER
    service iptables status
}

manageoff () {
    echo -e "\nMode manage OFF (closing port 443)\n"
    iptables -D INPUT -j HTTPS-FOR-XENCENTER
    service iptables status
}

usage () {
    cat <<EOF

USAGE:

$(basename $0) [options]

Options:

  -f, --fixall   : Fixes the XenServer pristine install to fit our needs.
                   Should be run only once after install and after each upgrade.
                   This will OPEN the HTTPS access, run -O to close it.

  -u, --users    : Fixes admin users and/or updates SSH keys

  -o, --on       : Turns HTTPS on (needed for XenCenter access)
  -O, --off      : Turns HTTPS off

  -h, --help     : This help message

EOF
}

## Argument parsing.
if [ "$#" -eq 0 ]; then   # Script needs at least one command-line argument.
    echo -e "\nWe need at least one argument.\n"
    usage
    exit 1
fi

## options may be followed by one colon to indicate they have a required argument
OPTS=`getopt -o fhoOu -l fixall,help,on,off,users -- "$@"`

if [ $? != 0 ]; then
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
	-f|--fixall)
	    fixall
	    shift
	    ;;
	-o|--on)
	    manageon
	    shift
	    ;;
	-O|--off)
	    manageoff
	    shift
	    ;;
	-u|--users)
	    manageusers
	    shift
	    ;;
        -h|--help)
            usage
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
