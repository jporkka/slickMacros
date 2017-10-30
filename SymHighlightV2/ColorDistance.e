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
static int MAXITERATIONS = 2000;
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

double nroot(double a, double root)
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
      double v = pow(e, root);
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
      double v = pow(e, root) * 1.0;
      double d = abs(a - v);
      //say("1A: " a ", E: " e ", V=" v ", Inc=" inc ", d=" d", iter=" iter1);
      if (d < 0.000001) {
         //say("1A: " a ", E: " e ", V=" v ", Inc=" inc ", iter=" iter1);
         return e;
      }
      if (d > 100*100) {
         inc *= div;
      }

      if (iter1 > MAXITERATIONS) {
         dbgsay("TOO MANY ITERATIONS d="d", inc="inc);
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
   //say("zero");
   return 0;
}

double jpow(double a, double n, double d)
{
   double p = nroot(a, d);
   double r = pow(p, n);
   return r;
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

static XYZ rgb_to_xyz2(int rgb)
{
    int    red    = rgb          & 0xff;
    int    green  = (rgb         & 0xff00)   >> 8;
    int    blue   = (rgb         & 0xff0000) >> 16;

    double rgbArray[];

    rgbArray[0] = red   / 255.0;
    rgbArray[1] = green / 255.0;
    rgbArray[2] = blue  / 255.0;

    double xyz[] = multy(matrix, rgbArray);

    XYZ xyz1;
    xyz1.x = xyz[0];
    xyz1.y = xyz[1];
    xyz1.z = xyz[2];
    return xyz1;
}

static XYZ rgb_to_xyz(int rgb)
{
    double red    = (rgb          & 0xff) / 255.0;
    double green  = ((rgb         & 0xff00)   >> 8) / 255.0;
    double blue   = ((rgb         & 0xff0000) >> 16) / 255.0;

    if(red>0.04045){
        red = (red+0.055)/1.055;
        red = jpow(red,12, 5); // 2.4
    }
    else{
        red = red/12.92;
    }
    if(green>0.04045){
        green = (green+0.055)/1.055;
        green = jpow(green, 12, 5); // 2.4
    }
    else{
        green = green/12.92;
    }
    if(blue>0.04045){
        blue = (blue+0.055)/1.055;
        blue = jpow(blue,12, 5);
    }
    else{
        blue = blue/12.92;
    }
    red *= 100;
    green *= 100;
    blue *= 100;
    XYZ xyz1;
    xyz1.x = red * 0.4124 + green * 0.3576 + blue * 0.1805;
    xyz1.y = red * 0.2126 + green * 0.7152 + blue * 0.0722;
    xyz1.z = red * 0.0193 + green * 0.1192 + blue * 0.9505;
    return xyz1;
}

static LAB xyz_to_lab(XYZ &xyz)
{
    double x = xyz.x/95.047;
    double y = xyz.y/100;
    double z = xyz.z/108.883;

    if (x>0.008856)
    {
        x = cubert(x); //pow(x,1/3);
    }
    else
    {
        x = 7.787*x + 16.0/116.0;
    }
    if (y>0.008856)
    {
        y = cubert(y); //(y,1/3);
    }
    else
    {
        y = (7.787*y) + (16.0/116.0);
    }
    if (z>0.008856)
    {
        z = cubert(z); //(z,1/3);
    }
    else
    {
        z = 7.787*z + 16.0/116.0;
    }
    LAB lab;
    lab.L = 116.0 * y - 16;
    lab.a = 500.0 * (x - y);
    lab.b = 200.0 * (y - z);
    return lab;
}

static double de_1994(LAB &lab1, LAB &lab2)
{
    double kl = 1.0;
    double sl = 1.0;
    double k1 = 0.045;
    double k2 = 0.015;
    double kc = 1.0;
    double kh = 1.0;

    double c1 = sqrt(lab1.a*lab1.a+lab1.b*lab1.b);  // C1 = sqrt(a1^2 + b1^2)
    double c2 = sqrt(lab2.a*lab2.a+lab2.b*lab2.b);  // C2 = sqrt(a2^2 + b2^2)
    double dc = c1-c2;           // ∆C
    double dl = lab1.L - lab2.L; // ∆L
    double da = lab1.a - lab2.a; // ∆a
    double db = lab1.b - lab2.b; // ∆b
    double dh = sqrt((da * da) + (db * db) - (dc * dc)); // ∆H = sqrt(∆a^2 + ∆b^2 - ∆c^2)

    double sc = 1 + k1 * c1;
    double sh = 1 + k2 * c1;
    double first  = dl / (kl * sl);
    double second = dc / (kc * sc);
    double third  = dh / (kh * sh);
    return sqrt(first * first + second * second + third * third);
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
