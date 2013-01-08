/**
 * $Id: oblivion.h,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: oblivion.cc,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: oblivion.d 2012/05/20 12:02:02 i Exp $
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
import std.array;
import std.c.stdio;
import std.c.stdlib;
import cpu;
import util;
import deque;

/// 忘却
/**
 * 高速自機狙い弾を避けるのに適したアルゴリズム。
 * 弾の発生を把握し、その弾が接近する前に少し軸をずらし、
 * その弾を忘れ、考慮から外す。
 */
class OblivionCpu : CpuInputBase {
 private:
  int movingAxis_;
  bool isMoving_;
  int firstFrame_;
  PosSpds* samples_;
  int startMoveFrame_;
  int endMoveFrame_;
  int dangerFrame_;
  int prevAxis_;
  Deque!(bool)* handlables_;

private:
  /// 集めるサンプルの数
  static const size_t WAIT_SAMPLES = 50;
  /// サンプル数が不十分でも意思決定をするまでの時間
  static const int WAIT_FRAMES = 10;
  /// 余裕をもって動くドット数
  static const int OVER_MOVE = 20;
  /// 弾を引きつける時間の割合
  static const double WAIT_RATE = 2.0 / 3;
  /// 考察対象にする弾の自機に対する角度の限界
  static const double LIMIT_BULLET_ANGLE = dtor(5);
  /// 壁付近であると判断するドット数
  static const int NEAR_WALL = 15;
  /// 弾が処理可能だったかどうかを記憶する量
  static const size_t HANDLABLE_NUM = 100;
  /// 最高に自身がある時の値
  static const int MAX_CONFIDENCE = 50;

 public:
  this()
    {
      samples_ = PosSpds.createDeque(1, PosSpd.classinfo.init.length);
      handlables_ = Deque!(bool).createDeque(1, bool.sizeof);

      movingAxis_ = 0;
      isMoving_ = false;
      firstFrame_ = -1;
      dangerFrame_ = -1;
      prevAxis_ = 0;

      decision_ = false;

      name_ = "oblivion";
    }
  ~this() 
    {
      for ( int i = 0; i < samples_.size; ++i ) {
	free(cast(void*)samples_.data[i].first);
	free(cast(void*)samples_.data[i].second);
      }
      PosSpds.deleteDeque(samples_);

      Deque!(bool).deleteDeque(handlables_);
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
    if (isMoving_) {
      // 移動終了かな。
      if (lastTurn_ > endMoveFrame_ || meetWall()) {
	movingAxis_ = NONE;
	axis_ = NONE;

	// リセット
	firstFrame_ = startMoveFrame_ =	endMoveFrame_ =	-1;
	isMoving_ = false;
      }
    }
    // まだ移動候補が定まっていない時
    else if (movingAxis_ == NONE) {
      // サンプルがいくつか集まるか、時間が経過すると移動方向を決定する
      if (firstFrame_ != -1 && firstFrame_ + WAIT_FRAMES < lastTurn_) {
	decideAxis();
      }
    }
    // 移動開始
    else if (lastTurn_ >= startMoveFrame_ && startMoveFrame_ != -1) {
      axis_ = movingAxis_;
      isMoving_ = true;
    }

    if (axis_ != NONE) {
      evaluations_[axis_] = 30;
      evaluations_[(((axis_-2)&7)+1)] = 20;
      evaluations_[((axis_&7)+1)] = 20;
      evaluations_[(((axis_-3)&7)+1)] = 10;
      evaluations_[(((axis_+1)&7)+1)] = 10;
      evaluations_[0] = 10;
    }
  }

  override void registShot(float x, float y, float sx, float sy)
  {
    PosSpd pas = new PosSpd(new Point(x, y), new Point(sx, sy));

    if (handlables_.size == HANDLABLE_NUM)
      --handlables_.size;

    double angle = getShotAngle(pas);
    if (angle > LIMIT_BULLET_ANGLE) {
      bool f = false;
      Deque!(bool).pushFront(handlables_, &f);
      return;
    }
     
    bool t = true;
    Deque!(bool).pushFront(handlables_, &t);  

    // まだ移動候補が定まっていない時
    if (movingAxis_ == NONE) {
      if (firstFrame_ == -1) firstFrame_ = lastTurn_;

      // サンプルを登録
      PosSpds.pushBack(samples_, &pas);

      // サンプルがいくつか集まるか、時間が経過すると移動方向を決定する
      if (samples_.size == WAIT_SAMPLES) {
	decideAxis();
      }
    }
    else {
      updateMovingPlan(pas);
    }
  }

  int getConfidence() const
  {
    if (handlables_.size == 0) return 0;

    int ok = 0;
    for ( int i = 0; i < handlables_.size; ++i )
      if (handlables_.data[i])
	++ok;

    return ok * MAX_CONFIDENCE / handlables_.size;
  }

  void decideAxis()
  {
    Point pnt = info_.getPlayerPnt();

    Point upper = info_.getPlayerMaxPnt();

    // サンプルと自機との角度の平均をとる
    Point averageVec = new Point(0, 0);
    for ( int i = 0; i < samples_.size; ++i ) {
      //      Point vec = new Point(pnt - samples_.data[i].first);
      double tmpx = pnt.x - samples_.data[i].first.x;
      double tmpy = pnt.y - samples_.data[i].first.y;
      Point vec = new Point(tmpx, tmpy);
      averageVec += vec;
      delete vec;
    }
    //    averageVec /= samples_.size;
    averageVec.x /= samples_.size;
    averageVec.y /= samples_.size;

    // 四軸のどれが適切な角度かを考えて、
    // その後広い方を選択する。

    // 方向は180度で考えれば良し
    //    if (averageVec.y < 0) averageVec =- averageVec;
    if (averageVec.y < 0) {
      averageVec.x =- averageVec.x;
      averageVec.y =- averageVec.y;
    }

    double angle = averageVec.angle();
    if (angle > PI_PER_8 * 11 || angle < PI_PER_8 * 5) {
      if (dangerFrame_ > lastTurn_) {
	if (!isAxisOK(UP))
	  movingAxis_ = DOWN;
	else if (!isAxisOK(DOWN))
	  movingAxis_ = UP;
      }

      if (movingAxis_ == NONE) {
	movingAxis_ = (pnt.y > upper.y / 2) ? UP : DOWN;
      }
    }

    else if (angle > PI_PER_8 * 9) {
      if (dangerFrame_ > lastTurn_) {
	if (!isAxisOK(UPLEFT))
	  movingAxis_ = DOWNRIGHT;
	else if (!isAxisOK(DOWNRIGHT))
	  movingAxis_ = UPLEFT;
      }

      if (movingAxis_ == NONE) {
	int len1 = cast(int)std.algorithm.min(pnt.x, pnt.y);
	int len2 = cast(int)std.algorithm.min(upper.x - pnt.x, upper.y - pnt.y);

	movingAxis_ = (len1 > len2) ? UPLEFT : DOWNRIGHT;
      }
    }
    
    else if (angle > PI_PER_8 * 7) {
      if (dangerFrame_ > lastTurn_) {
	if (!isAxisOK(RIGHT))
	  movingAxis_ = LEFT;
	else if (!isAxisOK(LEFT))
	  movingAxis_ = RIGHT;
      }
      
      if (movingAxis_ == NONE) {
	movingAxis_ = (pnt.x > upper.x / 2) ? LEFT : RIGHT;
      }
    }
    
    else {
      if (dangerFrame_ > lastTurn_) {
	if (!isAxisOK(UPRIGHT))
	  movingAxis_ = DOWNLEFT;
	else if (!isAxisOK(DOWNLEFT))
	  movingAxis_ = UPRIGHT;
      }
	
      if (movingAxis_ == NONE) {
	int len1 = cast(int)std.algorithm.min(pnt.x, upper.y - pnt.y);
	int len2 = cast(int)std.algorithm.min(upper.x - pnt.x, pnt.y);

	movingAxis_ = (len1 > len2) ? DOWNLEFT : UPRIGHT;
        }
    }

    delete averageVec;

    // 壁にぶつかっている場合
    if (movingAxis_ == UPRIGHT) {
      if (pnt.y < NEAR_WALL) movingAxis_ = RIGHT;
      else if (pnt.x > upper.x - NEAR_WALL)
	movingAxis_ = UP;
    }
    else if (movingAxis_ == UPLEFT) {
      if (pnt.y < NEAR_WALL) movingAxis_ = LEFT;
      else if (pnt.x < NEAR_WALL)	movingAxis_ = UP;
    }
    else if (movingAxis_ == DOWNRIGHT) {
      if (pnt.y > upper.y-NEAR_WALL)
	movingAxis_ = RIGHT;
      else if (pnt.x > upper.x-NEAR_WALL)
	movingAxis_ = DOWN;
    }
    else if (movingAxis_ == DOWNLEFT) {
      if (pnt.y > upper.y-NEAR_WALL)
	movingAxis_ = LEFT;
      else if (pnt.x < NEAR_WALL)	movingAxis_ = DOWN;
    }
    else if ((movingAxis_ == UP && pnt.y < NEAR_WALL) ||
	     (movingAxis_ == DOWN &&
	      pnt.y > upper.y-NEAR_WALL))
      {
	movingAxis_ = (pnt.x > upper.x / 2)
	  ? LEFT : RIGHT;
      }
    else if ((movingAxis_ == LEFT && pnt.x < NEAR_WALL) ||
	     (movingAxis_ == RIGHT &&
	      pnt.x > upper.x-NEAR_WALL))
      {
	movingAxis_ = (pnt.y > upper.y / 2)
	  ? UP : DOWN;
      }

    delete pnt;
    delete upper;

    prevAxis_ = movingAxis_;

    /*
      if (getConfidence() > 5) {
      message(getAxisString(movingAxis_));
      }
    */

    // 方向も決まったところで移動計画でも

    // 計画の初期化
    startMoveFrame_ = -1;
    endMoveFrame_ = -1;

    for ( int i = 0; i < samples_.size; ++i )
      updateMovingPlan(samples_.data[i]);


    // 後始末
    //    samples_.clear();
    for ( int i = 0; i < samples_.size; ++i ) {
      free(cast(void*)samples_.data[i].first);
      free(cast(void*)samples_.data[i].second);
      free(cast(void*)samples_.data[i]);
    }
    samples_.size = 0;
    samples_.reserve_size = 0;

    firstFrame_ = -1;
  }

  void updateMovingPlan(const PosSpd pas)
  {
    int turn = (firstFrame_ == -1) ? lastTurn_ : firstFrame_;

    // この弾が当らない位置までいくには
    // どれだけの時間でどれだけ動けば良いのか？

    // まず回転させて座標系を合わせる
    //    Point vec = new Point(info_.getPlayerPnt() - pas.first);
    Point tmp = info_.getPlayerPnt();
    double tmpx = tmp.x - pas.first.x;
    double tmpy = tmp.y - pas.first.y;
    delete tmp;
    Point vec = new Point(tmpx, tmpy);
    Point spd = new Point(pas.second);

    double rotAngle = - PI_PER_4 * (movingAxis_ - 1);
    vec.rotate(rotAngle);
    spd.rotate(rotAngle);

    // どれだけ時間がかかるの。
    double collSecond = vec.x / spd.x;

    // どれだけ動けば良いの。(いくらか余裕を見て)
    double safeLength = vec.y - spd.y * collSecond + OVER_MOVE;

    delete vec;
    delete spd;

    double safeSecond = safeLength / info_.getPlayerSpd();
    int safeFrame = cast(int)(safeSecond / info_.getSpf());

    // 後ろに撃たれた弾や、遠くを通る弾は無視。
    // この判定はもっと早くやるべきかもしれない。
    if (collSecond < 0 || collSecond < safeSecond) return;

    // 移動開始時刻を早めるかも。
    if (!isMoving_) {
      int newStartMoveFrame = turn
	+ cast(int)(
			   (collSecond-safeSecond)*WAIT_RATE/info_.getSpf());
      if (startMoveFrame_ == -1 || startMoveFrame_ > newStartMoveFrame) {
	if (endMoveFrame_ != -1) {
	  endMoveFrame_ += newStartMoveFrame - startMoveFrame_;
	}
	startMoveFrame_ = newStartMoveFrame;
      }
    }

    // 移動終了時刻を遅めるかも。
    if (!isMoving_) {
      int newEndMoveFrame = startMoveFrame_ + safeFrame;
      if (endMoveFrame_ == -1 || endMoveFrame_ < newEndMoveFrame) {
	endMoveFrame_ = newEndMoveFrame;
      }
    }
    else {
      int newEndMoveFrame = turn + safeFrame;
      if (endMoveFrame_ < newEndMoveFrame) {
	endMoveFrame_ = newEndMoveFrame;
      }
    }

    // 危険終了時刻を遅めるかも。
    int collFrame =
      cast(int)(collSecond / info_.getSpf()) + lastTurn_;
    if (dangerFrame_ == -1 || dangerFrame_ < collFrame) {
      dangerFrame_ = collFrame;
    }
  }

 private:
  bool isAxisOK(int axis) const
  {
    if (prevAxis_ == 0) return true;

    int opposite = (axis) ? ((axis + 3) & 7) + 1 : 0;
    if (prevAxis_ == opposite ||
	prevAxis_ == (opposite & 7) + 1 ||   // 右回転
	prevAxis_ == ((opposite-2)&7)+1)         // 左回転
      {
	return false;
      }
    return true;
  }

  bool meetWall() const 
  {
    Point pnt = info_.getPlayerPnt();
    Point upper = info_.getPlayerMaxPnt();

    double pntx = pnt.x;
    double pnty = pnt.y;
    double upperx = upper.x;
    double uppery = upper.y;

    delete pnt;
    delete upper;

    return (
	    (axisIsUp(movingAxis_) && pnty < NEAR_WALL) ||
	    (axisIsDown(movingAxis_) && pnty > uppery - NEAR_WALL) ||
	    (axisIsRight(movingAxis_) && pntx > upperx - NEAR_WALL) ||
	    (axisIsLeft(movingAxis_) && pntx < NEAR_WALL)
	    );
  }
}