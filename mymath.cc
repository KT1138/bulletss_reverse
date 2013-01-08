#include <ctime>
#include <boost/random.hpp>
#include <mymath.hh>
using namespace std;
using namespace boost;


int rnd(int v) 
{
    mt19937 gen( static_cast<unsigned long>(time(0)) );
    uniform_smallint<> dst( 1, 1000 );
    variate_generator<
        mt19937&, uniform_smallint<>
        > rand( gen, dst );

    return rand() % v;
}

float rtod(float a)
{
    return a * 180 / M_PI;
}

float dtor(float a)
{
    return a * M_PI / 180;
}
