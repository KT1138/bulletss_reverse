#include <axis.hh>


string Axis::getName() const
{
        if (axis_ == NONE) return "NONE";
        else if (axis_ == UP) return "UP";
        else if (axis_ == UPRIGHT) return "UPRIGHT";
        else if (axis_ == RIGHT) return "RIGHT";
        else if (axis_ == DOWNRIGHT) return "DOWNRIGHT";
        else if (axis_ == DOWN) return "DOWN";
        else if (axis_ == DOWNLEFT) return "DOWNLEFT";
        else if (axis_ == LEFT) return "LEFT";
        else if (axis_ == UPLEFT) return "UPLEFT";
        else return "UNKNOWN";
}

int Axis::getSmallAxisCode() const
{
    if (axis_ == NONE) return 0;
    else if (axis_ == UP) return 1;
    else if (axis_ == UPRIGHT) return 2;
    else if (axis_ == RIGHT) return 3;
    else if (axis_ == DOWNRIGHT) return 4;
    else if (axis_ == DOWN) return 5;
    else if (axis_ == DOWNLEFT) return 6;
    else if (axis_ == LEFT) return 7;
    else if (axis_ == UPLEFT) return 8;
    else return 0;
}

int Axis::createFromSmallCode(int code)
{
    if (code == 0) return NONE;
    else if (code == 1) return UP;
    else if (code == 2) return UPRIGHT;
    else if (code == 3) return RIGHT;
    else if (code == 4) return DOWNRIGHT;
    else if (code == 5) return DOWN;
    else if (code == 6) return DOWNLEFT;
    else if (code == 7) return LEFT;
    else if (code == 8) return UPLEFT;
    else return NONE;
}
