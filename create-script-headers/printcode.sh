#! /bin/bash
# Entête de script générée automatiquement par nsh !
# Sur une idée de l'ami du petit déjeuné... euh... non en fait, c'est une idée de Thierry.
# Auteur : Alex (biggnou@gmail.com)
# Titre: printcode.sh
# Description : Script qui liste les scripts du répertoire et concatǹe tout les codes en un seul fichier texte.
# Date de création : mer jan 28 12:24:30 EST 2009
# Modification:   2009-02-12 10:53:28
# Modification:   2009-02-12 10:53:28

# On demande dans quel répertoire se situent les scripts à concaténer (ce terme est correct, sinon on peut dire cater)

clear
echo -e "Dans quel répertoire se situent vos scripts ? \n(donnez un chemin ABSOLU)" ; read rep
while [ ! -d $rep ]
 do echo "Ce chemin ne correspond à aucun répertoire sur ce système; veuillez donner un CHEMIN ABSOLU de répertoire EXISTANT." ; read rep
done

#on crée un nom pour le répertoire choisi pour le cas ou le nom d'archivage sera auto

echo "$rep" > /tmp/printcodereptmp
repforname=`sed 's/\//~/g' /tmp/printcodereptmp`

# On demande le nom du fichier de sortie souhaité

echo -e "Quel nom de fichier souhaitez-vous donner ? \n(répondez \"auto\" si vous souhaitez un nom automatique)" ; read nom
if [ $nom = auto ]
 then nom=scripts_${repforname}_`date +%m-%d-%y`
fi

# On enlève les foutus documents temporaires créés par Gedit, l'éditeur de la misère, rien ne vaut vi, vi for ever !

rm -f $rep/*~

# On crée le fichier texte final en passant par un temporaire.

cd $rep

liste=`ls`

echo -e "Table des matières :\n" > $nom
echo -e "$liste\n" >> $nom
echo -e "--->~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<---\n" >> $nom
for i in $liste
 do echo -e "$i\n" >> $nom
    cat $i >> $nom
    echo >> $nom
    echo -e "--->~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<---\n" >> $nom
  done
cd $OLDPWD
rm -rf /tmp/printcodereptmp
