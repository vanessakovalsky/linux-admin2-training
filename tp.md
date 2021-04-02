# Travaux pratiques

Objectif : réaliser un script qui va  permettre d'exécuter la mise en place d'un serveur prêt à être utiliser. 

L'installation du serveur se fait au travers du vagrantFile qui contient différent disques. 
Il s'agit d'une Debian Buster avec 3 disques : 1 de 20Go qui contient la partition racine, et deux disques de 5GO chacun qui ne contiennent rien.

## Script d'installation du serveur

Au sein de script sh, les actions suivantes devront être effectuées  : 
* Créer une partition de type ext4 sur chaque disque vide (donc les disques 2 et 3 de 5 Go chacun).
* Installer la version stable de Jenkins et ses prérequis en suivant la documentation officielle : https://www.jenkins.io/doc/book/installing/linux
* Démarrer le service Jenkins 
* Créer un utilisateur ```userjob```
* Lui donner les permissions (via le fichier sudoers) d'utiliser ```apt``` (et seulement apt pas l'ensemble des droits admin)
* Afficher à la fin de l'execution du script le contenu du fichier /var/jenkins_home/secrets/initialAdminPassword pour permettre de récupérer le mot de passe 

## BONUS - Création du paquet
* Une fois le script crée et fonctionnel, créer un paquet DEB  contenant le script 

## Test
* Créer un nouveau dossier
* Copier le VagrantFile
* (Copier le paquet deb généré ) ou (si vous n'avez pas fait le paquet) lancer le script
* Lancer la VM avec ```vagrant up```
* Installer le paquet
* (Executer la commande pour installer le serveur) ou (si vous n'avez pas fait le paquet)
* Vérifier que le service Jenkins est bien démarré
* Vérifier en vous connectant avec le compte ```userjob``` que vous pouvez bien accéder à la commande apt
* Déposer sur Teams dans les fichiers du canal général, dans le dossier Linux puis le sous Dossier TP, votre script ou votre paquet qui devra être nommé : nomduscript_nom_prenom.sh ou nomdupaquet_nom_prenom.deb
