#include <axis.hh>
#include <bulletss.hh>
#include <cpuinput.hh>


struct CpuInfoHolder {
    tr1::shared_ptr<Target> player;
};
CpuInfoHolder cpuinfoHolder_;


extern "C" {
    double CpuInfo_getPlayerSize_(CpuInfo info) { return 20; }
    double CpuInfo_getPlayerSpd_(CpuInfo info) { return 3; }
    double CpuInfo_getFps_(CpuInfo info) { return 1; }
    int CpuInfo_getTurn_(CpuInfo info) { return cpuinfoHolder_.player->turn(); }
    double CpuInfo_getSpf_(CpuInfo info) { return 1; }
}


CpuInput::CpuInput(tr1::shared_ptr<Target> player)
    : player_(player), cpu_(Cpu_getDefaultCpu()), info_(CpuInfoCave_new())
{
    cpuinfoHolder_.player = player;

    CpuInfo_set_getPlayerSize(info_, &CpuInfo_getPlayerSize_);
    CpuInfo_set_getPlayerSpd(info_, &CpuInfo_getPlayerSpd_);
    CpuInfo_set_getFps(info_, &CpuInfo_getFps_);
    CpuInfo_set_getTurn(info_, &CpuInfo_getTurn_);
    CpuInfo_set_getSpf(info_, &CpuInfo_getSpf_);
    CpuInfo_setPlayerMaxPnt(info_, 300, 400);

    Cpu_setCpuInfomation(info_);
}

CpuInput::~CpuInput()
{
    Cpu_delete(cpu_);
    CpuInfoCave_delete(info_);
}

tr1::shared_ptr<Axis> CpuInput::getAxis()
{
    CpuInfo_setPlayerPnt(info_, player_->x(), player_->y());
    int len = 0;
    float* x = 0;
    float* y = 0;
    float* sx = 0;
    float* sy = 0;

    // BulletSS::obj->getBullets(len, x, y, sx, sy);
    len = BulletSS::obj->shotNum_;
    x = BulletSS::obj->shotX_;
    y = BulletSS::obj->shotY_;
    sx = BulletSS::obj->shotSX_;
    sy = BulletSS::obj->shotSY_;


    CpuInfo_setBulletsPosSpd(info_, len, x, y, sx, sy);

    int a = Cpu_getAxis(cpu_);   // chairman.d:41参照

    return tr1::shared_ptr<Axis>(new Axis(Axis::createFromSmallCode(a)));
}
