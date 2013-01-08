/**
 * $Id: pair.d 2012/05/20 12:02:02 i Exp $
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


class Pair(T) {
public:
  T first;
  T second;

public:
  this(T first, T second)
  {
    this.first = first;
    this.second = second;
  }
  ~this()
  {
    delete first;
    delete second;
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
}

class Pair(T, U) {
public:
  T first;
  U second;

public:
  this(T first, U second)
  {
    this.first = first;
    this.second = second;
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
}
