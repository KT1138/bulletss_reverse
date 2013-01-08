#ifndef _CHARACTOR_HH
#define _CHARACTOR_HH

#include <cmath>
#include <vector>
#include <tr1/memory>
#include <bulletml.h>
using namespace std;


class BulletMLRunner;
class PadInput;


class Charactor {
public:
    enum Type { BOSS, BULLET, SHOT1, SHOT2, PLAYER };

protected:
    float x_, y_, sx_, sy_;
    float a_, v_;
    Type type_;
    int turn_;
    bool alive_;

public:
    Charactor(float x, float y, float a, float v, Type type)
        : x_(x), y_(y), a_(a), v_(v), sx_(v * sin(a)), sy_(-v * cos(a)), type_(type), turn_(0), alive_(true) {}
    virtual ~Charactor() {}
    
    void move();
    void draw();

    float x() const { return x_; }
    float y() const { return y_; }
    float sx() const { return sx_; }
    float sy() const { return sy_; }    
    
    bool alive() const { return alive_; }
    void kill() { alive_ = false; }

    int turn() const { return turn_; }
};


class Shot : public Charactor {
public:
    Shot(float x, float y, float a, float v, Type type)
        : Charactor(x, y, a, v, type) {}
};



class Bullet : public Shot , public tr1::enable_shared_from_this<Bullet>{
public:
    static tr1::shared_ptr<Bullet> now;

private:
    BulletMLRunner* runner_;
    int generation_;

public:
	Bullet(BulletMLRunner* runner, float x, float y,
           float a, float v, Type type, int gen)
            : Shot(x, y, a, v, type), runner_(runner),  generation_(gen) {}	

    tr1::shared_ptr<Bullet> returnSharedThis() { return shared_from_this(); }
    void move();

    bool isEnd() const { return BulletMLRunner_isEnd(runner_); }

    float angle() const { return a_; }
    float velocity() const { return v_; }

    void setCartesian();
    void setPolar();

    void setSX(float sx) { sx_ = sx; }
    void setSY(float sy) { sy_ = sy; }
    void setAngle(float a) { a_ = a; }
    void setVelocity(float v) { v_ = v; }

    int generation() const { return generation_; }

private:
    Bullet(const Bullet&);
    Bullet& operator=(const Bullet&);
};


class Target : public Charactor {
private:
    tr1::shared_ptr<PadInput> input_;

public:
    Target(float x, float y, float a, float v, Type type)
        : Charactor(x, y, a, v, type) {}

    void setInput(tr1::shared_ptr<PadInput> input) { input_ = input; }

    void move();
};

vector<char> ftoa(double f);

#endif //  _CHARACTOR_HH
