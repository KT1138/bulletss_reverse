/**
 * $Id: position.h,v 1.1 2003/09/06 22:53:28 i Exp $
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
 * $Id: position.cc,v 1.1 2003/09/06 22:53:28 i Exp $
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
 * $Id: position.d 2012/05/20 12:02:02 i Exp $
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

import std.algorithm;
import std.c.stdio;
import std.c.stdlib;
import cpu;
import util;


/// 場所取り
/**
 * 弾は全く気にせず、敵正面を保とうとする
 */
class PositionCpu : CpuInputBase {
 public:
  this() 
    {
      name_ = "position";
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

  override void calc()
  {
    Point pnt = info_.getPlayerPnt();
    Point upper = info_.getPlayerMaxPnt();
    //    Point upperLen = upper - pnt;
    double tmpx = upper.x - pnt.x;
    double tmpy = upper.y - pnt.y;
    Point upperLen = new Point(tmpx, tmpy);

    if (pnt.x < 30) {
      evaluations_[7] -= cast(int)(100 / (pnt.x*pnt.x+10));
      ++evaluations_[3];
    }
    if (pnt.y < 100) {
      evaluations_[1] -= cast(int)(100 / (pnt.y*pnt.y+10));
      ++evaluations_[5];
    }
    if (upperLen.x < 30) {
      evaluations_[3] -= cast(int)(100 / (upperLen.x*upperLen.x+10));
      ++evaluations_[7];
    }
    if (upperLen.y < 100) {
      evaluations_[5] -= cast(int)(100 / (upperLen.y*upperLen.y+10));
      ++evaluations_[1];
    }

    if (pnt.y < upper.y / 2) {
      evaluations_[1] -= cast(int)(upper.y / 2 - pnt.y) / 10;
      ++evaluations_[5];
    }

    evaluations_[2] = (evaluations_[1] + evaluations_[3]) / 2;
    evaluations_[4] = (evaluations_[3] + evaluations_[5]) / 2;
    evaluations_[6] = (evaluations_[5] + evaluations_[7]) / 2;
    evaluations_[8] = (evaluations_[7] + evaluations_[1]) / 2;

    // バランスをとるために
    evaluations_[0] = std.algorithm.reduce!("a + b")(0, evaluations_[1 .. 9]) / 8;

    delete pnt;
    delete upper;
    delete upperLen;
  }

  override void registShot(float, float, float, float) {}

  int getConfidence() const { return 10; }
}