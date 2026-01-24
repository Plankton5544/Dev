#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
//Work in progress


int main() {

    FILE *f = fopen("example.bmp", "rb");
    if (!f) {
        perror("fopen");
        return 1;
    }

    fseek(f, 0, SEEK_END);
    //Size in number of bytes of the read file
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);

    unsigned char *data = malloc(size);
    if (!data) {
        perror("malloc");
        fclose(f);
        return 1;
    }

    size_t read = fread(data, 1, size, f);
    if (read != size) {
        perror("WARNING: Partial Read!");
        fclose(f);
        return 1;
    }

// PARSER EXECUTION


free(data);
fclose(f);
}
