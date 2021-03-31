# Exercice 2 - Installation

Cet exercice a pour objectifs : 
* De créer un serveur d'installation PXE
* De réaliser une installation KickStart
* De créer un paquet RPM
* De créer un serveur de dépôt 

## Créer un serveur d'installation PXE

* Installer le paquet dhcp 
* Editer le fichier /etc/dhcp/dhcp.conf (après l'avoir copié pour sauvegarder l'original) et mettre la confguration suivante :
```
ddns-update-style none;
log-facility local7;
subnet 192.168.0.0 netmask 255.255.255.0 {
default-lease-time -1;
option routers 192.168.0.200;
option domain-name "pinguins";
next-server 192.168.0.200;
option domain-name-servers 192.168.0.200;
filename "pxelinux.0";
}
host linux01 {
hardware ethernet 00:01:00:00:00:01;
fixed-address 192.168.0.1;
}
```
* Démarrer le service dhcpd et vérifier sa présence (port 67)
* Installer tftp et tftp-server et activer le service
* Tester :
```
# echo "Server TFTP" > /var/lib/tftpboot/welcome.txt
# echo "get welcome.txt" | tftp 192.168.0.200
tftp> get welcome.txt
tftp>
# cat welcome.txt
Server TFTP
```
* Installer syslinux
* Copier le chargeur dans le répertoire de données du serveur TFTP: 
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot
* 
@TODO

## Réaliser une installation KickStart
@TODO

## Créer un paquet RPM

* Installer les outils de développements
```
yum -y -q groupinstall 'Development tools'
```
* Créer le répertoire racine du logiciel et se positionner à l'intérieur : 
```
mkdir nbmister-1.0
cd nbmister-1.0
```
* Créer le fichier source (nbmister.c) avec le contenu suivant : 
```
/* nbmiser.c */
# include <stdio.h>
# include <string.h>
int random_number();
main() {
int misterious_number = random_number();
int a_try, i;
char a_string[256];
for(i=1;;i++) {
printf("What is the misterious number (between 1 and 100) ? ");
fgets( a_string, 255, stdin);
a_try = atoi( a_string);
printf("===>Try number:%d, Try:%d\n", i, a_try);
if ( a_try == misterious_number ) break;
if ( a_try < misterious_number ) puts("=== too small ===");
if ( a_try > misterious_number ) puts("=== too high ===");
}
printf("YOUPI!!!!\n");
}
# vi bib.c
/* bib.c */
# include <stdlib.h>
# include <time.h>
int random_number() {
srandom( time(0) );
return random() % 100 + 1;
}
# vi Makefile
nbmister: nbmister.o bib.o
cc -o nbmister nbmister.o bib.o
install: nbmister
install -m 755 nbmister /usr/local/bin
clean:
rm -f *.o
```
* Tester le fonctionnement 
```
make install
nbmister
make clean
rm -rf nbmister /usr/local/bin/nbmister
```
* Créer l'archive 
```
cd
tar czf nbmister-1.0.tar.gz nbmister-1.0/
```
* Créer le fichier nbmister.spec qui décrit le paquet et est obligatoire pour créer un paquet. Son contenu peut être trouvé dans corrige/nbmister.spec 
* Créer le RPM avec les commande suivantes : 
```
mkdir -p rpmbuild/SOURCES
cp nbmister-1.0.tar.gz rpmbuild/SOURCES/
rpmbuild -ba nbmister-1.0-1.spec > err 2>&1
```
* Installer le logiciel a partir du paquet créé : 
```
rpm -Uvh rpmbuild/RPMS/i686/nbmister-1.0-1.i686.rpm
```
* Le desinstaller :
```
rpm -e nbmister
```
* Reconstruire le paquet binaire à partir des sources : 
```
rm –f rpmbuild/RPMS/i686/nbmister-*
rpmbuild --rebuild rpmbuild/SRPMS/nbmister-1.0-1.src.rpm
```
* Vous savez maintenant créer un paquet pour les systèmes de la famille Red Hat

## Créer un paquet DEB

* Création d'un fichier myecho qui contient le script suivant : 
```
#!/bin/bash
    
    if [ ! -f ~/.myecho_content ]; then
        echo "HELLO WORLD">~/.myecho_content
    fi
    
    cat ~/.myecho_content
```
* Nous allons ensuite créé l'arborescence nécessaire à la création de notre paquet (respecter la casse sur les nom de dossier et de fichier):
```
/home/<vous>/
    ->myecho/
    --->DEBIAN/
    ----->control (fichier décrivant les informations relatives à notre paquet)
    ----->postinst (script exécuté après l'installation du paquet)
    ----->postrm (script exécuté après la désinstallation du paquet)
    --->usr/
    ----->bin/
    ------->myecho (notre script, exposé ci-dessus)
    ----->share/
    ------->doc/
    --------->README (informations relatives à l'utilisation de myecho)
    --------->copyright 
    --------->changelog (changements apportés par rapport à la dernière version)
    --------->changelog.Debian (idem, mais seulement pour le paquet Debian)
```
* Le fichier control est obligatoire et permet de décrire notre paquet, voici un exemple de contenu : 
```
Package: myecho
    Version: 1.0
    Section: base
    Priority: optional
    Architecture: all
    Depends: bash
    Maintainer: Mr X <MrX@fun.com>
    Description: Echoes the content of /home/<you>/.myecho_content
```
* Il est possible de demander à depkg d'éxécuter des commandes à la suite de l'installation avec le fichier postinst. Exemple
```
    #!/bin/bash
    touch ~/.myecho_content
    echo "HELLO WORLD" > ~/.myecho_content
```
* Il est également possible de faire des actions à la suite de la désinstallation 
```
#!/bin/bash
    
    rm ~/.myecho_content
```
* Les autres fichiers sont à votre convenance. 
* Pour créer le paquet utiliser dpkg-deb comme suit :
```
cd ~             # on se place dans notre répertoire racine utilisateur (non root)
dpkg-deb --build myecho # à exécuter en root
```


## Créer un serveur de dépôt Red Hat
* Nous allons créer un dépôt de paquet Red Hat accessible en HTTP.
* Commencer par installer et démarrer Apache : 
```
yum –q –y install httpd
service httpd start
```
* Puis créer un dossier et copier le rpm crée à l'étape précédente dans ce dossier : 
```
mkdir /var/www/html/MAISON
cp rpmbuild/RPMS/i686/nbmister-*.rpm /var/www/html/MAISON/
```
* Il est nécessaire de créer des métadonnées pour le dépôts. Utiliser la commande createrepo (à installer):
```
yum -y -q install createrepo
cd /var/www/html/MAISON/
createrepo .
```
* Le dépôt est maintenant prêt à être utilisé.
* Ajouter le au fichier de configuration des dépôts :
```
vi /etc/yum.conf
...
[maison]
name=RHEL 6 - maison
baseurl=http://localhost/MAISON
```
* Installer le paquet nbmister depuis le dépôt crée et configuré : 
```
yum clean all
yum list | grep nbmister
yum -y -q install nbmister
```
* Il est également possible de créer un groupe de paquet : 
* * Créer un fichier XML qui décrit les composants du groupe : 
```
vi comps.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
<comps>
    <group>
        <id>Maison</id>
        <name>Logiciels maison</name>
        <description>Logiciels ecrits pour le FUN</description>
        <default>false</default>
        <uservisible>true</uservisible>
        <packagelist>
            <packagereq type='default'>nbmister</packagereq>
            <packagereq type='default'>nbmister-debuginfo</packagereq>
        </packagelist>
    </group>
    <grouphierarchy>
    </grouphierarchy>
</comps>
```
* * Mettre à jour les métadonnés 
```
createrepo -g comps.xml
```
* Lister les groupes disponibles, obtenir des infos sur le groupe créé et l'installer
```
yum clean all
yum grouplist |grep -i maison
yum groupinfo 'Logiciels Maison'
yum -y -q groupinstall 'Logiciels Maison'
rpm –q nbmister-debuginfo
```

-> Vous savez maintenant créer des paquets et des dépôts pour les mettre à disposition

## Créer un serveur de dépôt Debian
* On va créer un dépôt accessible en SSH 
* Créer un utilisateur :
```
adduser myrepo
```
* Puis générer une clé GPG pour l'utilisateur créé (suivre l'assistant en laissant les options par défaut pour la génération de la clé)
```
su - myrepo
gpg --gen-key
```
* Créer deux répertoire conf et incoming dans le home de l'utilisateur 
```
mkdir -p {conf,incoming}
```
* Créer le fichier de configuration conf/distribitions qui contient la configuration du dépôt et la liste des distributions. Voici un exemple de contenu
```
Origin: Vanessa Kovalsky
Label: MYREPO
Suite: stable
Codename: myrepo-stable
Architectures: amd64
Components: main
Description: My wonderfull repo
SignWith: yes

Origin: Vanessa Kovalsky
Label: MYREPO
Suite: stable-integration
Codename: myrepo-stable-integration
Architectures: amd64
Components: main
Description: My wonderfull repo
SignWith: yes

Origin: Vanessa Kovalsky
Label: MYREPO
Suite: testing
Codename: myrepo-testing
Architectures: amd64
Components: main
Description: My wonderfull repo
SignWith: yes

Origin: Vanessa Kovalsky
Label: MYREPO
Suite: testing-integration
Codename: myrepo-testing-integration
Architectures: amd64
Components: main
Description: My wonderfull repo
SignWith: yes
```
* Avec cet exemple on a 4 depôts : 
* * stable 
* * stable-integration
* * testing
* * testing-integration
* Stable et testing sont les mêmes types de dépôts que les dépôts officiels de Debian.
* Les depôts dont le nom finit par -integration sont ceux qui servent à faire des tests sur les paquets sans impacter les environnements de production qui utilisent les depôts stable et testing.

* On va inclure le paquet myecho.deb créé précédemment dans le depôt.
* Copier le paquet dans le dossier incoming que l'on a créé
* Pour cela il faut signer le paquet avec la clé GPG que l'on a généré :
```
dpkg-sig --sign builder incoming/myecho.deb
```
* Puis avec l'utilitaire reprepro (à installer) on inclut le paquet en précisant sur quel distribution on souhaite que le paquet apparaissent: 
```
reprepro -Vb . includedeb testing-integration 
```

* Il ne reste plus qu'à nous connecter sur notre depôt depuis un client.
* Depuis une autre machine, copier la clé ssh sur le serveur de depôt
```
ssh-copy-id myrepo@IP-DU-DEPOT
```
* Ajouter le dépôt dans le fichier de sources et mettre à jour la liste des depôts :
```
echo "deb ssh://myrepo@IP-DU-DEPOT:/home/myrepo/ myrepo-testing-integration main" >> /etc/apt/sources.list
aptitude update
```
* Installer maintenant le paquet myecho 
```
sudo aptitude install myecho
```

-> Félicitation la création de paquets et de dépôts n'est plus un mystère pour vous