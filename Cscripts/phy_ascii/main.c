#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <stdbool.h>
#include <math.h>

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
    struct pos pastpos[3];
    int state;
};


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
        struct entity *obj = &object[z];

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
                screen[ty][tx] = '~';
            }
        }
        int dx = (int)obj->position.x;
        int dy = (int)obj->position.y;
        if (dx >= 0 && dx < width && dy >= 0 && dy < height) {
            if (obj->state == 1) {
                screen[dy][dx] = 'o';
            }else if (obj->state == 2) {
                screen[dy][dx] = '0';
            }else if (obj->state == 3) {
                screen[dy][dx] = '@';
            }
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

        if (obj->velocity.vy != 0) {
            float ratio = obj->velocity.vx / obj->velocity.vy;
            if (ratio <= 0.5) obj->state = 1;
            else if (ratio <= 1.0) obj->state = 2;
            else obj->state = 3;
        }
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

        if (obj->position.x <= 2) {
            obj->position.x = 2;
            obj->velocity.vx = -obj->velocity.vx * restitution;
        } else if (obj->position.x >= width - 2) {
            obj->position.x = width - 2;
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


            if (distance_squared < 2.25 && distance_squared > 0.001f) {
                float distance = sqrtf(distance_squared);

                // Normalize collision vector
                float nx = dx / distance;
                float ny = dy / distance;

                // Separate the balls (push apart)
                float overlap = 1.5f - distance;  // 1.5 is your collision radius
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

void handle_input(char c, struct entity *object, int size, int *running, float *gravity, float *restitution) {
    switch (c) {
        case 'q':
            *running = 1;
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
        case 'g':
            *gravity+=1;
            break;
        case 'v':
            *gravity-=1;
            break;
        case 'f':
            *restitution+=.1;
            break;
        case 'c':
            *restitution-=.1;
            break;
    }
}


int main() {
    enable_raw_mode();
    float gravity = 30.0f;
    float restitution = 0.7f;
    float dt = 0.05f;
    struct entity ball[10];
    int size=sizeof(ball) / sizeof(*ball);


    for (int z=0; z<size; z++) {
        ball[z].position.x=(z+1)*2;
        ball[z].position.y=(z+1)*2;

        ball[z].velocity.vx=z;
        ball[z].velocity.vy=0;
    }

    int running=0;

    // Get the terminal size
    struct winsize sz;

    printf("\033[2J"); // Clear terminal
    printf("\033[?25l");

    while (running == 0) {
        //Physics
        phy_update(ball, size,  gravity, dt);

        //Input
        char c;
        while (read(STDIN_FILENO, &c, 1) > 0) {
            handle_input(c, ball, size, &running, &gravity, &restitution);
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
