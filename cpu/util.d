import std.string;
import std.math;
import std.c.stdio;
import std.c.stdlib;
import cpu;


const double PI = 3.1415926;
const double SQRT_TWO = std.math.sqrt(2.0);

const double PI_PER_2 = PI / 2;
const double PI_PER_4 = PI / 4;
const double PI_PER_8 = PI / 8;

double dtor(double x) { return x * PI / 180; }
double rtod(double x) { return x * 180 / PI; }

T_  absolute(T_)(T_ v) { return (v < 0) ? -v : v; }

void ignoreBrankAndComment(string str, string delim = "#");

class GetDoubleCastPolicy {
  static double getDouble(T_)(T_ v) { return cast(double)v; }
}

// class GetDoubleMethodPolicy {
//   static double getDouble(T_)(T_ v) { return v.getDouble(); }
// }

class Coord(T_) {
public:
  double x, y;

public:
  //  this(T_ x0, T_ y0) { x = x0, y = y0; }
  this(double x0, double y0) { x = x0, y = y0; }
  this(const Coord rhs) { x = rhs.x, y = rhs.y; }

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

  // Coord opAdd(const Coord rhs) const
  // {
  //   return new Coord(x + rhs.x, y + rhs.y);
  // }
  // Coord opSub(const Coord rhs) const
  // {
  //   return new Coord(x - rhs.x, y - rhs.y);
  // }
  // Coord opMul(const Coord rhs) const
  // {
  //   return new Coord(x * rhs.x, y * rhs.y);
  // }
  // Coord opMul(T_ rhs) const
  // {
  //   return new Coord(x * rhs, y * rhs);
  // }
  // Coord opDiv(const Coord rhs) const
  // {
  //   return new Coord(x / rhs.x, y / rhs.y);
  // }
  Coord opAddAssign(const Coord rhs)
  {
    this.x += rhs.x;
    this.y += rhs.y;
    return this;
  }
  Coord opSubAssign(const Coord rhs) 
  {
    this.x -= rhs.x;
    this.y -= rhs.y;
    return this;
  }
  Coord opMulAssign(const Coord rhs) 
  {
    this.x *= rhs.x;
    this.y *= rhs.y;
    return this;
  }
  Coord opDivAssign(const Coord rhs) 
  {
    this.x /= rhs.x;
    this.y /= rhs.y;
    return this;
  }
  // Coord opNeg()
  // {
  //   return new Coord(-x, -y);
  // }

	// friend std::ostream& operator<< (std::ostream& os, const Coord<T_>& rhs) {
	// 	os << '(' << rhs.x << ',' << rhs.y << ')';
	// 	return os;
	// }

  T_ length2() const
  {
    return x * x + y * y;
  }
  T_ length2(const Coord p) const
  {
    T_ x1 = x - p.x;
    T_ y1 = y - p.y;
    return x1 * x1 + y1 * y1; 
  }

  double length() const 
  {
    return std.math.sqrt(GetDoubleCastPolicy.getDouble(length2()));
  }
  double length(const Coord p) const
  {
    return std.math.sqrt(GetDoubleCastPolicy.getDouble(length2(p)));
  }

  void rotate(double angle)
  {
    double cs = std.math.cos(angle);
    double sn = std.math.sin(angle);
    T_ x2 = cs * x - sn * y;
    y = sn * x + cs * y;
    x = x2;
  }

  void unit()
  {
    T_ x2 = absolute(x) * x;
    T_ y2 = absolute(y) * y;
    T_ x2y2 = absolute(x2) + absolute(y2);
    x = x2 / x2y2;
    y = y2 / x2y2;
  }

  /**
   * 上が0度で右回り。
   */
  double angle() const
  {
    double ret;
    if (y == 0) {
      if (x > 0)
	return PI_PER_2;
      else
	return PI_PER_2 * 3;
    }
    else 
      ret = std.math.atan(GetDoubleCastPolicy.getDouble(x / y));
    return (y > 0) ? PI - ret : -ret;
  }
  double angle(const Coord p) const
  {
    //    Coord vec = new Coord(this - p);
    double tmpx = this.x - p.x;
    double tmpy = this.y - p.y;
    Coord vec = new Coord(tmpx, tmpy);
    double ret = vec.angle();
    delete vec;

    return ret;
    
  }

  double innerProduct() const
  {
    return x * x + y * y;
  }

  int xi() const { return cast(int)x; }
  int yi() const { return cast(int)y; }
  double xd() const { return GetDoubleCastPolicy.getDouble(x); }
  double yd() const { return GetDoubleCastPolicy.getDouble(y); }
}

alias Coord!(double) Point;


