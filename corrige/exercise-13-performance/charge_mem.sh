{ perl -e 'for ($i=0;$i<100000000;$i++){$tb[$i]=$i;}' & sleep 10; kill $!; } &
