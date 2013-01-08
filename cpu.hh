#ifndef _CPU_HH
#define _CPU_HH

extern "C" {
typedef int CpuInfo;
typedef int CpuInfoCave;
int CpuInfoCave_new();
void CpuInfoCave_delete(int);
void CpuInfo_setPlayerPnt(int , float, float);
void CpuInfo_setPlayerMaxPnt(int , float, float);
void CpuInfo_setBulletsPosSpd(int , int, float*, float*, float*, float*);
void CpuInfo_set_getPlayerSize(int, double (*fp) (int )); 
void CpuInfo_set_getPlayerSpd(int, double (*fp) (int )); 
void CpuInfo_set_getFps(int, double (*fp) (int )); 
void CpuInfo_set_getTurn(int, int (*fp) (int )); 
void CpuInfo_set_getSpf(int, double (*fp) (int )); 
typedef int CpuInputBase;
void Cpu_delete(int);
CpuInputBase Cpu_getDefaultCpu();
void Cpu_setCpuInfomation(CpuInfo);
void Cpu_registShot(int , float, float, float, float);
int Cpu_getAxis(int );

void Cpu_initAxis();
}

#endif   // _CPU_HH
