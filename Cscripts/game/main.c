#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <math.h>

#include <termios.h>
#include <fcntl.h>

#define BALL_RADIUS 1.5f
#define WALL_MARGIN 1

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
    struct pos pastpos[3];
    int state;
};


struct termios old_term;

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

void disable_raw_mode(void) {
    tcsetattr(STDIN_FILENO, TCSANOW, &old_term);
}

void cleanup(void) {
    printf("\033[?25h");
    disable_raw_mode();
}

void render(int height, int width, struct entity *object, int size) {
    printf("\033[H");  // Move cursor to top-left

    static char *screen = NULL;
    static int sw=0, sh=0;
    if (width != sw || height !=sh) {
        free(screen);
        screen = malloc(width * height);
        sw=width;
        sh=height;
    }
    if (!screen) exit(1);

    for (int y=0; y<height; y++) {
        for (int x=0; x<width; x++) {
            if ((x == width - WALL_MARGIN || x == 0 + WALL_MARGIN)
             && !(y <= 0 + WALL_MARGIN || y >= height - WALL_MARGIN)) {
                screen[y * width + x] = '|';
            }else if ((y == height - WALL_MARGIN || y == 0 + WALL_MARGIN)
             && !(x >= width - WALL_MARGIN || x <= 0 + WALL_MARGIN)) {
                screen[y * width + x] = '=';
            }else {
                screen[y * width + x] = ' ';
            }
        }
    }


    for (int z=0; z<size; z++) {
        struct entity *obj = &object[z];

        //struct pos pastpos[50];
        int length = sizeof(obj->pastpos) / sizeof(obj->pastpos[0]);
        for (int i=length-1; i>0; i--) {
            obj->pastpos[i].x = obj->pastpos[i-1].x;
            obj->pastpos[i].y = obj->pastpos[i-1].y;
        }
        obj->pastpos[0].x = (int)obj->position.x;
        obj->pastpos[0].y = (int)obj->position.y;
        for (int i=1; i<length; i++) {
            int tx = (int)obj->pastpos[i].x;
            int ty = (int)obj->pastpos[i].y;
            if (tx >= 0 && tx < width && ty >= 0 && ty < height) {
                screen[ty * width + tx] = '~';
            }
        }
        int dx = (int)obj->position.x;
        int dy = (int)obj->position.y;
        if (dx >= 0 && dx < width && dy >= 0 && dy < height) {
            switch (obj->state) {
                case 1: screen[dy * width + dx] = 'o'; break;
                case 2: screen[dy * width + dx] = '0'; break;
                case 3: screen[dy * width + dx] = '@'; break;
                case *: screen[dy * width + dx] = 'X'; break;
            }
        }

    }

    for (int y=0; y<height; y++) {
        for (int x=0; x<width; x++) {
            putchar(screen[y * width + x]);
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

        if (obj->velocity.vy != 0) {
            float ratio = fabsf(obj->velocity.vx);
            if (ratio <= 2.0f) obj->state = 1;
            else if (ratio <= 6.0) obj->state = 2;
            else obj->state = 3;
        }

        if (obj->velocity.vx > 30) obj->velocity.vx = 30;
        if (obj->velocity.vx < -30) obj->velocity.vx = -30;
    }
}

void collision(struct entity *object, int size, int height, int width, float restitution) {
    for (int z=0; z<size; z++) {
        struct entity *obj = &object[z];
        //Vertical Impacts
        if (obj->position.y >= height - WALL_MARGIN) {
            obj->position.y = height - WALL_MARGIN;
            obj->velocity.vy = -obj->velocity.vy * restitution;
        }else if (obj->position.y <= 1 + WALL_MARGIN) {
            obj->position.y = 1 + WALL_MARGIN;
            obj->velocity.vy = -obj->velocity.vy * restitution;
        }

        if (obj->position.x <= 1 + WALL_MARGIN) {
            obj->position.x = 1 + WALL_MARGIN;
            obj->velocity.vx = -obj->velocity.vx * restitution;
        } else if (obj->position.x >= width - WALL_MARGIN) {
            obj->position.x = width - WALL_MARGIN;
            obj->velocity.vx = -obj->velocity.vx * restitution;
        }

        //Friction 2% loss Horizontally
        if (obj->position.y >= height - 2) {
            obj->velocity.vx *= 0.98f;
        }

        //Ball-Ball Collisions
        for (int j=z+1; j<size; j++) {  // Only check each pair once
            struct entity *obj2= &object[j];
            float dx = obj2->position.x - obj->position.x;
            float dy = obj2->position.y - obj->position.y;
            float distance_squared = dx*dx + dy*dy;


            if (distance_squared < BALL_RADIUS && distance_squared > 0.001f) {
                float distance = sqrtf(distance_squared);

                // Normalize collision vector
                float nx = dx / distance;
                float ny = dy / distance;

                // Separate the balls (push apart)
                float overlap = BALL_RADIUS - distance;
                obj->position.x -= nx * overlap * 0.5f;
                obj->position.y -= ny * overlap * 0.5f;
                obj2->position.x += nx * overlap * 0.5f;
                obj2->position.y += ny * overlap * 0.5f;

                // Calculate relative velocity
                float dvx = obj2->velocity.vx - obj->velocity.vx;
                float dvy = obj2->velocity.vy - obj->velocity.vy;
                float relative_velocity = dvx * nx + dvy * ny;

                // Only bounce if approaching
                if (relative_velocity < 0) {
                    // Calculate and apply impulse
                    float impulse = -(1.0f + restitution) * relative_velocity;
                    obj->velocity.vx -= impulse * nx * 0.5f;
                    obj->velocity.vy -= impulse * ny * 0.5f;
                    obj2->velocity.vx += impulse * nx * 0.5f;
                    obj2->velocity.vy += impulse * ny * 0.5f;
                }
            }
        }

    }
}

void handle_input(char c, struct entity *object, int *running) {
    struct entity *player1 = &object[0];
    struct entity *player2 = &object[1];
    switch (c) {
        case 'q':
            *running = 0;
            break;
        case 'a':
            player1->velocity.vx -= 10;
            break;
        case 'd':
            player1->velocity.vx += 10;
            break;
        case 'w':
            player1->velocity.vy -= 10;
            break;
        case 's':
            player1->velocity.vy += 10;
            break;
        case 'k':
            player2->velocity.vy -= 10;
            break;
        case 'j':
            player2->velocity.vy += 10;
            break;
        case 'l':
            player2->velocity.vx += 10;
            break;
        case 'h':
            player2->velocity.vx -= 10;
            break;
    }
}

int main() {
    atexit(cleanup);
    enable_raw_mode();
    float gravity = 30.0f;
    float restitution = 0.7f;
    float dt = 0.05f;

    struct entity players[2];
    int size=sizeof(players) / sizeof(*players);


    players[0].position.x=10;
    players[0].position.y=10;

    players[1].position.x=0;
    players[1].position.y=0;

    players[0].velocity.vx=10;
    players[0].velocity.vy=10;

    players[1].velocity.vx=20;
    players[1].velocity.vy=20;

    players[0].state=1;
    players[1].state=1;

    int running=1;

    // Get the terminal size
    struct winsize sz;

    printf("\033[2J"); // Clear terminal
    printf("\033[?25l");


    while (running) {
        //Input
        char c;
        while (read(STDIN_FILENO, &c, 1) > 0) {
            handle_input(c, players, &running);
        }

        //Physics
        phy_update(players, size, gravity, dt);

        //Terminal Resize
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &sz);
        struct term terminal={
            .row = sz.ws_row-1,
            .column = sz.ws_col
        };

        //Collision
        collision(players, size, terminal.row-1, terminal.column-1, restitution);

        //RendeR
        render(terminal.row, terminal.column, players, size);

        //Sleep
        usleep(50000);
    }

    printf("\033[?25h");
    disable_raw_mode();
    return 0;
}
