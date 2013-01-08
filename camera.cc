#include <cassert>
#include <cmath>
#include <gl.h>
#include <mesaglu.hh>
#include <bulletss.hh>
#include <camera.hh>
#include <charactor.hh>
#include <mymath.hh>
using namespace std;


Camera::Camera()
{
    cameras_.push_back(tr1::shared_ptr<NormalCamera>(new NormalCamera()));
    cameras_.push_back(tr1::shared_ptr<UpRollCamera>(new UpRollCamera()));
    cameras_.push_back(tr1::shared_ptr<PlayerCamera>(new PlayerCamera()));
    cameras_.push_back(tr1::shared_ptr<EnemyCamera>(new EnemyCamera()));
    cameras_.push_back(tr1::shared_ptr<PlayerToEnemyCamera>(new PlayerToEnemyCamera()));
    cameras_.push_back(tr1::shared_ptr<RandomCamera>(new RandomCamera()));
    cameras_.push_back(tr1::shared_ptr<SideCamera>(new SideCamera()));
    cameras_.push_back(tr1::shared_ptr<PlayerUpCamera>(new PlayerUpCamera()));
    cameras_.push_back(tr1::shared_ptr<GrazeUpRollCamera>(new GrazeUpRollCamera()));
    cameras_.push_back(tr1::shared_ptr<RandomLineCamera>(new RandomLineCamera()));

    camera_ = cameras_[rnd(cameras_.size())];
    camera_->reset();

    ex_ = 320;
    ey_ = 240;
    ez_ = -500;
    cx_ = 320;
    cy_ = 240;
    cz_ = 0;
    ux_ = 0;
    uy_ = -1;
    uz_ = 0;
}

void Camera::set()
{
    camera_->set(&ex_, &ey_, &ez_, &cx_, &cy_, &cz_, &ux_, &uy_, &uz_);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(ex_, ey_, ez_, cx_, cy_, cz_, ux_, uy_, uz_);

    if (camera_->isEnd()) {
        camera_ = cameras_[rnd(cameras_.size())];
        camera_->reset();
    }
}

void CameraImpl::set(float* ex, float* ey, float* ez,
                     float* cx, float* cy, float* cz,
                     float* ux, float* uy, float* uz)
{
    ex_ = *ex; ey_ = *ey; ez_ = *ez;
    cx_ = *cx; cy_ = *cy; cz_ = *cz;
    ux_ = *ux; uy_ = *uy; uz_ = *uz;
    
    set_();

    *ex = ex_; *ey = ey_; *ez = ez_;
    *cx = cx_; *cy = cy_; *cz = cz_;
    *ux = ux_; *uy = uy_; *uz = uz_;

    ++turn_;
}

void CameraImpl::setAim(float ex, float ey, float ez,
                        float cx, float cy, float cz,
                        float ux, float uy, float uz, int times)
{
    assert(times > 0);

    dex_ = (ex - ex_)  / times;
    dey_ = (ey - ey_)  / times;
    dez_ = (ez - ez_)  / times;
    dcx_ = (cx - cx_)  / times;
    dcy_ = (cy - cy_)  / times;
    dcz_ = (cz - cz_)  / times;
    dux_ = (ux - ux_)  / times;
    duy_ = (uy - uy_)  / times;
    duz_ = (uz - uz_)  / times;
}

void CameraImpl::goAim()
{
    ex_ += dex_;
    ey_ += dey_;
    ez_ += dez_;
    cx_ += dcx_;
    cy_ += dcy_;
    cz_ += dcz_;
    ux_ += dux_;
    uy_ += duy_;
    uz_ += duz_;
}

void NormalCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 240, -500, 320, 240, 0, 0, -1, 0, 100);
    }
    else if (turn_ < 100) {
        goAim();
    }
    else {
    }
}

void UpRollCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 240, -500, 320, 240, 0, 0, -1, 0, 100);
    }
    else if (turn_ < 100) {
        goAim();
    }
    else {
        float t = (turn_ - 100) * 0.01;
        ux_ = sin(t);
        uy_ = -cos(t);
    }
}

void PlayerCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 480, -20, 320, 240, 0, 0, -20, -240, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
    }
}

void EnemyCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 0, -20, 320, 240, 0, 0, 20, -240, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
    }
}

void PlayerToEnemyCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 480, -20, 320, 240, 0, 0, -20, -240, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
        tr1::shared_ptr<Charactor> p = BulletSS::obj->target();
        tr1::shared_ptr<Charactor> e = BulletSS::obj->topBullet();
        setAim(p->x()+170, p->y()+40, -30,
               e->x()+170, e->y()+40, 0, 0, -30, -100, 5);
        goAim();
    }
}

void RandomCamera::set_()
{
    if (turn_ % 100 == 0) {
        setAim(rnd(640), rnd(480), rnd(50)-25,
               320, 240, 0, rnd(3)-1, rnd(3)-1, rnd(3)-1, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
    }
}

void SideCamera::set_()
{
    if (turn_ == 0) {
        setAim(650, 240, -50, 320, 240, 0, 50, 0, -330, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
    }
}

void PlayerUpCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 240, -500, 320, 240, 0, 0, -1, 0, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
        tr1::shared_ptr<Charactor> p = BulletSS::obj->target();
        setAim(p->x()+170, p->y()+90, -100,
               p->x()+170, p->y()+40, 0,
               0, -10, -5, 5);
        goAim();
    }
}

void GrazeUpRollCamera::set_()
{
    if (turn_ == 0) {
        setAim(320, 480, 240, 320, 240, 0, 0, -1, 1, 100);
    }
    else if(turn_ < 100) {
        goAim();
    }
    else {
        float t = (turn_ - 100) * -0.01;
        ex_ = 320 + sin(t) * 240;
        ey_ = 240 + cos(t) * 240;
        ux_ = -sin(t);
        uy_ = -cos(t);
    }
}

void RandomLineCamera::set_()
{
    if (turn_ == 0) {
        dex_ = rnd(3)-1;
        dey_ = rnd(3)-1;
        dez_ = rnd(3)-1;
        dcx_ = 0;
        dcy_ = 0;
        dcz_ = 0;
        dux_ = 0;
        duy_ = 0;
        duz_ = 0;
        cx_ = 320;
        cy_ = 240;
        cz_ = 0;
    }
    goAim();
}
