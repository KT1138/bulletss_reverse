/**
 * $Id: chairman.h,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: chairman.cc,v 1.2 2003/09/16 08:25:57 i Exp $
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
 * $Id: chairman.d 2012/05/20 12:02:02 i Exp $
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
import gl.opengl;
import cpu;
import oblivion;
import position;
import reflection;
import roundtrip;
import veto;
import deque;


static const int MAX_DIETS = 10;


///議長
/**
 * 議員である他アルゴリズムの意見をまとめて方針を定める
 */
class ChairmanCpu : CpuInputBase {
 private:
  Deque!(CpuInputBase)* diet_;
  int[9][MAX_DIETS] dietEvals_;

 public:
  this()
    {
      diet_ = Deque!(CpuInputBase).createDeque(1, CpuInputBase.classinfo.init.length);

      VetoCpu veto = new VetoCpu();
      Deque!(CpuInputBase).pushBack(diet_, &veto);

      // under construction...
      ReflectionCpu reflection = new ReflectionCpu();
      Deque!(CpuInputBase).pushBack(diet_, &reflection);

      PositionCpu pos = new PositionCpu();
      Deque!(CpuInputBase).pushBack(diet_, &pos);

      RoundtripCpu round = new RoundtripCpu();
      Deque!(CpuInputBase).pushBack(diet_, &round);      

      OblivionCpu oblivion = new OblivionCpu();
      Deque!(CpuInputBase).pushBack(diet_, &oblivion);      

      assert(diet_.size <= MAX_DIETS);
    }
  ~this()
    {
      for ( int i = 0; i < diet_.size; ++i )
	free(cast(void*)diet_.data[i]);

      Deque!(CpuInputBase).deleteDeque(diet_);
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

  override void registShot(float x, float y, float sx, float sy)
  {
    for ( int i = 0; i < diet_.size; ++i )
      diet_.data[i].registShot(x, y, sx, sy);
  }

  override void calc()
  {
    for ( size_t j = 0; j < diet_.size; ++j) {
      CpuInputBase cpu = diet_.data[j];

      cpu.update();
      for (int i = 0; i < 9; ++i) {
	int eval = cpu.getAxisEvaluation(i) * cpu.getConfidence();
	evaluations_[i] += eval;
	dietEvals_[j][i] = eval;
      }
    }
    int index = 9 -  std.algorithm.minPos!("a > b")(evaluations_[0 .. 9]).length;

    axis_ = index;   // "axis_"はcpuinput.cc:66で代入される

    decision_ = false;

    drawGraph();
  }

//#if 0
// void registEnemy(const Enemy* enemy) {
// 	for (size_t i = 0; i < diet_.size; ++i) {
// 		diet_.data[i].registEnemy(enemy);
// 	}
// }
//#endif

 private:
  void report() const
  {
    for ( int i = 0; i < diet_.size; ++i )
      diet_.data[i].report();
  }

  version(Windows) { import std.windows; }

  void drawGraph()
  {
    // 適当すぎるなあ
    static const float cols[][3] = [
				    [ 1, 0, 0 ], [ 1, 0.5, 0 ], [ 1, 1, 0 ], [ 0, 1, 0], [ 0, 0, 1 ],
				    [ 1, 0, 1 ], [ 0.5, 0.5, 0.5 ] ];

    glBegin(GL_LINES);
    for (size_t i = 0; i < diet_.size; ++i) {
      drawSingleGraph(&dietEvals_[i][0], &cols[i][0]);
    }
    glEnd();
  }

  void drawSingleGraph(int* evals, const float* col)
  {
    static const int cx = 320;
    static const int cy = 240;

    int ev = evals[8] / 20 + 20;
    if (ev > cx-1) ev = cx-1;
    else if (ev < 0) ev = 0;
    int px = cast(int)(axis2vec.data[8].x * ev) + cx;
    int py = cast(int)(axis2vec.data[8].y * ev) + cy;

    for (size_t i = 1; i < 9; ++i) {
      int ev2 = evals[i] / 20 + 20;
      if (ev2 > 200) ev2 = 200;
      else if (ev2 < 0) ev2 = 0;
      int x = cast(int)(axis2vec.data[i].x * ev2) + cx;
      int y = cast(int)(axis2vec.data[i].y * ev2) + cy;

      glColor3fv(cast(float*)col);
      glVertex3f(px, py, 0);
      glVertex3f(x, y, 0);

      px = x;
      py = y;
    }
  }
}