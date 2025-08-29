#include <stdio.h>
#include <math.h>
#include <unistd.h>


double totalblank=100;


int total_in=0;

int main() {

    for(int i=0; i < totalblank+1; i++) {

        double percent_done=((i * 100) / totalblank);
        double filled=((10 * i));
        double left=(10 - filled);



        //printf("\033[2J");

        printf("\n[");
        for (int j=0; j<percent_done; j+=10) {
            printf("%c", '=');
        }

        printf("%i  ", filled);
        printf("%i   ", left);

        for(int k=0; k<left; k+=10) {
            printf("%c", ' ');
        }



        printf("]");


        printf("%g%c", percent_done, '%');
    };


return 0;
}
