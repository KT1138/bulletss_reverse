/**
 * $Id: roundtrip.h,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: roundtrip.cc,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: roundtrip.d 2012/05/20 12:02:02 i Exp $
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

import std.array;
import std.c.stdio;
import std.c.stdlib;
import cpu;
import pair;
import util;
import deque;


/// 切り返し
/**
 * ただ切り返すだけ。対象は自機狙い気味ばらまき弾
 */
class RoundtripCpu : CpuInputBase {
 private:
  alias Pair!(bool, int) RegistedShot;
  Deque!(RegistedShot)* registed_;

 private:
  int lastRegistShotTurn_;
  int sameTurnRegists_;

  bool right_;

 private:
  /// 完全自機狙い弾規定する角度
  static const double MIN_ANGLE = dtor(1);
    /// 大雑把な自機狙い弾規定する角度
  static const double MAX_ANGLE = dtor(60);
  /// 同一ターンでいくつ登録するか
  static const int SAME_TURN_SHOTS = 5;
  /// 自信の最大値
  static const int MAX_CONFIDENCE = 10;
  /// 弾を忘れるターン数
  static const int FORGET_TURN = 120;
  /// ばらまきとみなせる弾数
  static const size_t MIN_BULLETS = 50;
  /*
 /// 折り返し地点、右端
 const int RIGHT_EDGE;
 /// 折り返し地点、左端
 const int LEFT_EDGE;
  */

 public:
  this()
    {
      registed_ = 
	Deque!(RegistedShot).createDeque(1, RegistedShot.classinfo.init.length);

      lastRegistShotTurn_ = -1;
      sameTurnRegists_ = 0;
      right_ = true;
    }
  ~this()
    {
      for ( int i = 0; i < registed_.size; ++i )
	free(cast(void*)registed_.data[i]);

      Deque!(RegistedShot).deleteDeque(registed_);
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
    const int RIGHT_EDGE = cast(int)(info_.getPlayerMaxPnt().x * 4 / 5);
    const int LEFT_EDGE = cast(int)(info_.getPlayerMaxPnt().y / 5);

    // 毎ターンリセット
    sameTurnRegists_ = 0;

    int turn = info_.getTurn();
    while (registed_.size && turn > registed_.data[0].second) {
      Deque!(RegistedShot).popFront(registed_);
    }

    Point pnt = info_.getPlayerPnt();
    if ((right_ && pnt.x > RIGHT_EDGE) ||
	(!right_ && pnt.x < LEFT_EDGE))
      {
	right_ = !right_;
	// message("切りかえしー");
      }
    delete pnt;

    if (registed_.size < MIN_BULLETS) return;

    if (right_) {
      evaluations_[2] = 10;
      evaluations_[3] = 20;
      evaluations_[4] = 10;
    }
    else {
      evaluations_[6] = 10;
      evaluations_[7] = 20;
      evaluations_[8] = 10;
    }
  }

  override void registShot(float x, float y, float sx, float sy)
  {
    int turn = info_.getTurn();

    if (lastRegistShotTurn_ == turn &&
	sameTurnRegists_ >= SAME_TURN_SHOTS)
      {
	return;
      }
    ++sameTurnRegists_;

    double angle = getShotAngle(new PosSpd(new Point(x, y), new Point(sx, sy)));

    if (angle < MIN_ANGLE || angle > MAX_ANGLE) {
      RegistedShot regist = new RegistedShot(false, turn + FORGET_TURN);
      Deque!(RegistedShot).pushBack(registed_, &regist);
    }
    else {
      RegistedShot regist = new RegistedShot(true, turn + FORGET_TURN);
      Deque!(RegistedShot).pushBack(registed_, &regist);      
    }
  }

  int getConfidence() const
  {
    if (registed_.size < MIN_BULLETS) return 0;

    int cnt = 0;
    for ( int i = 0; i < registed_.size; ++i )
      if (registed_.data[i].first)
    	++cnt;

    return MAX_CONFIDENCE * cnt / registed_.size;
  }
}