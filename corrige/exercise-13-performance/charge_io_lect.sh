{ find / -type f -exec grep -i Linux {} \; > /dev/null 2>&1 & sleep 10;kill $!;
} &
