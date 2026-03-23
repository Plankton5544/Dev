#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

#define WIDTH 100
#define HEIGHT 20

typedef enum {
    EMPTY=0,
    SAND=1,
    WATER=2
} type;

typedef struct {
    type class;
} Cell;


void simulate(bool* state, Cell screen_cells[WIDTH][HEIGHT]) {
    for (int y=HEIGHT-2; y>=0; y--) {
        for (int x=WIDTH-1; x>=0; x--) {
            if (screen_cells[x][y].class == SAND && screen_cells[x][y+1].class == EMPTY) {
                screen_cells[x][y].class = EMPTY;
                screen_cells[x][y+1].class = SAND;
            }
        }
    }
};

void render(Cell screen_cells[WIDTH][HEIGHT]) {
    printf("\033[2J");
    printf("\033[H");
    for (int y=0; y<HEIGHT; y++) {
        for (int x=0; x<WIDTH; x++) {
            if (screen_cells[x][y].class == EMPTY) {
                printf(" ");
            } else if (screen_cells[x][y].class == SAND) {
                printf("S");
            } else if (screen_cells[x][y].class == WATER) {
                printf("W");
            }
        }
        printf("\n");
    }
    sleep(1);
};

void initialize_cells(Cell screen_cells[WIDTH][HEIGHT]) {
    for (int y=0; y<HEIGHT; y++) {
        for (int x=0; x<WIDTH; x++) {
            if (y>5 && y<8) {
                screen_cells[x][y].class=SAND;
            }else {
                screen_cells[x][y].class=EMPTY;
            }

        }
    }
};

int main() {
    bool running=true;
    Cell screen[WIDTH][HEIGHT];

    initialize_cells(screen);

    while (running) {
        simulate(&running, screen);
        render(screen);
    }
    return 0;
}
