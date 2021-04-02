# include <stdlib.h>
# include <time.h>
int random_number() {
srandom( time(0) );
return random() % 100 + 1;
}
