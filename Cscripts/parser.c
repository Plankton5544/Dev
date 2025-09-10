#include <stdio.h>  // For perror() and printf()
#include <fcntl.h>  // For open() and O_RDONLY
#include <unistd.h> // For read() and close()
#include <string.h> // For strings

int main () {
    int fd = open("example.bmp", O_RDONLY);

    if (fd == -1) {
        perror("Error opening file");
        return -1;
    }

      char buffer[2000000];

    ssize_t bytesRead = read(fd, buffer, sizeof(buffer));



    if (bytesRead == -1) {
        perror("Error reading file");
    } else if (bytesRead == 0) {
        printf("End of file reached\n");
    } else {
        printf("Read %zd bytes: %b\n", bytesRead, buffer);
    }

    char firsttwo[3];
    strncpy(firsttwo, buffer, 2);
    printf("FIRST TWO: %s\n", firsttwo);


    int result = strcmp(firsttwo, "BM");



    if (result == 0) {
        printf("VALID BMP.\n");
    } else if (result < 0) {
        printf("INVALID BMP. ERR1\n");
    } else {
        printf("INVALID BMP ERR2.\n");
    }






    // Print the ASCII representation of the binary data
    //for (int i = 0; i < sizeof(buffer); i++) {
    //    printf("%c", buffer[i]);
    //}

    printf("\n");


    close(fd);
    return 0;
}

