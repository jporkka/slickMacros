////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#import "slick.sh"
#import "markers.sh"
#import "ColorDistance.e"
#import "SymDebug.e"
#import "sc/lang/IHashTable.e"
#include "SlickCompat.sh"

#define RGB(r, g, b) (((b)<<16)|((g)<<8)|(r))
#define INIT_SYMCOLOR(r,g,b,name, scheme) {RGB(r,g,b),name,scheme}


#define SCHEME_DARK  0x0001
#define SCHEME_LIGHT 0x0100

struct ColorDefinition
{
    int m_rgb;
    _str m_name;
    int m_SchemeBits;
    int m_cRef;
};


int g_ColorIndex=999;

static bool _isDarkColorBackground() {
   typeless value;
   parse _default_color(CFG_WINDOW_TEXT) with . value .;
   value=_dec2hex(value,16);
   typeless bg_r=strip(substr(value,1,2));
   typeless bg_g=strip(substr(value,3,2));
   typeless bg_b=strip(substr(value,5,2));
   bg_r=_hex2dec(bg_r,16);
   bg_g=_hex2dec(bg_g,16);
   bg_b=_hex2dec(bg_b,16);
   if (!isinteger(bg_r)) bg_r=0;
   if (!isinteger(bg_g)) bg_g=0;
   if (!isinteger(bg_b)) bg_b=0;
   result:= (bg_r<90 && bg_g<90 && bg_b<90);
   return result;
}

#if 1
static ColorDefinition g_ColorDefinitions[] =
{
// Hand pick colors
    INIT_SYMCOLOR(0x00, 0x80, 0x00, "Green",                SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x99, 0x32, 0xCC, "DarkOrchid",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xBF, 0xFF, "DeepSkyBlue",          SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xBD, 0xB7, 0x6B, "DarkKhaki",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xA0, 0x52, 0x2D, "Sienna",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xFA, 0x9A, "MediumSpringGreen",    SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x00, 0xFF, "Magenta",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x87, 0xCE, 0xFA, "LightSkyBlue",         SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xF4, 0xA4, 0x60, "SandyBrown",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x69, 0x69, 0x69, "DimGray",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x20, 0xB2, 0xAA, "LightSeaGreen",        SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xEE, 0x82, 0xEE, "Violet",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x40, 0xE0, 0xD0, "Turquoise",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x63, 0x47, "Tomato",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x8B, 0x00, 0x00, "DarkRed",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xFF, 0x00, "Lime",                 SCHEME_LIGHT |  SCHEME_DARK )
};
#else
static ColorDefinition g_ColorDefinitions[] =
{
/// Sorted from light to dark.
    INIT_SYMCOLOR(0xFF, 0xFF, 0xFF, "White",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xFA, "Snow",                 SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF8, 0xF8, 0xFF, "GhostWhite",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF5, 0xFF, 0xFA, "MintCream",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFF, 0xF0, "Ivory",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF0, 0xFF, 0xFF, "Azure",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xF0, "FloralWhite",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF0, 0xF8, 0xFF, "AliceBlue",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xF0, 0xF5, "LavenderBlush",        SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xF5, 0xEE, "SeaShell",             SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF5, 0xF5, 0xF5, "WhiteSmoke",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF0, 0xFF, 0xF0, "HoneyDew",             SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFF, 0xE0, "LightYellow",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xE0, 0xFF, 0xFF, "LightCyan",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFD, 0xF5, 0xE6, "OldLace",              SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xF8, 0xDC, "Cornsilk",             SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFA, 0xF0, 0xE6, "Linen",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xCD, "LemonChiffon",         SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFA, 0xFA, 0xD2, "LightGoldenRodYellow", SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF5, 0xF5, 0xDC, "Beige",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xE6, 0xE6, 0xFA, "Lavender",             SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xE1, "MistyRose",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xEF, 0xD5, "PapayaWhip",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFA, 0xEB, 0xD7, "AntiqueWhite",         SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xEB, 0xCD, "BlanchedAlmond",       SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xC4, "Bisque",               SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xB5, "Moccasin",             SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xDC, 0xDC, 0xDC, "Gainsboro",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xDA, 0xB9, "PeachPuff",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xAF, 0xEE, 0xEE, "PaleTurquoise",        SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xC0, 0xCB, "Pink",                 SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xDE, 0xAD, "NavajoWhite",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF5, 0xDE, 0xB3, "Wheat",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xEE, 0xE8, 0xAA, "PaleGoldenRod",        SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xD3, 0xD3, 0xD3, "LightGray",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xB6, 0xC1, "LightPink",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xB0, 0xE0, 0xE6, "PowderBlue",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xD8, 0xBF, 0xD8, "Thistle",              SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xAD, 0xD8, 0xE6, "LightBlue",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xF0, 0xE6, 0x8C, "Khaki",                SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xEE, 0x82, 0xEE, "Violet",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xDD, 0xA0, 0xDD, "Plum",                 SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xB0, 0xC4, 0xDE, "LightSteelBlue",       SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x7F, 0xFF, 0xD4, "Aquamarine",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x87, 0xCE, 0xFA, "LightSkyBlue",         SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x87, 0xCE, 0xEB, "SkyBlue",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xC0, 0xC0, 0xC0, "Silver",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x98, 0xFB, 0x98, "PaleGreen",            SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xDA, 0x70, 0xD6, "Orchid",               SCHEME_DARK  ),
    INIT_SYMCOLOR(0xDE, 0xB8, 0x87, "BurlyWood",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x69, 0xB4, "HotPink",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0xA0, 0x7A, "LightSalmon",          SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xD2, 0xB4, 0x8C, "Tan",                  SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x90, 0xEE, 0x90, "LightGreen",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0x00, 0xFF, "Magenta",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xFF, 0xFF, "Cyan",                 SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xFF, 0xFF, 0x00, "Yellow",               SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xA9, 0xA9, 0xA9, "DarkGray",             SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xE9, 0x96, 0x7A, "DarkSalmon",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xF4, 0xA4, 0x60, "SandyBrown",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x40, 0xE0, 0xD0, "Turquoise",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xF0, 0x80, 0x80, "LightCoral",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFA, 0x80, 0x72, "Salmon",               SCHEME_DARK  ),
    INIT_SYMCOLOR(0x64, 0x95, 0xED, "CornflowerBlue",       SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x48, 0xD1, 0xCC, "MediumTurquoise",      SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xBA, 0x55, 0xD3, "MediumOrchid",         SCHEME_DARK  ),
    INIT_SYMCOLOR(0xBD, 0xB7, 0x6B, "DarkKhaki",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x93, 0x70, 0xDB, "MediumPurple",         SCHEME_DARK  ),
    INIT_SYMCOLOR(0xDB, 0x70, 0x93, "PaleVioletRed",        SCHEME_DARK  ),
    INIT_SYMCOLOR(0x66, 0xCD, 0xAA, "MediumAquaMarine",     SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xAD, 0xFF, 0x2F, "GreenYellow",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0xBC, 0x8F, 0x8F, "RosyBrown",            SCHEME_DARK  ),
    INIT_SYMCOLOR(0x8F, 0xBC, 0x8F, "DarkSeaGreen",         SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0xD7, 0x00, "Gold",                 SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x7B, 0x68, 0xEE, "MediumSlateBlue",      SCHEME_DARK  ),
    INIT_SYMCOLOR(0xFF, 0x7F, 0x50, "Coral",                SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xBF, 0xFF, "DeepSkyBlue",          SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x1E, 0x90, 0xFF, "DodgerBlue",           SCHEME_DARK  ),
    INIT_SYMCOLOR(0xFF, 0x63, 0x47, "Tomato",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x14, 0x93, "DeepPink",             SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0xA5, 0x00, "Orange",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xDA, 0xA5, 0x20, "GoldenRod",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xCE, 0xD1, "DarkTurquoise",        SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x5F, 0x9E, 0xA0, "CadetBlue",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x9A, 0xCD, 0x32, "YellowGreen",          SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x77, 0x88, 0x99, "LightSlateGray",       SCHEME_DARK  ),
    INIT_SYMCOLOR(0x8A, 0x2B, 0xE2, "BlueViolet",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x99, 0x32, 0xCC, "DarkOrchid",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0xFA, 0x9A, "MediumSpringGreen",    SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x6A, 0x5A, 0xCD, "SlateBlue",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xCD, 0x85, 0x3F, "Peru",                 SCHEME_DARK  ),
    INIT_SYMCOLOR(0x41, 0x69, 0xE1, "RoyalBlue",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x8C, 0x00, "DarkOrange",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xCD, 0x5C, 0x5C, "IndianRed",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x80, 0x80, 0x80, "Gray",                 SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x70, 0x80, 0x90, "SlateGray",            SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0xFF, 0x7F, "SpringGreen",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x7F, 0xFF, 0x00, "Chartreuse",           SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x20, 0xB2, 0xAA, "LightSeaGreen",        SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x46, 0x82, 0xB4, "SteelBlue",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x7C, 0xFC, 0x00, "LawnGreen",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x94, 0x00, 0xD3, "DarkViolet",           SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xC7, 0x15, 0x85, "MediumVioletRed",      SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x3C, 0xB3, 0x71, "MediumSeaGreen",       SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xD2, 0x69, 0x1E, "Chocolate",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xB8, 0x86, 0x0B, "DarkGoldenRod",        SCHEME_DARK  ),
    INIT_SYMCOLOR(0xFF, 0x45, 0x00, "OrangeRed",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x69, 0x69, 0x69, "DimGray",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x66, 0x33, 0x99, "RebeccaPurple",        SCHEME_DARK  ),
    INIT_SYMCOLOR(0x32, 0xCD, 0x32, "LimeGreen",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xDC, 0x14, 0x3C, "Crimson",              0            ),
    INIT_SYMCOLOR(0xA0, 0x52, 0x2D, "Sienna",               SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x6B, 0x8E, 0x23, "OliveDrab",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x8B, 0x00, 0x8B, "DarkMagenta",          SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0x8B, 0x8B, "DarkCyan",             SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x48, 0x3D, 0x8B, "DarkSlateBlue",        SCHEME_DARK  ),
    INIT_SYMCOLOR(0x2E, 0x8B, 0x57, "SeaGreen",             SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0x80, 0x80, "Teal",                 SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x80, 0x00, 0x80, "Purple",               SCHEME_DARK  ),
    INIT_SYMCOLOR(0x80, 0x80, 0x00, "Olive",                SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xFF, 0x00, 0x00, "Red",                  SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x00, 0xFF, 0x00, "Lime",                 SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0x00, 0xFF, "Blue",                 SCHEME_DARK  ),
    INIT_SYMCOLOR(0xA5, 0x2A, 0x2A, "Brown",                SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0xB2, 0x22, 0x22, "FireBrick",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x55, 0x6B, 0x2F, "DarkOliveGreen",       SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x8B, 0x45, 0x13, "SaddleBrown",          SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x22, 0x8B, 0x22, "ForestGreen",          SCHEME_LIGHT ),
    INIT_SYMCOLOR(0x4B, 0x00, 0x82, "Indigo",               SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0x00, 0xCD, "MediumBlue",           SCHEME_DARK  ),
    INIT_SYMCOLOR(0x2F, 0x4F, 0x4F, "DarkSlateGray",        SCHEME_DARK  ),
    INIT_SYMCOLOR(0x19, 0x19, 0x70, "MidnightBlue",         SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0x00, 0x8B, "DarkBlue",             SCHEME_DARK  ),
    INIT_SYMCOLOR(0x8B, 0x00, 0x00, "DarkRed",              SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x80, 0x00, 0x00, "Maroon",               SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0x00, 0x80, "Navy",                 SCHEME_DARK  ),
    INIT_SYMCOLOR(0x00, 0x80, 0x00, "Green",                SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0x64, 0x00, "DarkGreen",            SCHEME_LIGHT |  SCHEME_DARK ),
    INIT_SYMCOLOR(0x00, 0x00, 0x00, "Black",                0            )
};
////
#endif

int sortfn(ColorDefinition &t1, ColorDefinition &t2)
{
    int n1 = (t1.m_rgb>>16) + ((t1.m_rgb>>8)&0xff) + ((t1.m_rgb)&0xff)
    int n2 = (t2.m_rgb>>16) + ((t2.m_rgb>>8)&0xff) + ((t2.m_rgb)&0xff)
    return n2 - n1;
}

_str tohex(int n)
{
    return _dec2hex(n, 16, 2, 0)

}
_command sort_colors() name_info(','VSARG2_MACRO|VSARG2_MARK|VSARG2_REQUIRES_EDITORCTL)
{
    g_ColorDefinitions._sort("", 0, -1, sortfn);
    int i;
    for( i = 0; i < g_ColorDefinitions._length(); ++i)
    {
        int mask = 0;
        _str bits = "0";
        if (g_ColorDefinitions[i].m_SchemeBits == (SCHEME_LIGHT|SCHEME_DARK))
        {
            bits = "SCHEME_LIGHT | SCHEME_DARK";
            mask = SCHEME_LIGHT | SCHEME_DARK;
        }
        if (g_ColorDefinitions[i].m_SchemeBits == (SCHEME_LIGHT))
        {
            mask = SCHEME_LIGHT;
            bits = "SCHEME_LIGHT";
        }
        if (g_ColorDefinitions[i].m_SchemeBits == (SCHEME_DARK))
        {
            bits = "SCHEME_DARK";
        }

        say(nls('    INIT_SYMCOLOR(0x%s, 0x%s, 0x%s, "%s",     %s ),',
                tohex((g_ColorDefinitions[i].m_rgb)&0xff),
                tohex((g_ColorDefinitions[i].m_rgb>>8)&0xff),
                tohex(g_ColorDefinitions[i].m_rgb>>16),
                g_ColorDefinitions[i].m_name,
                bits));
    }
}

static double computeDelta(int fg, ColorDefinition &colorDef)
{
    int c1 = fg;
    int c2 = colorDef.m_rgb;
    double delta = sym_get_color_delta(c1, c2);
    double delta2 = sym_get_color_delta(c2, c1);
    dbgsayc("Delta Color: " colorDef.m_name ", FG: " dec2hex(fg) ", C2: " dec2hex(c2) ", Delta="delta", Delta2="delta2);
    return delta;
}

static int _getTextColor(int &backGround)
{
    parse _default_color(CFG_WINDOW_TEXT) with auto fg auto bg auto fontFlags;

    backGround = (int) bg;
    return (int) fg;
}

#define MIN_BG_DELTA (6.0)
#define MIN_FG_DELTA (10.0)
static _str _getAnotherColor(int &colorIndex, int offset)
{
    double dbg;
    double dfg;

    int bg;
    int fg = _getTextColor(bg);
    int count = 0;
    int schemeMask = _isDarkColorBackground() ? SCHEME_DARK : SCHEME_LIGHT;
    do
    {
        colorIndex = (colorIndex + offset);
        if (colorIndex >= g_ColorDefinitions._length())
        {
            colorIndex = 0;
        }

        if (colorIndex < 0)
        {
            colorIndex = g_ColorDefinitions._length() - 1;
        }

        if (g_ColorDefinitions[colorIndex].m_SchemeBits & schemeMask)
        {
                break;
            }
        break;
        ++count;
        //dbgsayc("colorIndex="colorIndex ", new colorIndex ="(colorIndex + offset) % g_ColorDefinitions._length());
    } while (count < g_ColorDefinitions._length());

    return g_ColorDefinitions[colorIndex].m_name;
}

_str ColorDeftoText(ColorDefinition &colorDef)
{
    return "ColorDef("dec2hex(colorDef.m_rgb)", '"colorDef.m_name"')"; 
}

class SymbolColor
{
    private int m_ColorDefIndex;
    private int m_ScrollMarkerType;
    private int m_ColorSymHighlight;
    _str toText()
    {
        return "SymbolColor("ColorDeftoText(g_ColorDefinitions[m_ColorDefIndex])", m_ScrollMarkerType:"m_ScrollMarkerType", m_ColorSymHighlight"m_ColorSymHighlight")";
    }

    SymbolColor(int colorDefIndex = -1)
    {
        m_ColorDefIndex = -1;
        m_ScrollMarkerType = -1;
        m_ColorSymHighlight = -1;
        //initsay("SymbolColor colorDefIndex="colorDefIndex);
        if (colorDefIndex >= 0)
        {
            m_ColorDefIndex = colorDefIndex;
        }
    }

    void reset()
    {
        initsay("SymbolColor reset colorDefIndex="m_ColorDefIndex);
    }

    boolean ensureColor()
    {
        if (m_ColorSymHighlight == -1)
        {
            parse _default_color(CFG_WINDOW_TEXT) with auto fg auto bg auto fontFlags;

            m_ColorSymHighlight = _AllocColor((int)fg, g_ColorDefinitions[m_ColorDefIndex].m_rgb, F_INHERIT_FG_COLOR);
            //_default_color(m_ColorSymHighlight, _rgb(0x00, 0x00, 0x00), g_ColorDefinitions[m_ColorDefIndex].m_rgb, 0);
            m_ScrollMarkerType = _ScrollMarkupAllocType()   ;

            _ScrollMarkupSetTypeColor(m_ScrollMarkerType, m_ColorSymHighlight);
            initsay("AllocColor Color:" g_ColorDefinitions[m_ColorDefIndex].m_name ", ColorIndex:"m_ColorSymHighlight);
            return true;
        }
        return false;
    }

    boolean free()
    {
        g_ColorDefinitions[m_ColorDefIndex].m_cRef -= 1;
        if (g_ColorDefinitions[m_ColorDefIndex].m_cRef == 0)
        {
            _mdi.p_child.p_window_id._FreeColor(m_ColorSymHighlight);
            m_ColorSymHighlight = -1;
        }
        if (g_ColorDefinitions[m_ColorDefIndex].m_cRef < 0)
        {
            dbgsay("ASSERT! m_cRef < 0 " g_ColorDefinitions[m_ColorDefIndex].m_cRef ", m_ColorDefIndex:"m_ColorDefIndex);
            return false;
        }
        return true;
    }

    void alloc()
    {
        g_ColorDefinitions[m_ColorDefIndex].m_cRef += 1;
        ensureColor();
        dbgsay("alloc m_cRef:" g_ColorDefinitions[m_ColorDefIndex].m_cRef ", m_ColorDefIndex:"m_ColorDefIndex);
    }

    int getColorIndex()
    {
        return m_ColorDefIndex;
    }
    int getMarkerIndex()
    {
        return m_ColorSymHighlight;
    }
    int getScrollMarkerIndex()
    {
        return m_ScrollMarkerType;
    }
    ColorDefinition *getColorDef()
    {
        return &g_ColorDefinitions[m_ColorDefIndex];
    }
};

static SymbolColor g_SymbolColors:[];

SymbolColor *sym_color_get(_str color)
{
    return g_SymbolColors._indexin(color);
}

void sym_color_reset()
{
    _str index;
    SymbolColor value;

    foreach ( index => value in g_SymbolColors )
    {
        g_SymbolColors:[index].reset();
    }

}

/*-------------------------------------------------------------------------------
    Removes scrollbar markers from this window
-------------------------------------------------------------------------------*/
void sym_color_remove_highlight_markers(int wid)
{
    _str index;
    SymbolColor value;

    foreach ( index => value in g_SymbolColors )
    {
        _ScrollMarkupRemoveType(wid, g_SymbolColors:[index].getScrollMarkerIndex());
    }
}

/*-------------------------------------------------------------------------------
    Removes scrollbar markers
-------------------------------------------------------------------------------*/
void sym_color_remove_all_highlight_marker_types()
{
    _str index;
    SymbolColor value;

    foreach ( index => value in g_SymbolColors )
    {
        if (g_SymbolColors._indexin(index) && g_SymbolColors:[index] != null)
        //if (g_SymbolColors._indexin(index) != null)
        {
            dbgsay("Index is " index);
            int markerIndex = g_SymbolColors:[index].getScrollMarkerIndex();
            if (markerIndex != -1)
            {
                _ScrollMarkupRemoveAllType(markerIndex);
            }
        }
        else
        {
            dbgsay("INVALID Index is " index);
        }
    }
}

_command void symtag_set_color_index(int index=0) name_info(',')
{
    g_ColorIndex = index;
}

_command int  symtag_get_color_index() name_info(',')
{
    return g_ColorIndex;
}

_str sym_color_get_new_color()
{
    return _getAnotherColor(g_ColorIndex, 1);
}

_str sym_color_get_next_color(_str color)
{
    int index = g_SymbolColors:[color].getColorIndex();
    return _getAnotherColor(index, 1);
}

_str sym_color_get_prev_color(_str color)
{
    int index = g_SymbolColors:[color].getColorIndex();
    return _getAnotherColor(index, -1);
}


_str sym_color_get_color_by_index(int index)
{
    if (index < 0 || index >= g_ColorDefinitions._length())
    {
        return null;
    }
    return g_ColorDefinitions[index].m_name;
}

boolean sym_color_is_valid_color(_str color)
{
    return g_SymbolColors._indexin(color) != null;
}

void sym_color_debug_dump_colordefs()
{
    int numColors = g_ColorDefinitions._length();
    int i;
    dbgsay("color defs numColors:"numColors);
    for (i = 0; i < numColors; ++i)
    {
        dbgsay("    " i ": ref:"g_ColorDefinitions[i].m_cRef ", name:"g_ColorDefinitions[i].m_name);
    }
}

static void _InitSymColor()
{
    //int num = g_SymbolColors._length();
    dbgsayc("_InitSymColor1");

    _str index;
    SymbolColor value;
    foreach ( index => value in g_SymbolColors )
    {
        //g_SymbolColors:[index].reset();
        //double delta = sym_get_color_delta(value.m_rgb, 0xffffff);
        //dbgsayc("Delta colors " value.m_name ", WHITE == " delta);
        //g_SymbolColors:[i].m_ColorSymHighlight = -1;
    }
}

static void initGlobals()
{
    g_SymbolColors = null;
    g_ColorIndex = 0;
}

static void DeferredSymInitC()
{
    int numColors = g_ColorDefinitions._length();
    int i;
    initsay("DeferredSymInitC numColors is " numColors);
    //for (i = 0; i < numColors; ++i)
    //{
    //    _str color = g_ColorDefinitions[i].m_name;
    //    g_SymbolColors:[color].alloc();
    //}
    _InitSymColor();
}

void sym_color_sym_initc()
{
    initsay("sym_color_sym_initc");
    initGlobals();

    int numColors = g_ColorDefinitions._length();
    int i;
    initsay("sym_color_sym_initc numColors=" numColors);
    g_SymbolColors = null;
    g_ColorIndex = 0;
    for (i = 0; i < numColors; ++i)
    {
        _str color = g_ColorDefinitions[i].m_name;
        g_ColorDefinitions[i].m_cRef = 0;
        SymbolColor c(i);
        initsay("sym_color_sym_initc i=" i ", color is " color);
        g_SymbolColors:[color] = c;
    }
    _post_call( DeferredSymInitC);
//    initsay("Len is " g_SymbolColors._hash_length());
}

static _str _ModuleName = "SymColors";
definit()
{
    if (arg(1) == "L")
    {
        initsay("defInit load "_ModuleName);
    }
    else
    {
        initsay("defInit none" _ModuleName);
    }
}

defload()
{
    initsay("defload " _ModuleName);
}


