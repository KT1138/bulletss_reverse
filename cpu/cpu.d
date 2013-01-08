/**
 * $Id: cpuutil.h,v 1.2 2003/09/16 08:25:57 i Exp $
 *
 * Copyright (C) shinichiro.h <s31552@mail.ecc.u-tokyo.ac.jp>
 *  http://user.ecc.u-tokyo.ac.jp/~s31552/wp/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
/**
 * $Id: cpuutil.cc,v 1.2 2003/09/16 08:25:57 i Exp $
 *
 * Copyright (C) shinichiro.h <s31552@mail.ecc.u-tokyo.ac.jp>
 *  http://user.ecc.u-tokyo.ac.jp/~s31552/wp/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

/**
 * $Id: cpu.d 2012/05/20 12:02:02 i Exp $
 *
 * Copyright (C) Koichi Yazawa <kyazawa12@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


import std.c.stdio;
import std.c.stdlib;

import chairman;
import cpuinfo;
import pair;
import util;
import deque;


class CpuInputBase {
protected:
  alias Pair!(Point) PosSpd;
  alias Deque!(PosSpd) PosSpds;

protected:
  int lastTurn_;
  int prevIndex_;

protected:
  int axis_;
  bool decision_;
  int evaluations_[9];
  string name_;
  static Deque!(Point)* axis2vec;
  static Point upper;

protected:
  static CpuInfo info_;

public:
  // 静的コンストラクタの代わり
  static initAxis()
  {
    upper = new Point(info_.getPlayerMaxPnt());

    axis2vec = Deque!(Point).createDeque(1, Point.classinfo.init.length);

    Point p0 = new Point(0, 0);
    Deque!(Point).pushBack(axis2vec, &p0);
    Point p1 = new Point(0, -1);
    Deque!(Point).pushBack(axis2vec, &p1);
    Point p2 = new Point(1/SQRT_TWO, -1/SQRT_TWO);
    Deque!(Point).pushBack(axis2vec, &p2);
    Point p3 = new Point(1, 0);
    Deque!(Point).pushBack(axis2vec, &p3);
    Point p4 = new Point(1/SQRT_TWO, 1/SQRT_TWO);
    Deque!(Point).pushBack(axis2vec, &p4);
    Point p5 = new Point(0, 1);
    Deque!(Point).pushBack(axis2vec, &p5);
    Point p6 = new Point(-1/SQRT_TWO, 1/SQRT_TWO);
    Deque!(Point).pushBack(axis2vec, &p6);
    Point p7 = new Point(-1, 0);
    Deque!(Point).pushBack(axis2vec, &p7);
    Point p8 = new Point(-1/SQRT_TWO, -1/SQRT_TWO); 
    Deque!(Point).pushBack(axis2vec, &p8);
  
  }
  this()
  {
    lastTurn_ = -1;
    axis_ = 0;
  }

  new(size_t sz)
  {
    void* p;

    p = malloc(sz);
    if (!p) {
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    return p;
  }
  delete(void* p)
  {
    if (p) {
      free(p);
    }
  }  

  int getAxis()
  {
    update();
    return axis_;
  }

  bool getButton(int id)
  {
    update();
    return decision_ && id == 1;
  }

  static CpuInputBase getDefaultCpu()
  {
    return new ChairmanCpu();
  }

  static void setCpuInfomation(CpuInfo info) { info_ = info; }

public:
  abstract void registShot(float, float, float, float);

  int getAxisEvaluation(int axis)
  {
    return evaluations_[axis];
  }

  int getConfidence() const { return 100; }

  void report() const {}


public:
  void update() {
    if (info_.getTurn() == lastTurn_) return;

    lastTurn_ = info_.getTurn();

    initEvaluation();

    calc();
  }

public:
  const string name() const { return name_; }

protected:
  abstract void calc();

protected:
  void message(const string msg)
  {
    printf("%s: %s\n", name(), msg);
  }

protected:
  void initEvaluation() {
    for (int i = 0; i < 9; i++) {
      evaluations_[i] = 0;
    }
  }

protected:
  Point getMovedPoint(Point pnt, int axis) {
    double spf = info_.getSpf();

    double base = info_.getPlayerSpd() * spf;
    double cross = base / SQRT_TWO;

    Point ret;

    if (axis == 0) ret = new Point(pnt.x, pnt.y);
    else if (axis == 1) {
      ret = new Point(pnt.x, pnt.y - base);
    }
    else if (axis == 2) { 
      ret = new Point(pnt.x + cross, pnt.y - cross);
    }
    else if (axis == 3) { 
      ret = new Point(pnt.x + base, pnt.y);
    }
    else if (axis == 4) { 
      ret = new Point(pnt.x + cross, pnt.y + cross);
    }
    else if (axis == 5) {
      ret = new Point(pnt.x, pnt.y + base);
    }
    else if (axis == 6) {
      ret = new Point(pnt.x - cross, pnt.y + cross);
    }
    else if (axis == 7) {
      ret = new Point(pnt.x - base, pnt.y);
    }
    else if (axis == 8) {
      ret = new Point(pnt.x - cross, pnt.y - cross);
    }
    else {
      fprintf(stderr, "unknown axis\n");
      exit(1);
    }

    upper = new Point(info_.getPlayerMaxPnt());

    if (ret.x > upper.x) {
      ret.x = upper.x;
    }
    else if (ret.x < 0) {
      ret.x = 0;
    }
    if (ret.y > upper.y) {
      ret.y = upper.y;
    }
    else if (ret.y < 0) {
      ret.y = 0;
    }

    return ret;
  }

  double getShotAngle(const PosSpd shot) {
    Point pnt = info_.getPlayerPnt();

    double angle = std.math.fabs(pnt.angle(shot.first));

    delete pnt;

    return std.math.fabs(std.math.fabs(shot.second.angle()) - angle);
  }

  Point getAxisVector(int axis) {
    return axis2vec.data[axis];
  }

protected:
  enum { NONE, UP, UPRIGHT, RIGHT, DOWNRIGHT, DOWN, DOWNLEFT, LEFT, UPLEFT }

  bool axisIsUp(int a) const {
    return a == UP || a == UPRIGHT || a == UPLEFT;
  }
  bool axisIsDown(int a) const {
    return a == DOWN || a == DOWNRIGHT || a == DOWNLEFT;
  }
  bool axisIsRight(int a) const {
    return a == RIGHT || a == UPRIGHT || a == DOWNRIGHT;
  }
  bool axisIsLeft(int a) const {
    return a == LEFT || a == UPLEFT || a == DOWNLEFT;
  }

}