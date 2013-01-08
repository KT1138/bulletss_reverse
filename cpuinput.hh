#ifndef _CPUINPUT_HH
#define _CPUINPUT_HH

#include <tr1/memory>
#include <axis.hh>
#include <charactor.hh>
#include <cpu.hh>
#include <padinput.hh>
using namespace std;


class Target;


class CpuInput : public PadInput {
private:
    tr1::shared_ptr<Target> player_;
    CpuInputBase cpu_;
    CpuInfoCave info_;

public:
    explicit CpuInput(tr1::shared_ptr<Target> player);
    ~CpuInput();

    tr1::shared_ptr<Axis> getAxis();
    bool getButton(int id) const { return false; }
    void registShot(float x, float y, float sx, float sy) { Cpu_registShot(cpu_, x, y, sx, sy); }
};

#endif   //  _CPUINPUT_HH
