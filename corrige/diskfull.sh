#!/bin/sh
# disk_full - teste si les disques sont plein
SEUIL=10
message=/tmp/bidon

df -P | grep -v '^Filesystem' | sed 's/%//' |
while read fs total used avail capacity mount
do
if [ "$capacity" -gt $SEUIL ];then
printf "%-20s %5d%%\n" $mount $capacity >> $message
fi
done
if [ -r $message ];then
	if [ -x mail --version ]
	then
		mail -s "LES DISQUES SONT PLEINS" root < $message
	else 
		sudo apt install mailutils
		echo 'Mail a été installé'
		mail -s "LES DISQUES SONT PLEINS" root < $message
		rm -f $message
	fi
fi