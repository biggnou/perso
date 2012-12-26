#!/bin/sh

OFFICE=`getent hosts host.example.com | cut -d' ' -f1`
VPN="192.168.0.0/16"
IPTCONF="/etc/sysconfig/iptables"

fixall () {
    ## Fix yum: add fc6 extras
    if [ ! -f /etc/yum.repos.d/fc6extras.repo ]; then
	cat > /etc/yum.repos.d/fc6extras.repo <<EOF
# [fc6-extras]
name=Fedora Core 6 Extras
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=extras-6&arch=$basearch
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
autoindent
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
;; (setq-default tab-width 4)
;; (setq make-backup-files nil)
(setq indent-tabs-mode nil)
(display-time)
;;(mouse-wheel-mode t)
(setq backup-directory-alist '(("." . "~/.emacsbak")))
(setq require-final-newline t)
(menu-bar-mode -1)
;;(tool-bar-mode -1)
(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))
;;(setq c-default-style '(("c++-mode" . "gnu") (other . "gnu")))
;;(setq write-region-inhibit-fsync t)
(put 'upcase-region 'disabled nil)
(load-library "cmuscheme")
(setq fortune-file "/usr/share/games/fortunes")
(setq custom-file "~/.emacs-custom.el")
(load custom-file)
(column-number-mode t)
;; (setq semantic-load-turn-everything-on t)
;; (load-library "semantic-load")
;; (global-semantic-idle-completions-mode)
;; (setq semanticdb-project-roots
;;          (list "/home/joe/prog/proj3d/src"))
;; (setq semanticdb-default-save-directory "~/.semantic-cache")
;; (semantic-load-enable-code-helpers)
;; (add-hook 'c-mode-hook
;;    '(lambda ()
;;       (define-key c-mode-map "." 'semantic-complete-self-insert)))
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
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
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
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 ;; '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 160 :width normal :family "xos4-terminus"))))
 '(cursor ((t (:background "#ffffff")))))
EOF

    ## secure the webserver
    if [ mv /opt/xensource/www/XenCenter.msi /opt/xensource/www/XenCenter.msi.disabled ]; then
	echo -e "\nMoved /opt/xensource/www/XenCenter.msi"
    fi
    if [ mv /opt/xensource/www/XenCenter.iso /opt/xensource/www/XenCenter.iso.disabled ]; then
	echo -e "\nMoved /opt/xensource/www/XenCenter.iso"
    fi
    cat > /opt/xensource/www/Citrix-index.html <<EOF
<html>
  <title>XenServer 2.1.0-haha.com</title>
  <body>Go away.</body>
</html>
EOF

    ## Prepare /root/.ssh/authorized_keys
    cat > /root/.ssh/authorized_keys <<EOF
# Paste your keys here
EOF

    ## Prepare sshd_config
    cat > /etc/ssh/sshd_config <<EOF
Protocol 2
SyslogFacility AUTHPRIV
PermitRootLogin without-password
PasswordAuthentication no
ChallengeResponseAuthentication no
GSSAPIAuthentication no
GSSAPICleanupCredentials yes
UsePAM yes
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES 
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT 
AcceptEnv LC_IDENTIFICATION LC_ALL
X11Forwarding yes
Subsystem   sftp    /usr/libexec/openssh/sftp-server
EOF

    # Restart sshd
    echo -e "\n\tRestarting ssh service:\n"
    service sshd restart

    ## Correct iptables
    sed -i 's/^IPTABLES_MODULES=".\+$/IPTABLES_MODULES=""/g' /etc/sysconfig/iptables-config

    cat > /etc/sysconfig/iptables <<EOF
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

}

iptablesrestart () {
    echo -e "\n\tRestarting iptables:\n"
    service iptables restart
    service iptables status
}

manageon () {
    echo -e "\nMode manage ON (opening port 443)\n"
    sed -i '/INPUT -j HTTPS/ s/^# //' $IPTCONF
}

manageoff () {
    echo -e "\nMode manage OFF (closing port 443)\n"
    sed -i '/INPUT -j HTTPS/ s/^/# /' $IPTCONF
}

usage () {
    cat <<EOF
USAGE:

$(basename $0) [options]

Options:

  -f, --fixall   : fixes the XenServer pristine install to fit our needs.
                   Should be run only once after install and after each upgrade.

  -o, --on       : turns on HTTPS (needed for XenCenter access)
  -O, --off      : turns off HTTPS

  -h, --help     : this help message

EOF
}

## Argument parsing.
if [ "$#" -eq 0 ]; then   # Script needs at least one command-line argument.
    echo -e "\nWe need at least one argument.\n"
    usage
    exit 1
fi

## options may be followed by one colon to indicate they have a required argument
OPTS=`getopt -o fhoO -l fixall,help,on,off -- "$@"`

if [ $? != 0 ]; then
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
	-f|--fixall)
	    fixall
	    iptablesrestart
	    shift
	    ;;
	-o|--on)
	    manageon
	    iptablesrestart
	    shift
	    ;;
	-O|--off)
	    manageoff
	    iptablesrestart
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
