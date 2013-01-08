#ifndef _BULLETSS_HH
#define _BULLETSS_HH

#include <vector>
#include <tr1/array>
#include <tr1/memory>
#include <bulletml.h>
using namespace std;


class Bullet;
class BulletMLRunner;
class BulletMLState;
class Camera;
class Charactor;
class CpuInput;
class Target;


extern "C" {
    double getBulletDirection_(BulletMLRunner* r);
    double getAimDirection_(BulletMLRunner* r);
    double getBulletSpeed_(BulletMLRunner* r); 
    double getDefaultSpeed_(BulletMLRunner* r);
    double getRank_(BulletMLRunner* r);
    void createSimpleBullet_(BulletMLRunner* r, double d, double s);
    void createBullet_(BulletMLRunner* r, BulletMLState* state, double d, double s);
    int getTurn_(BulletMLRunner* r);
    void doVanish_(BulletMLRunner* r);
    void doChangeDirection_(BulletMLRunner* r, double d);
    void doChangeSpeed_(BulletMLRunner* r, double s);
    void doAccelX_(BulletMLRunner* r, double sx);
    void doAccelY_(BulletMLRunner* r, double sy);
    double getBulletSpeedX_(BulletMLRunner* r);
    double getBulletSpeedY_(BulletMLRunner* r);
}

class BulletSS : public tr1::enable_shared_from_this<BulletSS> {
public:
    static tr1::shared_ptr<BulletSS> obj;
	
private:
    enum {
        CHAR_NUM = 1000
    };

    tr1::shared_ptr<Target> target_;
    tr1::shared_ptr<Bullet> topBullet_;
    tr1::shared_ptr<CpuInput> input_;

    tr1::array<tr1::shared_ptr<Charactor>, CHAR_NUM> charactors_;

    int turn_;
    bool end_;

    tr1::shared_ptr<Camera> camera_;

    vector<string> xmls_;

public:
    int shotNum_;

    float shotX_[CHAR_NUM];
    float shotY_[CHAR_NUM];
    float shotSX_[CHAR_NUM];
    float shotSY_[CHAR_NUM];

public:
    tr1::shared_ptr<BulletSS> returnSharedThis() { return shared_from_this(); }
    void registFunctions(BulletMLRunner* runner);
    void initSDLOpenGL();
    void procEndInput();
    void drawField();
    string getFileExt(const string& s);
    void initXmls(string runFile);
    int run(int argc, char* argv[]);

    tr1::shared_ptr<Target> target() const { return target_; }
    tr1::shared_ptr<Bullet> topBullet() const { return topBullet_; }

    void addShot(float a, float v);
    void addBullet(BulletMLState* s, float a, float v);;

    int turn() const { return turn_; }
    
    void getBullets(int& len, float* x, float* y, float* sx, float* sy);
};

#endif   //  _BULLETSS_HH
