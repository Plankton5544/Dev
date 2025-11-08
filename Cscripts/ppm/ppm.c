#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define IMAGE_WIDTH  256
#define IMAGE_HEIGHT 256

typedef struct {
    unsigned char r;
    unsigned char g;
    unsigned char b;
} pixel;

void draw_gradient(pixel *canvas, int w, int h) {
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            int index = y * w + x;

              float  R = 128 + 127 * sin(x / 30) * cos(y / 30);
              float  G = 128 + 127 * sin(x / 20 + y / 30);
              float  B = 128 + 127 * cos(x / 30) * sin(y / 20);

            canvas[index].r = R;
            canvas[index].g = G;
            canvas[index].b = B;
        }
    }
}




int main() {
    pixel *canvas;
    size_t total_bytes = IMAGE_WIDTH * IMAGE_HEIGHT * sizeof(pixel);
    canvas = (pixel *)malloc(total_bytes);

    //Error Checking
    if (canvas == NULL) {
        // Print error message to standard error (stderr)
        fprintf(stderr, "Error: Failed to allocate %zu bytes for the canvas.\n", total_bytes);
        // Terminate program with a non-zero status code (indicating failure)
        return EXIT_FAILURE; // A constant defined in stdlib.h for failure
    }

    draw_gradient(canvas, IMAGE_WIDTH, IMAGE_HEIGHT);


    FILE *output_file = fopen("output.ppm", "w");

    fprintf(output_file, "P3\n");
    fprintf(output_file, "%d %d\n", IMAGE_WIDTH, IMAGE_HEIGHT);
    fprintf(output_file, "255\n"); // Max color value

    for (int i=0; i< IMAGE_WIDTH * IMAGE_HEIGHT; i++) {
        fprintf(output_file, "%d %d %d ",
                canvas[i].r,
                canvas[i].g,
                canvas[i].b);

                if ((i + 1) % 4 == 0) {
                fprintf(output_file, "\n");
                }
    }




    fclose(output_file);

    // Clean up memory
    free(canvas);

    return EXIT_SUCCESS; // A constant defined in stdlib.h for success
}
