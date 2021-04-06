GROSFIC=/usr/grosfic
for i in 1 2 3 4 5 6 7
do
fic=${GROSFIC}${i}.dat
dd if=/dev/zero of=$fic bs=1k count=100000 > /dev/null 2>&1
rm $fic
done
