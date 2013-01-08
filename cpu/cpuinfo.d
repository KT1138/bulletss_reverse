/**
 * $Id: cpuinfo.h,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: cpuinfo.d 2012/05/20 12:02:02 i Exp $
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
import pair;
import util;
import deque;


// cpuにくれてやるべき情報群。純粋仮想。
class CpuInfo {
public:
  alias Deque!(Pair!(Point)) PosSpd;

public:
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

  extern (C) {
    // playerの大きさ
    abstract double getPlayerSize();

    // playerの位置
    abstract Point getPlayerPnt();

    // playerの速度
    abstract double getPlayerSpd();

    // playerの移動できる最大座標値
    abstract Point getPlayerMaxPnt();

    // Buletの位置と速度情報をつっこんで返す
    abstract void getBulletsPosAndSpd(PosSpd* posspd);

    // fps
    abstract double getFps();

    // 現在のターン数
    abstract int getTurn();


    //SPF オーバーライドしなくて良し
    double getSpf()
    {
      return 1.0 / getFps();
    }
  }
}