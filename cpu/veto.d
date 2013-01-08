/**
 * $Id: veto.h,v 1.1 2003/09/06 22:53:28 i Exp $
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
 * $Id: veto.cc,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: veto.d 2012/05/20 12:02:02 i Exp $
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
import cpu;
import util;

/// 拒否権
/**
 * 次のターンに死ぬことだけを拒否する。他は無視。
 */
class VetoCpu : CpuInputBase {
 public:
  this()
    {
      name_ = "veto";
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

 public:
  override void calc()
  {
    double size = info_.getPlayerSize();;
    double size2 = size * size;

    double spf = info_.getSpf();

    PosSpds* posspd = 
      PosSpds.createDeque(1, PosSpd.classinfo.init.length);
 
    info_.getBulletsPosAndSpd(posspd);

    Point mypnt = info_.getPlayerPnt();

    for ( int i = 0; i < 9; ++i) {
      Point pnt = getMovedPoint(mypnt, i);

      for ( int j = 0; j < posspd.size; ++j ) {
	// under construction...
	//	if (pnt.length2(posspd.data[j].first + posspd.data[j].second * spf) < size2) {   // こうするとメモリリークが起こる
	double tmpx = posspd.data[j].first.x + posspd.data[j].second.x * spf;
	double tmpy = posspd.data[j].first.y + posspd.data[j].second.y * spf;
	double tmpx2 = pnt.x - tmpx;
	double tmpy2 = pnt.y - tmpy;
	double result = tmpx2 * tmpx2 + tmpy2 * tmpy2;
	if (result < size2) {
	  evaluations_[i] = -10000;
      	  break;
      	}
      	if (pnt.length2(posspd.data[j].first) < size2) {
      	  evaluations_[i] = -5000;
      	  break;
      	}
      }
      delete pnt;
    }

    for ( int i = 0; i < posspd.size; ++i ) {
      free(cast(void*)posspd.data[i].first);
      free(cast(void*)posspd.data[i].second);
      free(cast(void*)posspd.data[i]);
    }
    PosSpds.deleteDeque(posspd);
    delete mypnt;
  }

  override void registShot(float, float, float, float) {}
}