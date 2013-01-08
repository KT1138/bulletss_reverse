/**
 * $Id: reflection.h,v 1.1 2003/09/06 22:53:28 i Exp $
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
 * $Id: reflection.d 2012/05/20 12:02:02 i Exp $
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

import std.c.math;
import std.c.stdio;
import std.c.stdlib;
import cpu;
import cpuinfo;
import util;
import deque;


///反射
/**
 * 弾との距離に反比例し、弾の速度に比例し、弾の自機に対する角度に比例する。
 * 危険度を計算して、それによって判断を行う。
 */
class ReflectionCpu : CpuInputBase {
 public:
  this() { name_ = "reflection"; }

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
    
  override void calc()
  {
    Point mypnt = info_.getPlayerPnt();

    PosSpds* posspd = PosSpds.createDeque(1, PosSpd.classinfo.init.length);

    info_.getBulletsPosAndSpd(posspd);

    Deque!(Point)* mypnts = Deque!(Point).createDeque(1, Point.classinfo.init.length);

    for ( int i = 0; i < 9; ++i ) {
      Point p = getMovedPoint(mypnt, i);
      Deque!(Point).pushBack(mypnts, &p);
    }
    delete mypnt;   // ok

    double dp = -1;
    int index, minIndex = 0;

    double dps[9];
    double dpAll = 0;

    for (index = 0; index < 9; ++index) {
      Point upper = info_.getPlayerMaxPnt();

      Point pnt = mypnts.data[index];   // 参照渡し


      if (pnt.x > upper.x || pnt.x < 0 || pnt.y > upper.y || pnt.y < 0) {
	delete upper;
	continue;
      }

      delete upper;

      double nowDp = dangerPoint(pnt, posspd);

      // 前回のまんまの行動は比較的自然だろう
      //if (index == prevIndex_ && nowDp != 0.0) nowDp *= 0.9;
      if (index == 0 && nowDp != 0.0) nowDp *= 0.95;

      dps[index] = nowDp;
      dpAll += nowDp;

      if (nowDp < dp || dp == -1) {
	dp = nowDp;
	minIndex = index;
      }

      // std::cerr << index << "; " << nowDp << std::endl;

    }

    for ( int i = 0; i < posspd.size; ++i ) {
      free(cast(void*)posspd.data[i].first);
      free(cast(void*)posspd.data[i].second);
      free(cast(void*)posspd.data[i]);
    }
    Deque!(PosSpd).deleteDeque(posspd);

    Deque!(Point).deleteDeque(mypnts);

    axis_ = minIndex;

    decision_ = false;
    prevIndex_ = minIndex;

    if (dpAll != 0) {
      for ( int i = 0; i < 9; ++i ) {
	evaluations_[i] = 5 - cast(int)(dps[i] / dpAll * 100);
      }
    }
  }

  override void registShot(float, float, float, float) {}

 private:
  double dangerPoint(Point mypnt, Deque!(PosSpd)* posspd) {
    double dp = 0;

    for ( int i = 0; i < posspd.size; ++i ) {
      Point pnt = posspd.data[i].first;
      Point spd = posspd.data[i].second;

      double tmpx = mypnt.x - pnt.x;
      double tmpy = mypnt.y - pnt.y;      

      //      Point vec = new Point(mypnt - pnt);
      Point vec = new Point(tmpx, tmpy);

      double timeLength = spd.length2() / vec.length2();

      delete vec;

      if (timeLength <= 4) continue;

      double angle =
    	PI / 4.0 -
    	std.math.fabs(std.math.fabs(spd.angle()) - std.math.fabs(mypnt.angle(pnt)));

      if (angle > 0)
    	dp += timeLength * angle * angle;
    }

    return dp;

  }
}