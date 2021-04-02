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
