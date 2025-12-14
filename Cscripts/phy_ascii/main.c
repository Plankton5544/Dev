#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <stdbool.h>

#include <string.h>

struct term {
    int column;
    int row;
};

struct pos {
    float x;
    float y;
};

struct vel {
    float vx;
    float vy;
};

struct entity {
    struct pos position;
    struct vel velocity;
};

void render(int height, int width, struct entity *obj) {
    printf("\033[H");  // Move cursor to top-left
    char screen[height][width];

    for (int y=0; y<height; y++) {
        for (int x=0; x<width; x++) {
            screen[y][x] = ' ';
        }
    }

    int dx = (int)obj->position.x;
    int dy = (int)obj->position.y;

    if (dx >= 0 && dx < width && dy >= 0 && dy < height) {
        screen[dy][dx] = 'O';
    }

    for (int y=0; y<height; y++) {
        for (int x=0; x<width; x++) {
            putchar(screen[y][x]);
        }
        putchar('\n');
    }

}

void phy_update(struct entity *obj, float gravity, float dt) {
    obj->velocity.vy += (gravity * dt);
    obj->position.x += (obj->velocity.vx * dt);
    obj->position.y += (obj->velocity.vy * dt);
}

void collision(struct entity *obj, int height, int width, float restitution) {
    if (obj->position.y >= height - 1) {
        obj->position.y = height - 1;
        obj->velocity.vy = -obj->velocity.vy * restitution;
    }
    if (obj->position.x <= 0 || obj->position.x >= width - 1) {
        obj->velocity.vx = -obj->velocity.vx * restitution;
    }

}

int main() {
    float gravity = 30.0f;
    float restitution = 0.7f;
    float dt = 0.05f;
    struct entity ball={{15, 5}, {25, 25}};

    bool running=true;

    // Get the terminal size
    struct winsize sz;

    printf("\033[2J"); // Clear terminal
    printf("\033[?25l");

    while (running) {
        phy_update(&ball, gravity, dt);

        ioctl(STDOUT_FILENO, TIOCGWINSZ, &sz);
        struct term terminal={
           .row = sz.ws_row,
           .column = sz.ws_col
        };

        collision(&ball, terminal.row, terminal.column, restitution);

        render(terminal.row, terminal.column, &ball);
        usleep(50000);
    }

    printf("\033[?25h");
    return 0;
}
