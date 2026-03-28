#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

#define WIDTH 95
#define HEIGHT 40
#define BUF_SIZE (WIDTH * HEIGHT * 20)

typedef enum {
    SMALL=0,
    MEDIUM=5,
    BIG=10,
} Size;

typedef enum {
    CURS=-1,
    EMPTY=0,

    WATER=1,
    LAVA=2,
    SAND=3,

    STONE=4,
    OBSIDIAN=5,
} Type;

typedef struct {
    int x;
    int y;
} Pos;

typedef struct {
    Type class;
    float lifetime;
} Cell;

void sim_move_x(Cell cell[WIDTH][HEIGHT], int x, int y) {
    int dir;
    if (rand() % 2) {
        dir = 1;
    } else {
        dir = -1;
    }

    if (x+dir < 0 || x+dir >= WIDTH) {
        return;
    } else if (x-dir < 0 || x-dir >= WIDTH) {
        return;
    }

    if (cell[x+dir][y].class < cell[x][y].class) {
        Type TEMP = cell[x+dir][y].class;
        if (TEMP >= 0) {
            cell[x+dir][y].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    } else if (cell[x-dir][y].class < cell[x][y].class) {
        Type TEMP = cell[x-dir][y].class;
        if (TEMP >= 0) {
            cell[x-dir][y].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    }
}

void sim_rise(Cell cell[WIDTH][HEIGHT], int x, int y) {
    if (y-1 < 0 || y-1 >= HEIGHT) {
        return;
    }

    if (cell[x][y-1].class < cell[x][y].class) {
        Type TEMP = cell[x][y-1].class;
        if (TEMP >= 0) {
            cell[x][y-1].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    }
}

void sim_diag_move(Cell cell[WIDTH][HEIGHT], int x, int y) {
    int dir;
    if (rand() % 2) {
        dir = 1;
    } else {
        dir = -1;
    }

    if (x+dir < 0 || x+dir >= WIDTH) {
        return;
    } else if (x-dir < 0 || x-dir >= WIDTH) {
        return;

    } else if (y+1 < 0 || y+1 >= HEIGHT) {
        return;
    } else if (y-1 < 0 || y-1 >= HEIGHT) {
        return;
    }

    if (cell[x+dir][y+1].class < cell[x][y].class) {
        Type TEMP = cell[x+dir][y+1].class;
        if (TEMP >= 0) {
            cell[x+dir][y+1].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    } else if (cell[x-dir][y+1].class < cell[x][y].class) {
        Type TEMP = cell[x-dir][y+1].class;
        if (TEMP >= 0) {
            cell[x-dir][y+1].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    }
}

void sim_lava_check(Cell cell[WIDTH][HEIGHT], int x, int y) {

    if (x-1 < 0 || x+1 >= WIDTH) {
        return;
        // STONE
    } else if (cell[x-1][y].class == WATER) {
        cell[x-1][y].class = STONE;
    } else if (cell[x+1][y].class == WATER) {
        cell[x+1][y].class = STONE;
    }

    if (y-1 < 0 || y+1 >= HEIGHT) {
        return;
        // OBY
    } else if (cell[x][y-1].class == WATER) {
        cell[x][y].class = OBSIDIAN;
        // OBY
    } else if (cell[x][y+1].class == WATER) {
        cell[x][y+1].class = OBSIDIAN;
    }
}

void sim_fall(Cell cell[WIDTH][HEIGHT], int x, int y) {
    //==BelowCheck
    if (cell[x][y+1].class < cell[x][y].class) {
        Type TEMP = cell[x][y+1].class;
        if (TEMP >= 0) {
            cell[x][y+1].class = cell[x][y].class;
            cell[x][y].class = TEMP;
        }
    }
}


void simulate(Cell scell[WIDTH][HEIGHT]) {
    for (int y=HEIGHT-2; y>=0; y--) {
        for (int x=WIDTH-1; x>=0; x--) {

            switch (scell[x][y].class) {
                case SAND:
                    sim_fall(scell, x, y);
                    sim_diag_move(scell, x, y);
                    break;

                case WATER:
                    sim_fall(scell, x, y);
                    sim_move_x(scell, x, y);
                    break;

                case LAVA:
                    sim_lava_check(scell, x, y);
                    sim_fall(scell, x, y);
                    sim_move_x(scell, x, y);
                    break;

                case STONE:
                    sim_fall(scell, x, y);
                    sim_diag_move(scell, x, y);
                    break;

                case OBSIDIAN:
                    break;

                case EMPTY:
                    break;
            }

        }
    }
}

void render(Cell screen_cells[WIDTH][HEIGHT]) {
    char buffer[BUF_SIZE]; // 20 chars per cell is enough for escape codes
    int position = 0;
    static Type prev[WIDTH][HEIGHT] = {0};

    position += sprintf(buffer + position, "\033[H"); // move to top-left (replaces \033[2J clear)

    for (int y=0; y<HEIGHT; y++) {
        for (int x=0; x<WIDTH; x++) {
            Type current = screen_cells[x][y].class;

            if (current == prev[x][y]) continue;  // ← skip if unchanged
            prev[x][y] = current;

            // move cursor to this cell's position
            position += sprintf(buffer + position, "\033[%d;%dH", y+1, x+1);

            switch (screen_cells[x][y].class) {
                case SAND:
                    position += sprintf(buffer + position, "\033[0;43m \033[0m");
                    break;

                case WATER:
                    position += sprintf(buffer + position, "\033[0;44m \033[0m");
                    break;

                case LAVA:
                    position += sprintf(buffer + position, "\033[0;41m \033[0m");
                    break;

                case STONE:
                    position += sprintf(buffer + position, "\033[0;47m \033[0m");
                    break;

                case OBSIDIAN:
                    position += sprintf(buffer + position, "\033[0;40m \033[0m");
                    break;

                case CURS:
                    position += sprintf(buffer + position, "X");
                    break;

                default:
                    position += sprintf(buffer + position, " ");
            }
        }
        position += sprintf(buffer + position, "\n");
    }
    write(STDOUT_FILENO, buffer, position);
}

void init_cells(Cell screen_cells[WIDTH][HEIGHT]) {
    for (int y=0; y<HEIGHT; y++) {
        for (int x=0; x<WIDTH; x++) {
            if (x == 5) {
                screen_cells[x][y].class=SAND;
            }else {
                screen_cells[x][y].class=EMPTY;
            }
        }
    }
}

void init_curs(Cell screen[WIDTH][HEIGHT], Pos *curs, int x, int y) {
    curs->x=x;
    curs->y=y;
    screen[x][y].class=CURS;
}

void update_curs(Cell screen[WIDTH][HEIGHT], Pos *curs, int x, int y) {
    if (x>0 && x<WIDTH-1 && y>0 && y<HEIGHT-1) {
        screen[curs->x][curs->y].class=EMPTY;
        curs->x=x;
        curs->y=y;
        screen[x][y].class=CURS;
    } else {
        screen[curs->x][curs->y].class=EMPTY;
        init_curs(screen, curs, 1, 1);
    }
}

void spawn(Cell cell[WIDTH][HEIGHT], Pos *curs, Type classification, Size radius) {
    switch (radius) {
        case SMALL:
            cell[curs->x][curs->y+1].class=classification;
            break;

        case MEDIUM:
            cell[curs->x][curs->y+1].class=classification;
            cell[curs->x-1][curs->y].class=classification;
            cell[curs->x+1][curs->y].class=classification;
            break;

        case BIG:
            cell[curs->x][curs->y+1].class=classification;
            cell[curs->x][curs->y-1].class=classification;

            cell[curs->x-1][curs->y].class=classification;
            cell[curs->x+1][curs->y].class=classification;

            cell[curs->x+2][curs->y].class=classification;
            cell[curs->x-2][curs->y].class=classification;

            cell[curs->x][curs->y-2].class=classification;
            cell[curs->x][curs->y+2].class=classification;
            break;

        default:
            cell[curs->x][curs->y+1].class=classification;
            break;

    }
}

void input(bool *running, char cinput, Cell screen[WIDTH][HEIGHT], Pos *curs) {
    switch (cinput) {
        case 'q':
            *running=false;
            break;

        case 'R':
            init_cells(screen);
            init_curs(screen, curs, 5, 5);
            break;

            //===SAND
        case 'z':
            spawn(screen, curs, SAND, SMALL);
            break;
        case 'Z':
            spawn(screen, curs, SAND, MEDIUM);
            break;

            //===WATER
        case 'e':
            spawn(screen, curs, WATER, SMALL);
            break;
        case 'E':
            spawn(screen, curs, WATER, MEDIUM);
            break;

            //===LAVA
        case 'x':
            spawn(screen, curs, LAVA, SMALL);
            break;
        case 'X':
            spawn(screen, curs, LAVA, MEDIUM);
            break;

            //===OBY
        case 'f':
            spawn(screen, curs, OBSIDIAN, SMALL);
            break;
            //===STONE
        case 'F':
            spawn(screen, curs, STONE, MEDIUM);
            break;

            //===ERASER
        case 'c':
            spawn(screen, curs, EMPTY, BIG);
            break;

        case 'a':
            // CURSER MOVING LEFT
            update_curs(screen, curs, curs->x-1, curs->y);
            break;

        case 'd':
            // CURSER MOVING RIGHT
            update_curs(screen, curs, curs->x+1, curs->y);
            break;

        case 'w':
            // CURSER MOVING UP
            update_curs(screen, curs, curs->x, curs->y-1);
            break;

        case 's':
            // CURSER MOVING DOWN
            update_curs(screen, curs, curs->x, curs->y+1);
            break;
    }
}

int main() {
    //==TERMINAL JARGON==//
    // Make stdin non-blocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
    // Save old settings and switch to raw mode
    struct termios oldt, newt;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);  // disable buffering and echo
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    //==================//

    //MAIN
    bool running=true;
    Cell screen[WIDTH][HEIGHT];
    Pos curser;

    init_cells(screen);
    init_curs(screen, &curser, 5, 5);

    printf("\033[2J"); // Clear terminal
    printf("\033[?25l"); // Hide cursor

    while (running) {
        //SIMULATE
        simulate(screen);
        //
        // INPUT
        char c;
        while (read(STDIN_FILENO, &c, 1) > 0) {
            input(&running, c, screen, &curser);
        }

        //RENDER
        render(screen);
        //
        usleep(50000);
    }

    printf("\033[?25h"); // Show cursor
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return 0;
}
