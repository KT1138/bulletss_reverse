#include <cstdio>
#include <gl.h>
#include <bulletml.h>
#include <axis.hh>
#include <charactor.hh>
#include <mymath.hh>
#include <padinput.hh>


void Charactor::move()
{
    x_ += sx_;
    y_ += sy_;
    ++turn_;
    if (( x_ < 0 || y_ < 0 || x_ > 300 || y_ > 400 ) &&
        type_ != BOSS && type_ != PLAYER ) kill();
}

void Charactor::draw()
{
    switch (type_) {
    case BOSS: {
        static int size = 5;

        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(turn_ * 5, 0, 0, 1);
        glRotatef(turn_ * 3, 0, 1, 0);

        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-size, -size, 0);
        glVertex3f(size, -size, 0);
        glVertex3f(size, size, 0);
        glVertex3f(-size, size, 0);
        glEnd();
        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-size, 0, -size);
        glVertex3f(size, 0, -size);
        glVertex3f(size, 0, size);
        glVertex3f(-size, 0, size);
        glEnd();
        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(0, -size, -size);
        glVertex3f(0, size, -size);
        glVertex3f(0, size, size);
        glVertex3f(0, -size, size);
        glEnd();

        glPopMatrix();

        break;
    }
    case SHOT1: {
        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(rtod(a_), 0, 0, 1);
        glRotatef(turn_ * 5, 0, 1, 0);

        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-2, 3, 0);
        glVertex3f(2, 3, 0);
        glVertex3f(0, -3, 0);
        glEnd();

        glPopMatrix();

        break;
    }
    case SHOT2: {
        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(rtod(a_), 0, 0, 1);
        glRotatef(-turn_ * 5, 0, 1, 0);

        glBegin(GL_TRIANGLE_STRIP);
        glColor3f(1, 1, 1);
        glVertex3f(-2, 3, 0);
        glVertex3f(2, 3, 0);
        glVertex3f(0, -3, 0);
        glEnd();

        glPopMatrix();

        break;
    }
    case BULLET: {
        static int size = 3;
        
        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(turn_ * 5, 0, 0, 1);
        glRotatef(turn_ * 3, 0, 1, 0);

        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-size, -size, 0);
        glVertex3f(size, -size, 0);
        glVertex3f(-size, size, 0);
        glVertex3f(size, size, 0);
        glEnd();

        glPopMatrix();

        break;
    }
    case PLAYER: {
        static const int size = 5;
        static const float sqrt3 = 1.732;

        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(-turn_ * 5, 0, 0, 1);
        glRotatef(turn_*3, 0, 1, 0);

        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-size, size / sqrt3, 0);
        glVertex3f(size, size / sqrt3, 0);
        glVertex3f(0, -2 * size / sqrt3, 0);
        glEnd();

        glPopMatrix();

        glPushMatrix();
        glTranslatef(x_ + 170, y_ + 40, 0);
        glRotatef(turn_ * 5, 0, 0, 1);
        glRotatef(-turn_ * 3, 0, 1, 0);

        glBegin(GL_LINE_LOOP);
        glColor3f(1, 1, 1);
        glVertex3f(-size, -size / sqrt3, 0);
        glVertex3f(size, -size / sqrt3, 0);
        glVertex3f(0, 2* size / sqrt3, 0);
        glEnd();

        glPopMatrix();

        break;
    }
    default:
        break;
    }
}

tr1::shared_ptr<Bullet> Bullet::now;

void Bullet::move()
{
    now = returnSharedThis();

    if (!BulletMLRunner_isEnd(runner_)) {
        BulletMLRunner_run(runner_);
    }

    Shot::move();
}

void Bullet::setCartesian()
{
    sx_ = v_ * sin(a_);
    sy_ = -v_ * cos(a_);
}

void Bullet::setPolar()
{
    a_ = atan2(sx_, -sy_);
    v_ = sqrt(sx_ * sx_ + sy_ * sy_);
}

void Target::move()
{
    ++turn_;

    tr1::shared_ptr<Axis> axis = input_->getAxis();
	
    float base = 2;
    float cross = 2 / sqrt(2.0);
    
    if (axis->getAxisCode() == Axis::UP) y_ -= base;
    else if (axis->getAxisCode() == Axis::RIGHT) x_ += base;
    else if (axis->getAxisCode() == Axis::DOWN) y_ += base;
    else if (axis->getAxisCode() == Axis::LEFT) x_ -= base;
    else if (axis->getAxisCode() == Axis::UPRIGHT) {
        x_ += cross;
        y_ -= cross;
    }
    else if (axis->getAxisCode() == Axis::DOWNRIGHT) {
        x_ += cross;
        y_ += cross;
    }
    else if (axis->getAxisCode() == Axis::DOWNLEFT) {
        x_ -= cross;
        y_ += cross;
    }
    else if (axis->getAxisCode() == Axis::UPLEFT) {
        x_ -= cross;
        y_ -= cross;
    }
}

vector<char> ftoa(double f) {
    char tmp[256];
    int len = sprintf(&tmp[0], "%f", f);

    vector<char> buf;
    for ( int i = 0; i < len; ++i )
        buf.push_back(tmp[i]);
            
    return buf;
}
