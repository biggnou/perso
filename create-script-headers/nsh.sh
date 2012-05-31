#! /bin/bash
# Idée reprise et (grandement :D ) améliorée de Thierry (merci ti'biscuit)
# Auteur : Alex (biggnou@gmail.com) et  Thierry (blackhole1002@yahoo.fr)
# Description : Ce script sert à créer des entêtes de scripts standardisées.
# Modification :  2010-03-20 13:50:01.583819699 -0400
# TODO: more error handlers and checks on user's entries. Never trust user's input, never.

#code couleur : 2=grisfoncé;30=noir;31=rouge;32=vert;33=orangemerdeux;34=bleu;35=mauve;36=turkoise;37=gris
#code inverse-vidéo : 7=noirsurblanc; code couleur +10=inverse-vidéo
#code spécial : 1=gras;4=souligés;9=barré

# fonction affichage : mettre de la couleur dans notre shell !
affichage() { echo -e "\033[$1m$2\033[0m\n";}

# script interractif ! (yes I'm bad, I know... bite me!)
# on force l'utilisateur a ne pas donner d'argument :
if [ $# -ne 0 ] ; then
    echo -e "\nUsage : $0\n\nNe donnez pas d'argument svp.\n"
    exit 1
fi

# on demande le nom du script à créer
clear
if [ $# -eq 0 ]
    then
    echo -en "\nDonnez un nom pour votre script : " ; read a
    nom=$a
fi

# on demande le shebang parmis les shells et langages plus haut niveau disponibles sur le système
echo -e "Choisissez un shell d'exécution ou un langage parmis ces possibilités :\n"
echo '- Langages compilés :'
if [ -e /usr/bin/perl ] ; then
    echo /usr/bin/perl
fi
if [ -e /usr/bin/python ] ; then
    echo /usr/bin/python
fi
echo '- Shells disponibles :'
cat /etc/shells | grep -v '^#'
echo
echo -n "--> " ; read b
shebang="#! $b"

# en fonction du langage choisi, on va creer le nom du script :
if [ $b == "/usr/bin/perl" ] ; then
    nom="${nom}.pl"
elif [ $b == "/usr/bin/python" ] ; then
    nom="${nom}.py"
else
    nom="${nom}.sh"
fi

# test sur l'existance de ce nom de fichier : si existe, ecraser ou sortir.
if [ -e $nom ] ; then
    affichage 31 '\n\tCe fichier existe déjà !\n'
    echo
    ls -lh $nom
    echo
    head $nom
    echo
    echo -en "Voulez-vous VRAIMENT écraser le fichier existant ?  (vous predrez toute donnée non-sauvegardée)\n\n\tO / N :" ; read q
    if [ $q != "y" ] && [ $q != "o" ] && [ $q != "Y" ] && [ $q != "O" ] ; then
        echo -e "\nQuitting without saving\n"
        exit 1
    fi
fi

# On demande une description pour le script
echo "Donnez une description pour votre script :" ; read description

# on crée le script, on lui donne une entête, on le rend exécutable et on l'ouvre avec emacs parceque vim c'est bien mais emacs c'est mieux :
echo "$shebang" > $nom
echo >> $nom
echo "# Entête de script générée automatiquement par nsh !" >> $nom
echo "# Remember: TIMTOWTDO but KISS"
echo "# Auteur : Alex (biggnou@gmail.com)" >> $nom
echo "# Titre : $nom" >> $nom
echo "# Description : $description" >> $nom
echo "# Date de création : `date`" >> $nom
echo "# Modification : `stat ${nom} | grep Modify | cut -c9-27`" >> $nom

if [ $b != "/usr/bin/perl" ] && [ $b != "/usr/bin/python" ] ; then
    echo -e "\n\n#code couleur : 2=grisfoncé;30=noir;31=rouge;32=vert;33=orangemerdeux;34=bleu;35=mauve;36=turkoise;37=gris\n"
    echo -e "#code inverse-vidéo : 7=noirsurblanc;+10=inverse-vidéo\n"
    echo -e "#code spécial : 1=gras;4=souligés;9=barré\n" >> $nom
    echo '# fonction affichage : bash en couleur !' >> $nom
    echo 'affichage() { echo -e "\033[$1m$2\033[0m\n";}' >> $nom
fi

chmod 0700 $nom
clear
emacs --no-window $nom
