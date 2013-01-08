#ifndef _PADINPUT_HH
#define _PADINPUT_HH

#include <tr1/memory>


class Axis;


class PadInput {
public:
    virtual ~PadInput() {}
    virtual tr1::shared_ptr<Axis> getAxis() = 0;
 };

#endif //  _PADINPUT_HH
