# Exercice 6 - Disques

Cet exercice a pour objectif :
- d'apprendre à utiliser les quotas
- de définir et utiliser les ACL
- d'utiliser les attributs étendus 
- de définir et utiliser le SWAP 

## Apprendre à utiliser les quotas

* Vérifier que le noyau prend bien en charge les quotas
```
grep -i quota /boot/config-$(uname -r)
```
* Monter un FS avec les options de quotas 
```
mkfs -t ext4 -q /dev/sda5
mount -t ext4 -o usrquota,grpquota /dev/sda5 /mnt
mount |grep /mnt
```
* Créer les fichiers quota à la racine du FS
```
quotacheck
ls -l /mnt
```
* Vérifier si les quotas sont activés, ensuite les activer.
```
quotaon -p /mnt
quotaon /mnt
quotaon -p /mnt
```
* Modifier les quotas d’un utilisateur et autoriser ce dernier à écrire dans le FS.
```
edquota guest
chmod a+rwx /mnt
```
* Se connecter sous ce compte et essayer de dépasser les quotas.
```
su - guest
cd /mnt
cp /etc/profile .
quota
dd if=/dev/zero of=toto bs=1k count=1500
ls -lh toto
quota
exit
```
* L’administrateur visualise l’usage des quotas.
```
repquota /mnt
```
* 
```

```
* 
```

```
* 
```

```
* 
```

```


## Définir et utiliser les ACL

## Utiliser les attributs étendus 

## Définir et utiliser le SWAP 
