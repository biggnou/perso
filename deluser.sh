#! /bin/bash
# Script pour tuer des usagers qui sont actuellements logués sur le système
# Version 0.8
# Auteur : Alex
# Description : ce script sers à trouver tous les processus d'un tuilisateur et à les killer.

clear
who
echo
echo "quel usager doit sortir du système ?"
read a

# Puis on tue l'usager passé en argument. Si l'usager n'est pas connecté, on aura un message d'erreur.

if ps -o %p -U "$a" --no-header 2>/dev/null
 then kill -9 `ps -o %p -U "$a" --no-header` 
 else echo "Oups... il semble que $a n'est pas connecté"
fi
