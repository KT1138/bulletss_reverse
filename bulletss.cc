#include <iostream>
#include <dirent.h>
#include <SDL.h>
#include <SDL_events.h>
#include <SDL_timer.h>
#include <SDL_video.h>
#include <gl.h>
#include <camera.hh>
#include <charactor.hh>
#include <cpuinput.hh>
#include <bulletss.hh>
#include <mesaglu.hh>
#include <mymath.hh>
#include <padinput.hh>
#include <bulletml/bulletmlparser.h>
#include <bulletml/bulletmlparser-tinyxml.h>


static const float VEL_SS_SDM_RATIO = 62.0 / 100;
static const float VEL_SDM_SS_RATIO = 100.0 / 62;

double getBulletDirection_(BulletMLRunner* r) {
    return rtod(Bullet::now->angle());
}
double getAimDirection_(BulletMLRunner* r) {
    tr1::shared_ptr<Bullet> b = Bullet::now;
    tr1::shared_ptr<Target> t = BulletSS::obj->target();
    return 180-rtod(atan2(t->x() - b->x(), t->y() - b->y()));
}
double getBulletSpeed_(BulletMLRunner* r) {
    return Bullet::now->velocity() * VEL_SS_SDM_RATIO;
}
double getDefaultSpeed_(BulletMLRunner* r) {
    return 1;
}
double getRank_(BulletMLRunner* r) {
    return 0.5;
}
void createSimpleBullet_(BulletMLRunner* r, double d, double s) {
    BulletSS::obj->addShot(dtor(d), s * VEL_SDM_SS_RATIO);
}
void createBullet_(BulletMLRunner* r, BulletMLState* state,
                   double d, double s) {
    BulletSS::obj->addBullet(state, dtor(d), s * VEL_SDM_SS_RATIO);
}

int getTurn_(BulletMLRunner* r) {
    return BulletSS::obj->turn();
}
void doVanish_(BulletMLRunner* r) {
    Bullet::now->kill();
}
void doChangeDirection_(BulletMLRunner* r, double d) {
    Bullet::now->setAngle(dtor(d));
    Bullet::now->setCartesian();
}
void doChangeSpeed_(BulletMLRunner* r, double s) {
    Bullet::now->setVelocity(s * VEL_SDM_SS_RATIO);
    Bullet::now->setCartesian();
}
void doAccelX_(BulletMLRunner* r, double sx) {
    Bullet::now->setSX(sx * VEL_SDM_SS_RATIO);
    Bullet::now->setPolar();
}
void doAccelY_(BulletMLRunner* r, double sy) {
    Bullet::now->setSY(sy * VEL_SDM_SS_RATIO);
    Bullet::now->setPolar();
}
double getBulletSpeedX_(BulletMLRunner* r) {
    return Bullet::now->sx() * VEL_SS_SDM_RATIO;
}
double getBulletSpeedY_(BulletMLRunner* r) {
    return Bullet::now->sy() * VEL_SS_SDM_RATIO;
}

tr1::shared_ptr<BulletSS> BulletSS::obj;

void BulletSS::registFunctions(BulletMLRunner* runner)
{
    BulletMLRunner_set_getBulletDirection(runner, &getBulletDirection_);
    BulletMLRunner_set_getAimDirection(runner, &getAimDirection_);
    BulletMLRunner_set_getBulletSpeed(runner, &getBulletSpeed_);
    BulletMLRunner_set_getDefaultSpeed(runner, &getDefaultSpeed_);
    BulletMLRunner_set_getRank(runner, &getRank_);
    BulletMLRunner_set_createSimpleBullet(runner, &createSimpleBullet_);
    BulletMLRunner_set_createBullet(runner, &createBullet_);
    BulletMLRunner_set_getTurn(runner, &getTurn_);
    BulletMLRunner_set_doVanish(runner, &doVanish_);

    BulletMLRunner_set_doChangeDirection(runner, &doChangeDirection_);
    BulletMLRunner_set_doChangeSpeed(runner, &doChangeSpeed_);
    BulletMLRunner_set_doAccelX(runner, &doAccelX_);
    BulletMLRunner_set_doAccelY(runner, &doAccelY_);
    BulletMLRunner_set_getBulletSpeedX(runner, &getBulletSpeedX_);
    BulletMLRunner_set_getBulletSpeedY(runner, &getBulletSpeedY_);
}

void BulletSS::initSDLOpenGL()
{
    int w, h, bpp;

    SDL_Init(SDL_INIT_VIDEO);

    w = 640;
    h = 480;
    const SDL_VideoInfo* info = SDL_GetVideoInfo();
    bpp = info->vfmt->BitsPerPixel;

    SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 5 );  
    SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 5 );
    SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 5 );  
    SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 16 );
    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

    SDL_SetVideoMode(w, h, bpp, SDL_OPENGL/*|SDL_FULLSCREEN*/);

    glClearColor(0, 0, 0, 0);
    glViewport(0, 0, w, h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    float asp = static_cast<float>(w) / h;
    gluPerspective(45.0, asp, 0.1, 1000);
}

void BulletSS::procEndInput()
{
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_QUIT) {
            end_ = true;
        }
        else if (e.type == SDL_KEYDOWN) {
            if (e.key.keysym.sym == SDLK_ESCAPE) {
                end_ = true;
            }
        }
    }
}

void BulletSS::drawField() {
    glBegin(GL_LINE_LOOP);
    glColor3f(1, 1, 1);
    glVertex3f(170, 40, 10);
    glVertex3f(170, 440, 10);
    glVertex3f(470, 440, 10);
    glVertex3f(470, 40, 10);
    glEnd();

    glBegin(GL_LINE_LOOP);
    glColor3f(1, 1, 1);
    glVertex3f(170, 40, -20);
    glVertex3f(170, 440, -20);
    glVertex3f(470, 440, -20);
    glVertex3f(470, 40, -20);
    glEnd();

    glBegin(GL_LINES);
    glVertex3f(170, 40, 10);
    glVertex3f(170, 40, -20);
    glVertex3f(170, 440, 10);
    glVertex3f(170, 440, -20);
    glVertex3f(470, 440, 10);
    glVertex3f(470, 440, -20);
    glVertex3f(470, 40, 10);
    glVertex3f(470, 40, -20);
    glEnd();
}

string BulletSS::getFileExt(const string &s) {
    size_t i = s.rfind('.', s.length());
    if (i != string::npos) {
        return (s.substr(i+1, s.length() - i));
    }   
    return ("");
}

void BulletSS::initXmls(string runFile) {
    if (getFileExt(runFile) == "xml") {
        xmls_.push_back(runFile);
    }
    else {
        DIR* dir = opendir(runFile.c_str());
        struct dirent* dp;
        while ((dp = readdir(dir)) != 0) {
            string name = dp->d_name;
            if (getFileExt(name) == "xml") {
                xmls_.push_back(runFile + name);
            }
        }
        closedir(dir);
    }
}

int BulletSS::run(int argc, char* args[])
{
    obj = returnSharedThis();

    string runFile = "bosses.d/";
    if (argc > 1) {
        runFile = string(args[1]);
    }
    initXmls(runFile);

    initSDLOpenGL();

    camera_.reset(new Camera());

    end_ = false;

    target_.reset(new Target(150, 300, 0, 0, Charactor::PLAYER));
    input_.reset(new CpuInput(target_));
    target_->setInput(input_);

    Cpu_initAxis();

    while (!end_) {
        string xml = xmls_[rnd(xmls_.size())];

#ifdef linux

        cout << xml << endl;

#endif   // linux
 

        BulletMLParserTinyXML* parser =
            BulletMLParserTinyXML_new(const_cast<char*>(xml.c_str()));
        BulletMLParserTinyXML_parse(parser);

        BulletMLRunner* runner =
            BulletMLRunner_new_parser(parser);
        registFunctions(runner);

        for ( int i = 0; i < charactors_.size(); ++i ) {
            charactors_[i].reset();
        }

        topBullet_.reset(new Bullet(runner, 150, 100, 0, 0, Charactor::BOSS, -1));
        charactors_[0] = topBullet_;

        turn_ = 0;
        int endTurn_ = 0;

        while (endTurn_ < 100 && !end_) {
            procEndInput();

            if (topBullet_->isEnd()) { 
                ++endTurn_;
            }

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            camera_->set();

            target_->move();
            target_->draw();
 
            shotNum_ = 0;
        
            for ( int i = 0; i < charactors_.size(); ++i ) {
                tr1::shared_ptr<Bullet> bullet =
                    tr1::dynamic_pointer_cast<Bullet>(charactors_[i]);
                if (charactors_[i]) {
                    if (bullet)
                       bullet->move();
                   else
                        charactors_[i]->move();
                    if (charactors_[i]->alive()) {
                        charactors_[i]->draw();

                        shotX_[shotNum_] = charactors_[i]->x();
                        shotY_[shotNum_] = charactors_[i]->y();
                        shotSX_[shotNum_] = charactors_[i]->sx();
                        shotSY_[shotNum_] = charactors_[i]->sy();
                        ++shotNum_;
                    }
                    else 
                        charactors_[i].reset();
                }
            }

            drawField();
    
            SDL_GL_SwapBuffers();
            SDL_Delay(16);

            ++turn_;
        }

        BulletMLRunner_delete(runner);
        BulletMLParserTinyXML_delete(parser);
    }

    SDL_Quit();

    return 0;
}

void BulletSS::addShot(float a, float v) {
    for ( int i = 0; i < charactors_.size(); ++i ) {
        if (!charactors_[i]) {
            if (Bullet::now->generation() & 1) {
                charactors_[i].reset(new Shot(Bullet::now->x(), Bullet::now->y(),
                                              a, v, Charactor::SHOT1));
            }
            else {
                charactors_[i].reset(new Shot(Bullet::now->x(), Bullet::now->y(),
                                              a, v, Charactor::SHOT2));
            }
            input_->registShot(charactors_[i]->x(), charactors_[i]->y(),
                               charactors_[i]->sx(), charactors_[i]->sy());
            return;
        }
    }
}

void BulletSS::addBullet(BulletMLState* s, float a, float v) {
    for ( int i = 0; i < charactors_.size(); ++i ) {
        if (!charactors_[i]) {
            BulletMLRunner* runner =
                BulletMLRunner_new_state(s);
            registFunctions(runner);
            charactors_[i].reset(new Bullet(runner, Bullet::now->x(), Bullet::now->y(),
                                            a, v, Charactor::BULLET,
                                            Bullet::now->generation() + 1));
            input_->registShot(charactors_[i]->x(), charactors_[i]->y(), 
                               charactors_[i]->sx(), charactors_[i]->sy());
            return;
        }
    }
}

void BulletSS::getBullets(int& len, float* x, float* y, float* sx, float* sy)
{
    len = shotNum_;
    x = shotX_;
    y = shotY_;
    sx = shotSX_;
    sy = shotSY_;
}


#ifdef linux

int main(int argc, char* argv[])
{
    tr1::shared_ptr<BulletSS> bulletss(new BulletSS());
    return bulletss->run(argc, argv);
}

#endif   // linux

#ifdef _WIN32

extern "C" int doit(int argc, char* argv[])
{
    BulletSS bulletss;
    return bulletss.run(argc, argv);
}

#endif   //  _WIN32
