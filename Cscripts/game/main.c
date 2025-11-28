#include <ncurses.h>
#include <time.h>
#include <unistd.h>

void apply_phys() {
    player1.y = player1.y - gravity;
    //f=ma

    velocity =
    //move.x = speed * cos(angle * PI / 180);
    //move.y = speed * sin(angle * PI / 180);

};


struct velocity {
    float
}
struct position {
    float x;
    float y;
};

struct player {
    float mass;

};

int main() {
    initscr();
    noecho();
    cbreak();
    keypad(stdscr, TRUE);
    nodelay(stdscr, TRUE);  // <-- Add this! Makes getch() non-blocking

    int height, width;
    getmaxyx(stdscr, height, width);

    struct position player1;
    player1.x = width / 2;
    player1.y = height / 2;

    int frame_count = 0;

    while (1) {
        int input = getch();
        if (input != ERR) {  // ERR means no key was pressed
            switch (input) {
                case 'w': player1.y--; player1.y--; break;
                case 's': player1.y++; break;
                case 'a': player1.x--; break;
                case 'd': player1.x++; break;
                case 'q':
          endwin();
          return 0;
            }
        }

        // Clear and redraw
        clear();

        for (int y = 2; y < height - 2; y++) {
            for (int x = 2; x < width - 2; x++) {
                mvprintw(y, x, ".");
            }
        }


        mvprintw(player1.y, player1.x, "P");
        refresh();

        struct timespec req = {0, 100000000}; // 100ms = 10 FPS
        nanosleep(&req, NULL);

        frame_count++;
    }

    endwin();
    return 0;
}
