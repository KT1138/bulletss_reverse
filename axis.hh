#ifndef _AXIS_HH
#define _AXIS_HH

#include <string>
using namespace std;


class Axis {
public:
    enum {
        NONE = 0,
        UP = 1,
        UPRIGHT = 5,
        RIGHT = 4,
        DOWNRIGHT = 6,
        DOWN = 2,
        DOWNLEFT = 10,
        LEFT = 8,
        UPLEFT = 9
    };

private:
    int axis_;

public:
    Axis() : axis_(NONE) {}
    explicit Axis(int axis) : axis_(axis) {}

    void add(int axis) { axis_ |= axis; }
    void add(const Axis& axis) { add(axis.axis_); }

    string getName() const;

    int getAxisCode() const { return axis_; };
    int getSmallAxisCode() const;
    static int createFromSmallCode(int code);

    bool eq(const Axis& rhs) const { return axis_ == rhs.axis_; };
    bool eq(int rhs) const { return axis_ == rhs; };

    bool isRight() const { return (axis_ & RIGHT) != 0; }
    bool isLeft() const { return (axis_ & LEFT) != 0; }
    bool isDown() const { return (axis_ & DOWN) != 0; }
    bool isUp() const { return (axis_ & UP) != 0; }
    bool isXAxis() const { return isRight() || isLeft(); }
    bool isYAxis() const { return isDown() || isUp(); }
};

#endif   // _AXIS_HH
