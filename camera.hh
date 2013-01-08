#ifndef _CAMERA_HH
#define _CAMERA_HH

#include <vector>
#include <tr1/memory>
using namespace std;


class CameraImpl {
protected:
    int turn_;
    float ex_, ey_, ez_, cx_, cy_, cz_, ux_, uy_, uz_;
    float dex_, dey_, dez_, dcx_, dcy_, dcz_, dux_, duy_, duz_;

public:
    virtual ~CameraImpl() {}

    void set(float* ex, float* ey, float* ez,
             float* cx, float* cy, float* cz,
             float* ux, float* uy, float* uz);

    bool isEnd() { return turn_ > 600; }
    void reset() { turn_ = 0; }

    virtual void set_() = 0;

    void setAim(float ex, float ey, float ez,
                float cx, float cy, float cz,
                float ux, float uy, float uz, int times);
    void goAim();
};


class NormalCamera : public CameraImpl {
public:
    void set_();
};


class UpRollCamera : public CameraImpl {
public:
    void set_();
};


class PlayerCamera : public CameraImpl {
public:
    void set_();
};


class EnemyCamera : public CameraImpl {
public:
    void set_();
};


class PlayerToEnemyCamera : public CameraImpl {
public:
    void set_();
};


class RandomCamera : public CameraImpl {
public:
    void set_();
};


class SideCamera : public CameraImpl {
public:
    void set_();
};


class PlayerUpCamera : public CameraImpl {
public:
    void set_();
};


class GrazeUpRollCamera : public CameraImpl {
public:
    void set_();
};


class RandomLineCamera : public CameraImpl {
public:
    void set_();
};


class Camera {
private:
    tr1::shared_ptr<CameraImpl> camera_;
    vector< tr1::shared_ptr<CameraImpl> > cameras_;

    float ex_, ey_, ez_, cx_, cy_, cz_, ux_, uy_, uz_;

public:
    Camera();
    
    void set();
};
	
#endif   //  _CAMERA_HH
