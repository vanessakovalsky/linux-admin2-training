{ perl -e '$var=2.5;while(1){$var*=3;$var/=3;}' & sleep 10; kill $!; } &
