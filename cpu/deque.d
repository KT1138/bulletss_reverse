/**
 * $Id: deque.d 2012/05/20 12:02:02 i Exp $
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
import std.c.string;


struct Deque(T) {
public:
  T* data;   // dequeへのポインタ
  int size;   // 現在使用中の領域サイズ
  int reserve_size;   // 予約領域サイズ
  size_t data_size;   // データ1個あたりの大きさ

public:
  static Deque!(T)* createDeque(int size, size_t data_size)
  {
    Deque!(T)* deq =
      cast(Deque!(T)*)malloc(Deque!(T).sizeof);

    if (deq == null )
      return null;
    
    deq.size = 0;
    deq.data_size = data_size;
    deq.reserve_size = size;

    deq.data = cast(T*)malloc(size * data_size);
    if (deq.data == null)
      return null;

    memset(deq.data, 0, size * data_size);

    return deq;
  }

  static void deleteDeque(Deque!(T)* deq)
  {
    if (deq != null) {
      if (deq.data != null) {
	free(cast(void*)deq.data);
      }
      free(cast(void*)deq);
    }
    deq.size = 0;
    deq.reserve_size = 0;
  }

  static int reallocDeque(Deque!(T)* deq, int realloc_size)
  {
    T* tmp =
      cast(T*)malloc(deq.data_size * realloc_size);
    if (tmp == null) {
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    memcpy(tmp, deq.data, deq.data_size * realloc_size);

    free(cast(void*)deq.data);

    deq.data = tmp;

    deq.reserve_size = realloc_size;

    return 1;
  }  

    static int pushBack(Deque!(T)* deq, void* data)
  {
    if(deq.size == deq.reserve_size && 
       reallocDeque(deq, deq.reserve_size+1)==0){
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    memcpy(deq.data + deq.size++ , data, deq.data_size);

    return 1;
  }

  static int pushFront(Deque!(T)* deq, void* data)
  {
    if(deq.size == deq.reserve_size && 
       reallocDeque(deq, deq.reserve_size+1)==0){
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    T* tmp =
      cast(T*)malloc(deq.data_size * deq.reserve_size+1);
    if (tmp == null) {
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    memcpy(tmp, data, deq.data_size);

    memcpy(tmp+1, deq.data, deq.data_size * deq.reserve_size);

    free(cast(void*)deq.data);

    deq.data = tmp;

    ++deq.size;

    return 1;
  }

  static int popFront(Deque!(T)* deq)
  {
    T* tmp =
      cast(T*)malloc(deq.data_size * deq.reserve_size-1);
    if (tmp == null) {
      fprintf(stderr, "メモリ確保失敗\n");
      exit(1);
    }

    memcpy(tmp, deq.data+1, deq.data_size * deq.reserve_size-1);

    free(cast(void*)deq.data);

    deq.data = tmp;

    --deq.size;
    --deq.reserve_size;

    return 1;
  }
}
