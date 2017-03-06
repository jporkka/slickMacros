////////////////////////////////////////////////////////////////////////////////////
// Revision: 1 
////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#include "slick.sh"

// Color contrast calculations: http://www.emanueleferonato.com/2009/09/08/color-difference-algorithm-part-2/

struct XYZ
{
    double x;
    double y;
    double z;
};

struct LAB
{
    double L;
    double a;
    double b;
};

//#define TEST_MATH

#ifdef TEST_MATH
static int iter1;
static double div = 3;
#endif
static int MAXITERATIONS = 200;
static double sqrt(double a)
{
   #ifndef TEST_MATH
      double div;
      int iter1;

      div = 3.0;
      iter1 = 0;
   #endif
   if (a <= 0) {
      return 0;
   }

   double e = a / 2.0;
   double inc = 1;

   while (true) {
      double v = e * e;
      if (v < a) {
         break;
      }
      e = e / 2.0;
      if (e < .1) {
         break;
      }
   }

   while (true) {
      ++iter1;
      if (iter1 > MAXITERATIONS) {
         //say("TOO MANY ITERATIONS");
         return 0;
      }
      double v = e * e;
      double d = abs(a - v);
      if (d < 0.000001) {
         //say("1A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         return e;
      }
      if (v < a) {
         if (inc < 0) {
            //e -= inc;
            inc = -inc / div;
            //say("2A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         }
         e += inc;
      } else if (v > a) {
         if (inc > 0) {
            inc = -inc / div;
            //say("3A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         }
         e += inc;
      }
   }
   return 0;
}

static double cubert(double a)
{
   #ifndef TEST_MATH
   double div;
   int iter1;

   div = 4.0;
   iter1 = 0;
   #endif

   if (a <= 0) {
      return 0;
   }

   double e = a / 2.0;
   double inc = 1;

   while (true) {
      double v = e * e * e;
      if (v < a) {
         break;
      }
      e = e / 2.0;
      if (e < 1) {
         break;
      }
   }
   while (true) {
      ++iter1;
      if (iter1 > MAXITERATIONS) {
         //say("TOO MANY ITERATIONS");
         return 0;
      }
      double v = e * e * e;
      double d = abs(a - v);
      if (d < 0.000001) {
         //say("1A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         return e;
      }
      if (v < a) {
         if (inc < 0) {
            //e -= inc;
            inc = -inc / div;
            //say("2A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         }
         e += inc;
      } else if (v > a) {
         if (inc > 0) {
            inc = -inc / div;
            //say("3A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         }
         e += inc;
      }
   }
   return 0;
}

#ifdef TEST_MATH
_command void cubetest1() name_info(',')
{
   double a;

   int i;

   int total = 0;
   for (div = 10; div > 1; div--) {
      total = 0;
      int fail = 0;
      for (i = 0; i < 1; i += (1 / 400.0)) {
         iter1 = 0;
         sqrt(i);
         total += iter1;
         if (iter1 > 100) {
            fail++;
         }
      }
      dbgsay("Total Iter: " total ", Average = " ((total * 1.0) / 400) ", Fails=" fail ", Div=" div);
   }
}
#endif

static double matrix[]=
{ 
    0.49,    0.31,    0.20,
    0.17697, 0.81240, 0.01063,
    0.0,     0.01,    0.99
};

static double multy(double matrix[], double rgb[])[]
{
    double recip = 1 / 0.17697;
    int cols = rgb._length();
    int rows = matrix._length() / cols;

    int i;
    int row = 0;

    double output[];
    for (row = 0; row < rows; ++row)
    {
        output[row] = 0.0;
        for (i = 0; i < cols; ++i)
        {
            output[row] += matrix[row * cols + i] * rgb[i];
        }

        output[row] *= recip;
    }
    return output;
}

static XYZ rgb_to_xyz(int rgb)
{
    int    red    = rgb          & 0xff;
    int    green  = (rgb         & 0xff00)   >> 8;
    int    blue   = (rgb         & 0xff0000) >> 16;

    double rgbArray[];

    rgbArray[0] = red/255.0;
    rgbArray[1] = green/255.0;
    rgbArray[2] = blue/255.0;

    double xyz[] = multy(matrix, rgbArray);

    XYZ xyz1;
    xyz1.x = xyz[0];
    xyz1.y = xyz[1];
    xyz1.z = xyz[2];
    return xyz1;
}

static LAB xyz_to_lab(XYZ &xyz)
{
    double _x = xyz.x/95.047;
    double _y = xyz.y/100;
    double _z = xyz.z/108.883;

    if (_x>0.008856)
    {
        _x = cubert(_x); //pow(_x,1/3);
    }
    else
    {
        _x = 7.787*_x + 16/116;
    }
    if (_y>0.008856)
    {
        _y = cubert(_y); //(_y,1/3);
    }
    else
    {
        _y = (7.787*_y) + (16/116);
    }
    if (_z>0.008856)
    {
        _z = cubert(_z); //(_z,1/3);
    }
    else
    {
        _z = 7.787*_z + 16/116;
    }
    LAB lab;
    lab.L = 116*_y -16;
    lab.a = 500*(_x-_y);
    lab.b = 200*(_y-_z);
    return lab;
}

static double de_1994(LAB &lab1, LAB &lab2)
{
    double c1 = sqrt(lab1.a*lab1.a+lab1.b*lab1.b);
    double c2 = sqrt(lab2.a*lab2.a+lab2.b*lab2.b);
    double dc = c1-c2;
    double dl = lab1.L-lab2.L;
    double da = lab1.a-lab2.a;
    double db = lab1.b-lab2.b;
    double dh = sqrt((da*da)+(db*db)-(dc*dc));
    double first = dl;
    double second = dc/(1+0.045*c1);
    double third = dh/(1+0.015*c1);
    return(sqrt(first*first+second*second+third*third));
}

double sym_get_color_delta(int c1, int c2)
{
    XYZ xyz1 = rgb_to_xyz(c1);
    XYZ xyz2 = rgb_to_xyz(c2);

    LAB lab1 = xyz_to_lab(xyz1);
    LAB lab2 = xyz_to_lab(xyz2);

    double delta = de_1994(lab1, lab2);

    return delta;
}
