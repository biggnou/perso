#! /bin/bash
# Entête de script générée automatiquement par nsh !
# Description : Ceci est un script pour trouver les descriptions dans les entêtes des scripts créés avec nsh.
# Date de création : lun jan 26 16:13:31 EST 2009
# Modification:   2009-02-12 10:57:17
 
if grep -m1 Description $1
 then echo $REPLY
 else echo "Pas de ligne \"# Description\" dans votre script..."
fi
