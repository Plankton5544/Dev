#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <stdbool.h>

#include <termios.h>
#include <fcntl.h>

struct termios old_term;

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

//For Non-Blocking Inpu
void enable_raw_mode(void) {
    struct termios new_term;

    tcgetattr(STDIN_FILENO, &old_term);
    new_term = old_term;

    new_term.c_lflag &= ~(ICANON | ECHO);
    new_term.c_cc[VMIN] = 0;
    new_term.c_cc[VTIME] = 0;

    tcsetattr(STDIN_FILENO, TCSANOW, &new_term);

    fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);
}

//Disables Non-Blocking Input
void disable_raw_mode(void) {
    tcsetattr(STDIN_FILENO, TCSANOW, &old_term);
}

void render(int height, int width, struct entity *object, int size) {
    printf("\033[H");  // Move cursor to top-left
    char screen[height][width];
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                if (x == width-1 || x == 0) {
                    screen[y][x] = '|';
                }else if (y == height-1 || y == 0) {
                    screen[y][x] = '=';
                }else {
                    screen[y][x] = ' ';
                }
            }
        }

    for (int z=0; z<size; z++) {
        //static struct pos pastpos[50];
        //int length = sizeof(pastpos) / sizeof(pastpos[0]);
        struct entity obj = object[z];
        //for (int i=length-1; i>0; i--) {
        //    pastpos[i].x = pastpos[i-1].x;
        //    pastpos[i].y = pastpos[i-1].y;
        //}
        //pastpos[0].x = (int)obj.position.x;
        //pastpos[0].y = (int)obj.position.y;
        //for (int i=1; i<length; i++) {
        //    int tx = (int)pastpos[i].x;
        //    int ty = (int)pastpos[i].y;
        //    if (tx >= 0 && tx < width && ty >= 0 && ty < height) {
        //        screen[ty][tx] = '~';
        //    }
        //}
        int dx = (int)obj.position.x;
        int dy = (int)obj.position.y;
        if (dx >= 0 && dx < width && dy >= 0 && dy < height) {
            screen[dy][dx] = 'o';
        }
    }

    for (int y=0; y<height; y++) {
        for (int x=0; x<width; x++) {
            putchar(screen[y][x]);
        }
        putchar('\n');
    }
}

void phy_update(struct entity *object, int size, float gravity, float dt) {
    for (int z=0; z<size; z++) {
        struct entity *obj = &object[z];
        obj->velocity.vy += (gravity * dt);
        obj->position.x += (obj->velocity.vx * dt);
        obj->position.y += (obj->velocity.vy * dt);
    }
}

void collision(struct entity *object, int size, int height, int width, float restitution) {
    for (int z=0; z<size; z++) {
        struct entity *obj = &object[z];
        //Vertical Impacts
        if (obj->position.y >= height - 1) {
            obj->position.y = height - 1;
            obj->velocity.vy = -obj->velocity.vy * restitution;
        }else if (obj->position.y <= 1) {
            obj->position.y = 1;
            obj->velocity.vy = -obj->velocity.vy * restitution;
        }

        //Horizontal Impacts
        if (obj->position.x <= 2 || obj->position.x >= width - 2) {
            obj->velocity.vx = -obj->velocity.vx * restitution;
        }

        //Friction 2% loss Horizontally
        if (obj->position.y >= height - 2) {
            obj->velocity.vx *= 0.98f;
        }
    }
}

void handle_input(char c, struct entity *object, int size, bool *running) {
    switch (c) {
        case 'q':
            *running = false;
            break;
        case 'a':
            for (int z=0; z<size; z++) {
                struct entity *ball = &object[z];
                ball->velocity.vx -= 10;
            }
            break;
        case 'd':
            for (int z=0; z<size; z++) {
                struct entity *ball = &object[z];
                ball->velocity.vx += 10;
            }
            break;
        case 'w':
            for (int z=0; z<size; z++) {
                struct entity *ball = &object[z];
                ball->velocity.vy -= 15;
            }
            break;
        case 's':
            for (int z=0; z<size; z++) {
                struct entity *ball = &object[z];
                ball->velocity.vy += 15;
            }
            break;
    }
}


int main() {
    enable_raw_mode();
    float gravity = 30.0f;
    float restitution = 0.7f;
    float dt = 0.05f;
    struct entity ball[2];
    int size=sizeof(ball) / sizeof(*ball);

    ball[0].position.x=20;
    ball[0].position.y=20;

    ball[0].velocity.vx=20;

    ball[1].position.x=10;
    ball[1].position.y=10;

    ball[1].velocity.vy=20;

    ball[2].position.x=15;
    ball[2].position.y=15;

    ball[2].velocity.vx=1;

    bool running=true;

    // Get the terminal size
    struct winsize sz;

    printf("\033[2J"); // Clear terminal
    printf("\033[?25l");

    while (running) {
        //Physics
        phy_update(ball, size,  gravity, dt);

        //Input
        char c;
        while (read(STDIN_FILENO, &c, 1) > 0) {
            handle_input(c, ball, size, &running);
        }

        //Terminal Resize
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &sz);
        struct term terminal={
            .row = sz.ws_row-1,
            .column = sz.ws_col
        };

        //Collision
        collision(ball, size, terminal.row-1, terminal.column-1, restitution);

        //RendeR
        render(terminal.row, terminal.column, ball, size);

        //Sleep
        usleep(50000);
    }

    printf("\033[?25h");
    disable_raw_mode();
    return 0;
}

