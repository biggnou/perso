#!/bin/bash
# Titre:   miseajour
# Auteur:   thierry (blackhole1002@yahoo.fr)
# Création:   lundi 26 janvier 2009, 19:34:06 (UTC-0500)
# Modification:   2009-02-12 10:53:28
# Description:   Met à jour le temps de modification dans l'en-tête de chaque script du répertoire
# Synopsis:   miseajour

# On enlève les fichiers temporaire du répertoire
rm -f *~

# Création de la liste des fichiers
liste=`ls`

for i in $liste
do
   verify=`head -1 $i |tr -d " "`
   if [ "$verify" = "#!/bin/bash" ]; then
   sed -i "/^# Modification/ c\# Modification:   $(stat $i|grep Modify|cut -c9-27)" $i

#ls -l $i |tr -s " " " " |cut -d" " -f6-7 |cut -c1-19)" $i

fi
done
