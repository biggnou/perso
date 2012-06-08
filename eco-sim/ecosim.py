#!/usr/bin/python
# -*- coding: utf-8 -*-

#----
# On va essayer de creer un jeu de simulation economique.
# Le vendeur (joueur) doit, dans un milieu concurentiel, s'approprier le marche.
# Jeu en tour par tour. Au debut, on fait simple : meteo decide si pluie ou soleil.
# Vendeur peut vendre limonade ou chocolat chaud. Prevision meteo pour le landemain.
# Peut vendre des produits si conserves dans un frigo, peremtpion apres deux jours.
# Acheteurs infulences par meteo, prix, qualite et publicite.
# Vendeur a une somme au depart, doit investir pour acheter des produits, un frigo plus grand, faire de la pub etc.
# Vendeur peut emprunter a la banque ou aux motards. Taux d'interets diferents mais motards peuvent venir et attention a la reputation de l'etablissement...
#----
# NOTES:
# voir en fonction des jours de semaines : samedi et dimanche, les gens sortent beau pas beau. mercredis, si pub et pas trop pire, sortent, autres jours, sortent si beau et pub, sinon faut pub ++ et ils sortent pas tous.
##
# pour les previsions, on tire la prevision et on a 1/2 chance que ca se realise (ex: si on prevoi soleil, random.randint(1,66))
#----

import random
import os
from pprint import pprint

capital = 100
invest = 0
valid_buys = {'limonade' : 2 ,'chocolat' : 2}


def Meteo():
    m = random.randint(1,100)
    #print m
    # si 1 < m < 40, soleil, si 40 < m < 65, maussade,  si 65 < m < 100, pluie.
    if m in range(1,41):
        pass
    if m in range(41,66):
        pass
    if m in range(66,101):
        pass

def PrevisionMeteo():
    pass

def Achats(capital):
    global invest
    print 'Couts unitaires :'
    #TODO: ameliorer l'affichage de pprint
    pprint(valid_buys)
    what = raw_input('Que voulez-vous acheter ?')
    if not what in valid_buys:
        pass
    howmuch = int(raw_input('Vous en voulez combien ?'))
    print 'Fin des achats pour ce tour'
    print '\n'
    invest = howmuch * 2
#    print '\n  DEBUG: in Achats(), invest = %i \n' %invest
    return invest

#def Finance(capital,invest):
def Finance(capital):
    print 'Vous avez actuellement %s $ en banque' %capital
    print 'Voici les previsions meteo pour demain :'
    PrevisionMeteo()
    print 'que voulez-vous acheter ?'
    invest = Achats(capital)
    capital = capital - invest
    print 'total invest : %i $' %invest
    print 'capital restant : %i $' %capital
    return capital,invest

def EndGame():
#    os.system('clear')
    print 'Fin du jeu'
    print 'Vous avez %s $ en banque' %capital
    exit

def main():
    tours = int(raw_input('Nombre de tours à jouer ?'))
    while tours > 0:
        print "\n"
        print "Debut d'un tour"
        capital, invest = Finance(capital=100) #capital,invest)
        Meteo()
        tours = tours - 1
        print "Fin d'un tour"
        if tours == 1:
            print 'Dernier tour de jeu'
        if tours == 0:
            EndGame()


if __name__ == '__main__':
    main()
