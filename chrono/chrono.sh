#! /bin/bash

# Entête de script générée automatiquement par nsh !
# Auteur : Alex (biggnou@gmail.com)
# Titre : chrono.sh
# Description : Chronomètre pour Travian
# Date de création : jeu fév 12 10:25:29 EST 2009
# Modification:   2009-02-12 10:53:28

#code couleur : 1=blancgras;2=grisfoncé;30=noir;31=rouge;32=vert;33=orangemerdeux;34=bleu;35=mauve;36=turkoise;37=gris
#code inverse-vidéo : 7=noirsurblanc;+10=inverse-vidéo
#code spécial : 1=gras;4=souligés;9=barré

affichage() { echo -e "\033[$1m$2\033[0m\n";}

if [ "$#" -ne 2 ];then
	clear
	echo -e "\n\n\t`affichage 41 'Vous devez spécifier deux argmuents :'`\n\n\t\tun timeout\n\t\tun message\n";read t; read "m";set "$t" "$m"
fi
(sleep "$1"; xmessage -buttons "M'en branle","OK Merci" -center " $2 ") &
