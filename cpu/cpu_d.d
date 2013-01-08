import std.c.stdio;
import std.c.stdlib;
import util;
import cpu;
import cpuinfo;
import chairman;
import pair;


class CpuInfoCave : CpuInfo {
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
    double getPlayerSize() { return D_getPlayerSize_fp(this ); }
    void D_set_getPlayerSize(double function(CpuInfoCave ) fp) { D_getPlayerSize_fp = fp; } 
    double function(CpuInfoCave) D_getPlayerSize_fp;
    double getPlayerSpd() { return D_getPlayerSpd_fp(this ); }
    void D_set_getPlayerSpd(double function(CpuInfoCave ) fp) { D_getPlayerSpd_fp = fp; }
    double function(CpuInfoCave) D_getPlayerSpd_fp;
    double getFps() { return D_getFps_fp(this ); }
    void D_set_getFps(double function(CpuInfoCave ) fp) { D_getFps_fp = fp; }
    double function(CpuInfoCave) D_getFps_fp;
    int getTurn() { return D_getTurn_fp(this ); }
    void D_set_getTurn(int function(CpuInfoCave ) fp) { D_getTurn_fp = fp; }
    int function(CpuInfoCave) D_getTurn_fp;
    double getSpf() { return D_getSpf_fp(this ); }
    void D_set_getSpf(double function(CpuInfoCave ) fp) { D_getSpf_fp = fp; }
    double function(CpuInfoCave) D_getSpf_fp;


    float getPlayerPnt_x;
    float getPlayerPnt_y;
    Point getPlayerPnt() {
      return new Point(getPlayerPnt_x, getPlayerPnt_y);
    }
    void setPlayerPnt(float x, float y) {
      getPlayerPnt_x = x;
      getPlayerPnt_y = y;
    }

    float getPlayerMaxPnt_x;
    float getPlayerMaxPnt_y;
    Point getPlayerMaxPnt() {
      return new Point(getPlayerMaxPnt_x, getPlayerMaxPnt_y);
    }
    void setPlayerMaxPnt(float x, float y) {
      getPlayerMaxPnt_x = x;
      getPlayerMaxPnt_y = y;
    }

    int getBulletsPosSpd_len;
    float* getBulletsPosSpd_pntx;
    float* getBulletsPosSpd_pnty;
    float* getBulletsPosSpd_spdx;
    float* getBulletsPosSpd_spdy;

    void setBulletsPosSpd(int len, float* px, float* py, float* sx, float* sy) {
      getBulletsPosSpd_len = len;
      getBulletsPosSpd_pntx = px;
      getBulletsPosSpd_pnty = py;
      getBulletsPosSpd_spdx = sx;
      getBulletsPosSpd_spdy = sy;
    }

    // ↓veto.dとreflection.dのcalc関数内で呼び出される関数。
    void getBulletsPosAndSpd(PosSpd* posspd) {
      for ( int i = 0; i < getBulletsPosSpd_len; ++i ) {
      	Pair!(Point) tmp = new Pair!(Point)(new Point(getBulletsPosSpd_pntx[i],
      					       getBulletsPosSpd_pnty[i]),
      				     new Point(getBulletsPosSpd_spdx[i],
      					       getBulletsPosSpd_spdy[i]));
	PosSpd.pushBack(posspd, &tmp);
      }
    }
  }
}

extern (C) {
  CpuInfoCave CpuInfoCave_new() { return new CpuInfoCave(); }
  void CpuInfoCave_delete(CpuInfoCave c) { delete c; }

  void CpuInfo_setPlayerPnt(CpuInfoCave c, float arg1, float arg2) { return c.setPlayerPnt(arg1, arg2); }
  void CpuInfo_setPlayerMaxPnt(CpuInfoCave c, float arg1, float arg2) { return c.setPlayerMaxPnt(arg1, arg2); }
  void CpuInfo_setBulletsPosSpd(CpuInfoCave c, int arg1, float* arg2, float* arg3, float* arg4, float* arg5) { return c.setBulletsPosSpd(arg1, arg2, arg3, arg4, arg5); }

  void CpuInfo_set_getPlayerSize(CpuInfoCave c, double function(CpuInfoCave) fp) { c.D_set_getPlayerSize(fp); }
  void CpuInfo_set_getPlayerSpd(CpuInfoCave c, double function(CpuInfoCave) fp) { c.D_set_getPlayerSpd(fp); }
  void CpuInfo_set_getFps(CpuInfoCave c, double function(CpuInfoCave) fp) { c.D_set_getFps(fp); }
  void CpuInfo_set_getTurn(CpuInfoCave c, int function(CpuInfoCave) fp) { c.D_set_getTurn(fp); }
  void CpuInfo_set_getSpf(CpuInfoCave c, double function(CpuInfoCave) fp) { c.D_set_getSpf(fp); }
}

//alias int CpuInputBase;
extern (C) {
  void Cpu_delete(CpuInputBase c) { delete c; }
  CpuInputBase Cpu_getDefaultCpu() { return CpuInputBase.getDefaultCpu(); }
  void Cpu_setCpuInfomation(CpuInfo arg1) { return CpuInputBase.setCpuInfomation(arg1); }
  void Cpu_registShot(CpuInputBase c, float arg1, float arg2, float arg3, float arg4) { return c.registShot(arg1, arg2, arg3, arg4); }
  int Cpu_getAxis(CpuInputBase c) { return c.getAxis(); }

  void Cpu_initAxis() { CpuInputBase.initAxis(); }
}
