# Exercice 1 - Administration professionnelle

Cet exercice a pour objectifs : 
* D'automatiser l'exploitation
* D'utiliser les commande expect et m4
* De journaliser avec script et logger et de communiquer avec motd et wall
* De tracer mes modifications d'un fichiers de configuration avec RCS
* D'écrire une page de manuel
* D'utiliser la commande sudo
* De découvrir les commande diff et patch

## Automatiser l'exploitation

* Créer un script qui envoi un mail à l'adminitrateur quand un des disque est plein (rempli à plus de 90%)
```sh
#!/bin/sh
# disk_full - teste si les disques sont plein
SEUIL=80
message=/tmp/bidon

df -P | grep -v '^Filesystem' | sed 's/%//' |
while read fs total used avail capacity mount
    do
        if [ "$capacity" -gt $SEUIL ];then
            printf "%-20s %5d%%\n" $mount $capacity >> $message
        fi
done
if [ -r $message ];then
    if [ -x "mail -v" ];then
        mail -s "LES DISQUES SONT PLEINS" root < $message
    else 
        apt install mailutils
        echo 'Mail a été installé'
        mail -s "LES DISQUES SONT PLEINS" root < $message

        rm -f $message
    fi
fi
```
* Tester le script manuellement
* Automatiser l'execution du script avec crontab, celui-ci doit tourner tous les jours deux fois par jour


## Utiliser les commande expect et m4

* Installer expect
* Créer un script qui vérifie si en se connectant en ssh sur un serveur, on récupère bien "$ " en retour (avec la commande expect)
```sh
#!/usr/bin/expect -f
set timeout 3
spawn ssh -l guest localhost
match_max 100000
expect -nocase "password: "
send -- "wwii1945\n"
expect "$ "
send -- "date > /tmp/date.log\r"
sleep 1
send -- "exit\r"
expect eof
```
* Créer un script source.m4 avec une macro qui inclue un fichier date.txt : 
```sh
dnl Ceci est un commentaire
dnl =======================
define(VER,`3.14')dnl
define(`fct1',`bonjour Mr $1')dnl
include(`date.txt')dnl
Version: VER
fct1(Dupont)
Goodbye
```
* Créer le fichier date.txt : 
```sh
date
```
* Executer le script source.m4 avec la commande m4


## Journaliser avec script et logger et de communiquer avec motd et wall

* Enregistrer les action suivantes avec la commande script : 
* * date
* * id 
* * uname -a
* * uptime
* Afficher le script et lancer le .

* Ajouter le fichier des actions administrateur au syslog : echo "local1.*
/var/log/journal_de_bord.log" >> /etc/rsyslog.conf
* Redemarrer le service rsyslog
* Ajouter un message de type info avec logger
* Ajouter un message de type warning avec logger
* Afficher le journal des actions administrateur

* Prévenir les utilisateur en utilisant le fichier motd (se connecter avec un autre compte pour voir le fihier s'afficher)
* Prévenir immédiatement les utilisateurs avec la commande wall  


## Tracer mes modifications d'un fichiers de configuration avec RCS

* Créer un répertoire RCS 
* Commencer l'historisation du fichier cupsd.conf (avec l'option -l pour conservé le fichier original)
* Modifier le fichier de configuration de cups pour permettre l'accès au port 631 depuis l'exterieur 
* Enregistrer les modifications et archiver la dernière version
* Relancer le service cups et vérifier avec netstat si votre modification a bien été prise en compte 
* Visualiser les commentires RCS
* Visualiser l'historique des modifications

## Ecrire une page de manuel

* Ecrire un script qui appelle la commande news avec le contenu suivant :
```sh
#!/bin/sh
# news
option=$1
if [ -e ~/.news_time ];then
FILES=`find /var/news -type f -newer ~/.news_time `
if [ "$FILES" != "" ];then
more $FILES
fi
fi
if [ ! -e ~/.news_time -o N$option = "N-a" ];then
more /var/news/*
fi
touch ~/.news_time
```
* Créer un dossier : /usr/local/man/man1
* Créer un fichier news.1 dans ce dossier qui décrit votre page de manuel, exemple :
```
.Dd August 1, 2006
.Dt NEWS 1
.Sh NAME
news \- print news items
.Sh SYNOPSIS
news [-a]
.Sh DESCRIPTION
news is used to keep the user informed of current events. By convention, these
events are described by files in the directory /var/news.
.Pp
When invoked without arguments, news prints the contents of all current files in
/var/news. news stores the ``currency'' time as the modification date of a file
named .news_time in the user's home directory; only files more recent than this
currency time are considered ``current.''
.Sh OPTIONS
-a
Print all items, regardless of currency.
.Sh FILES
.nf
/var/news/*
$HOME/.news_time
```
* Tester la page avec la commande groff : groff -Tascii -man /usr/local/man/man1/news.1
* Compresser la page en gzip
* Vérifier que la commande man trouve la page news
* Ajouter à l'index du manuel la nouvelle page :
```
makewhatis /usr/local/man
man -k news
```
* Visualiser le texte source d'une page de man : zcat /usr/share/man/man8/init.8.gz | more
* Tester la commande news

## Utiliser la commande sudo

* Créer un compte utilisateur : jean et lui définir un mot de passe
* A l'aide du fichier sudoers donner le droit à jean de créer des comptes
* Se connecter sur le compte de jean
* Créer un utilisateur
* Sortir du compte de jean
* Modifier la configuration du sudoers :
* * créer un alias de commande permettant d'accéder aux commandes suivantes : useradd, userdel, usermod, groupadd, passwd
* * Donner accès l'alias de commande que l'on vient de créer au groupe admins
* Créer un groupe admins
* Ajouter l'utilisateur mina au groupe admins (après l'avoir créé)
* Se connecter avec l'utilisateur mina et voir si l'on peut utiliser les commandes de l'alias


## Découvrir les commande diff et patch
On part du principe que la partie sur RCS a été faite
* Enregistrer la différence entre cupsd.conf et cupsd.conf.default dans le fichier patch.txt à l'aide de la commande diff
* Afficher les première ligne du fichier patch.txt
* Installer patch (si nécessaire)
* Copier le fichier cupsd.conf.default en cupsd.conf.001 
* Appliquer le fichier patch.txt sur le fichier cupsd.conf.001 avec la commande patch
* Afficher les différences entre les fichiers cupsd.conf et cupsd.conf.001 avec la commande diff .