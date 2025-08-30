#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {

    FILE *file = fopen(argv[1], "rb");
    int c;

    //while ((c = fgetc(f)) != EOF) {
    //    printf("%02X ", c);
    //}
    //fclose(f);


    unsigned char byte[];
    if (fread(&byte, 2, 1, file) == 1) {
        for item in byte; do
            done
    }


}
