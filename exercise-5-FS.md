# Exercice 5 - Système de fichiers

Cet exercice a pour objectifs :
* de créer, manipuler, gérer des partitions
* de gérer des FS EXT2/3/4
* de mettre en place un serveur NFS
* de créer un FS temporaire

## Créer, manipuler, gérer des partitions

*  Créer 4 partitions : 
* * Une partitions étendues qui contient l'ensemble des partitions suivantes 
* * Une partion logique de 512M
* * 3 autres partitions logique (dont la taille dépend de l'espace disque disponible sur vos machines)
/!\ adapter à vos propres disques présents sur la machine
```
fdisk /dev/sda
```
* Puis on sauvegarde la table des partitions 
```
partprobe
```
* Puis on vérifie en affichant les partitions
```
fdisk -l /dev/sda
```
* Connaitre les FS pris en charge par votre système : 
```
cat /proc/filesystems | cut -f2 |pr -4t
ls /lib/modules/$(uname -r)/kernel/fs
```
* La première commande liste les FS pris en charge actuellement par le noyau. La seconde ceux que l'on peut ajouter en les chargeant sur le noyau (nécessite d'ajouter un module au noyau s'il n'est pas présent dans la première liste)
* Voir les FS monté au démarrage
```
cat /etc/fstab
```
* Créer un FS
```
mkfs -q /dev/sda5
```
* Monter un FS
```
mount /dev/sda5 /mnt
```
* Lister les FS montés
```
df -Th
mount
```
* Lister tous les FS montés, y-compris les FS spéciaux (proc, sysfs...)
```
df -a
```
* Démonter un FS
```
umount /mnt
```
* Déterminer le type de contenu des disques (montés ou non)
```
blkid
blkid -s TYPE/dev/sda5
```
* Modifier et visualiser l'étiquette (label) d'un FS ext2/3/4 et le monter via le label 
```
e2label /dev/sda5 oracle
e2label /dev/sda5
blkid -s LABEL /dev/sda5
mount LABEL=oracle /mnt
df
umount /mnt
```
* Visualiser et modifier l’UUID d’un FS ext2/ext3/ext4. Enfin, monter le FS via son UUID
```
blkid -s UUID /dev/sda5
uuidgen
tune2fs /dev/sda5 -U f317fcf8-3488-43a5-886a-330d9434ee07
blkid -s UUID /dev/sda5
mount UUID="f317fcf8-3488-43a5-886a-330d9434ee07" /mnt
df
umount /mnt
```
* Rechercher un FS via son label ou via son UUID
```
findfs LABEL=oracle
findfs UUID="f317fcf8-3488-43a5-886a-330d9434ee07"
```

## Gérer des FS EXT2/3/4
* Les FS EXT sont les plus fréquemment utilisés. Il est donc intéressant de savoir les créer et d'utiliser les commandes dédiés. 
* Créer un FS Ext2 avec des blocs de 4Ko
```
mkfs -b 4096 /dev/sda5
```
* Créer un journal, le FS devient donc un Ext3
```
blkid -s TYPE /dev/sda5
tune2fs -j /dev/sda5
blkid -s TYPE /dev/sda5
```
* Visualiser les caractéristiques du FS
```
tune2fs -l /dev/sda5
```
* Monter le FS sans activer le journal.
```
mount -t ext2 /dev/sda5 /mnt
df -Th /dev/sda5
```
* Remonter le FS en tant que Ext3, on active donc la journalisation
```
umount /mnt
mount -t ext3 /dev/sda5 /mnt
df -Th /dev/sda5
```
* Monter le FS Ext3 en tant que FS Ext4
```
umount /mnt
mount -t ext4 /dev/sda5 /mnt
df -Th /dev/sda5
umount /mnt
```
* Convertir le FS Ext3 en Ext4. Mais il ne sera plus montable en Ext3
```
mount -t ext3 /dev/sda5 /mnt
cp -a /etc/ /mnt
umount /mnt
tune2fs -O extents,uninit_bg,dir_index /dev/sda5
e2fsck /dev/sda5
e2fsck -f /dev/sda5
blkid -s TYPE /dev/sda5
mount -t ext4 /dev/sda5 /mnt
df -Th /dev/sda5
umount /mnt
mount -t ext3 /dev/sda5 /mnt # génère une erreur
mount -t ext4 /dev/sda5 /mnt
```
* Vérifier un FS Ext2/Ext3/Ext4. Il est vivement conseillé qu’il soit démonté
* * Vérification simple
```
umount /mnt
fsck /dev/sda5
```
* * L'option -f force la vérification complète du FS
```
fsck -f /dev/sda5
```
* Créer FS Ext4 avec un journal externe (la taille des blocs doit être identique)
```
mke2fs -b 4096 -O journal_dev /dev/sda6
```
* Visualiser la structure du FS.
```
dumpe2fs /dev/sda5
```
* Monter le FS en activant le journal.
```
mount -t ext4 /dev/sda5 /mnt
```
* Remonter le FS en journalisant également les données.
```
umount /mnt
mount -t ext4 -o data=journal /dev/sda5 /mnt
mount |grep /mnt
umount /mnt
```
* Modifier le nombre maximum de montages sans vérification (fsck).
```
mkfs -t ext4 -q /dev/sda5
tune2fs -l /dev/sda5 |grep -i 'mount count'
tune2fs -c 5 /dev/sda5
tune2fs -l /dev/sda5 |grep -i 'mount count'
mount /dev/sda5 /mnt
umount /mnt
tune2fs -l /dev/sda5 |grep -i 'mount count'
```
* Créer un FS, supprimer par erreur son Superbloc, le réparer, le monter et le démonter
```
mkfs -t ext4 -q /dev/sda5
dumpe2fs /dev/sda5 |grep superblock |head -3
dd if=/dev/zero of=/dev/sda5 bs=4k count=1
mount -t ext4 /dev/sda5 /mnt
e2fsck -b 32768 /dev/sda5
mount -t ext4 /dev/sda5 /mnt
umount /mnt
```
* Explorer et dépanner un FS.
```
mount -t ext4 /dev/sda5 /mnt
cal > /mnt/toto
ls -i /mnt/toto
umount /mnt
debugfs -w /dev/sda5
debugfs: pwd
debugfs: ls
debugfs: stat <12>
debugfs: testb 32801
debugfs: testb 40000
debugfs: ncheck 12
debugfs: quit
stat /etc/issue
```
* Mémoriser les métadonnées d’un FS dans un fichier
```
e2image /dev/sda5 /tmp/sda5.ext4
dumpe2fs -i /tmp/sda5.ext4
```
* Afficher la fragmentation de l’espace libre
```
e2freefrag /dev/vg00/lv_root
```

## Mettre en place un serveur NFS
### Red Hat
* Installer le client et le serveur NFS
```
// Red Hat 
yum -q -y install nfs-utils
```
* Exporter l’arborescence /var/ftp en lecture seule pour tout le monde
```
mkdir -p /var/ftp/pub
vi /etc/exports
```
* Activer le service RPCBIND, puis NFS. Surveiller la présence des démons
```
service rpcbind start
netstat -an |grep 111
service nfs start
ps -e | grep -e mountd -e nfsd -e rpc
```
* 
### Debian 
* Installer le client et le serveur NFS
```
// Debian
apt install -y nfs-kernel-server
```
* Activer le service
```
systemctl enable --now nfs-server.service
```

### Monter le partage depuis un client (en modifiant l'adresse IP pour la faire correspondre au serveur) 
* Installer le client : 
```
apt install nfs-common // Debian
yum install nfs-client // Red Hat
```
* Faire le montage
```
mount -t nfs 127.0.0.1:/var/ftp /mnt
ls /mnt
mount |grep -i nfs
df -Th /mnt
```

## Créer un FS temporaire
* Créer un FS de type tmpfs sans option
```
mount -t tmpfs tmpfs /mnt
free
cp /bin/* /mnt
df -Th /mnt
umount /mnt
```
* Créer un FS de type tmpfs en précisant sa taille maximum (64M) et les droits de la racine (770)
```
mount -o size=64M,mode=770 -t tmpfs tmpfs /mnt
df -Th /mnt
ls -ld /mnt
umount /mnt
```