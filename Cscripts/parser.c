#include <stdint.h>  // For alot of stuffs
#include <stdio.h>   // For perror() and printf()
#include <fcntl.h>   // For open() and O_RDONLY
#include <unistd.h>  // For read() and close()
#include <string.h>  // For strings

// Author: Plankton5544
/// Date Of Creation: September 10 2025
//Idea: ASCII Renderer Using C
//Features:
/*
   BMP Parsing
   Restructure & Polish
   Check if we have at least one argument (Required String)

   !Reminder!
   uint8_t = 1 byte
   uint16_t = 2 bytes
   uint32_t = 4 bytes
   uint64_t = 8 bytes
   */

//Read Little Endian 4-byte
uint32_t read_le_4(const char *buffer, int offset) {
    const uint8_t *bytes = (const uint8_t *)(buffer + offset);
    return (uint32_t)bytes[0] |
        ((uint32_t)bytes[1] << 8) |
        ((uint32_t)bytes[2] << 16) |
        ((uint32_t)bytes[3] << 24);
}
//Read Little Endian 2-byte
uint16_t read_le_2(const char *buffer, int offset) {
    const uint8_t *bytes = (const uint8_t *)(buffer + offset);
    return (uint16_t)bytes[0] |
        ((uint16_t)bytes[1] << 8);
}



// Access pixel at (x, y)
int get_pixel_offset(int x, int y, int width, int padded_row_width, bool bottom_up, int height, int data_offset, int bytes_per_pix) {
    int row = bottom_up ? (height - 1 - y) : y;  // Handle orientation
    return data_offset + (row * padded_row_width) + (x * bytes_per_pix);
}

int main () {
    char brightness_scale[] = " .:>!$%#@M";
    char pixel_data[2000000];
    char buffer[2000000];
    uint8_t averages[2000000];


    int fd = open("example.bmp", O_RDONLY);

    if (fd == -1) {
        perror("Error opening file");
        return -1;
    }

    ssize_t bytesread = read(fd, buffer, sizeof(buffer));



    if (bytesread == -1) {
        perror("Error reading file");
    } else if (bytesread == 0) {
        printf("End of file reached\n");
    } else {
        printf("Read %zd bytes\n", bytesread);
    }

    char signature[3];
    strncpy(signature, buffer, 2);
    signature[2] = '\0'; // Null terminate

    if (strcmp(signature, "BM") == 0) {
        printf("VALID BMP.\n");
    } else {
        printf("INVALID BMP.\n");
        close(fd);
        return -1;
    }



    // BMP file structure uses 4-byte values mostly
    uint32_t file_size = read_le_4(buffer, 2);
    uint32_t data_offset = read_le_4(buffer, 10);

    uint32_t DIB_header_size = read_le_4(buffer, 14);
    uint32_t width = read_le_4(buffer, 18);
    uint32_t height = read_le_4(buffer, 22);
    uint16_t planes = read_le_2(buffer, 26);
    uint16_t bits_per_pix = read_le_2(buffer, 28);
    uint32_t compression = read_le_4(buffer, 30);
    uint32_t image_size = read_le_4(buffer, 34);
    uint32_t x_pix_per_meter = read_le_4(buffer, 38);
    uint32_t y_pix_per_meter = read_le_4(buffer, 42);
    uint32_t colors_used = read_le_4(buffer, 46);
    uint32_t colors_important = read_le_4(buffer, 50);

    // Calculate row padding
    int bytes_per_pix = bits_per_pix / 8;
    int row_width = width * bytes_per_pix;
    int padding = (4 - (row_width % 4)) % 4;
    int padded_row_width = row_width + padding;
    // Other
    int32_t height_signed = (int32_t)read_le_4(buffer, 22);
    bool bottom_up = height_signed > 0;
    if (height_signed < 0) {
        height_signed=(height_signed * -1);
    }
    uint32_t actual_height = height_signed;


    // For 24-bit pixels:
    uint8_t blue  = pixel_data[0];
    uint8_t green = pixel_data[1];
    uint8_t red   = pixel_data[2];

    if (compression > 0) {
        perror("COMPRESSED IMAGE!");
        return -1;
    } else if (bits_per_pix != 24 && bits_per_pix != 32) {
        perror("ONLY SUPPORT certain bits/pixel!");
        return -1;
    }

    printf("Signature: %s\n", signature);
    printf("DIB Header Size: %u\n", DIB_header_size);
    printf("Planes: %u\n", planes);
    printf("Compression: %u\n", compression);
    printf("File Size: %u\n", file_size);
    printf("Width: %u\n", width);
    printf("Height: %u\n", height);
    printf("Bits/Pixel: %u\n", bits_per_pix);

    // Print the ASCII representation of the binary data
    //for (int i = 0; i < sizeof(buffer); i++) {
    //    printf("%c", buffer[i]);
    //}

    printf("\n");


        for (uint32_t y=0; y < actual_height; y++) {
            for (uint32_t x=0; x < width; x++) {
                int file_row = bottom_up ? (actual_height - 1 - y) : y;
                int pixel_offset = data_offset + (file_row * padded_row_width) + (x * bytes_per_pix);
                uint8_t blue  = buffer[pixel_offset];
                uint8_t green = buffer[pixel_offset + 1];
                uint8_t red   = buffer[pixel_offset + 2];



                uint8_t avg = (red + green + blue) / 3;
                int array_index = y * width + x;
                averages[array_index] = avg;
            }
        }
        printf("Processing complete!\n");
            for (int i=0; i < (width * actual_height); i++) {
        //        printf("%u\n", averages[i]);

                uint8_t char_index=(averages[i] * (10) / 255 );
//                char_index=(9-char_index);

                char ascii_char=brightness_scale[char_index];
                printf("%c", ascii_char);
                printf("%c", ascii_char);
                if ((i + 1) % width == 0) {
                    printf("\n");
                }
            }


    close(fd);
    return 0;
}



