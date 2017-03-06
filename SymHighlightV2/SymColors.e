////////////////////////////////////////////////////////////////////////////////////
// Revision: 1 
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
#pragma pedantic on
#pragma strict on
#pragma strict2 on

#define RGB(r, g, b) (((b)<<16)|((g)<<8)|(r))
#define INIT_SYMCOLOR(r,g,b,name) {RGB(r,g,b),name}
#define FEWCOLORS

struct ColorDefinition
{
    int m_rgb;
    _str m_name;
    int m_cRef;
};


#ifdef FEWCOLORS
static ColorDefinition g_ColorDefinitions[] =
{
    INIT_SYMCOLOR(0xF0, 0xF8, 0xFF, "AliceBlue"),
    INIT_SYMCOLOR(0xFA, 0xEB, 0xD7, "AntiqueWhite"),
    INIT_SYMCOLOR(0x7F, 0xFF, 0xD4, "Aquamarine"),
    INIT_SYMCOLOR(0xF0, 0xFF, 0xFF, "Azure"),
    INIT_SYMCOLOR(0xF5, 0xF5, 0xDC, "Beige"),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xC4, "Bisque"),
    INIT_SYMCOLOR(0x00, 0x00, 0x00, "Black"),
    INIT_SYMCOLOR(0xFF, 0xEB, 0xCD, "BlanchedAlmond"),
    INIT_SYMCOLOR(0x00, 0x00, 0xFF, "Blue"),
    INIT_SYMCOLOR(0x8A, 0x2B, 0xE2, "BlueViolet"),
    INIT_SYMCOLOR(0xA5, 0x2A, 0x2A, "Brown"),
    INIT_SYMCOLOR(0xDE, 0xB8, 0x87, "BurlyWood"),
    INIT_SYMCOLOR(0x8B, 0x45, 0x13, "SaddleBrown"),
    INIT_SYMCOLOR(0xFA, 0x80, 0x72, "Salmon"),
    INIT_SYMCOLOR(0xF4, 0xA4, 0x60, "SandyBrown"),
    INIT_SYMCOLOR(0x5F, 0x9E, 0xA0, "CadetBlue")
};
#else
static ColorDefinition g_ColorDefinitions[] =
{
    INIT_SYMCOLOR(0xF0, 0xF8, 0xFF, "AliceBlue"),
    INIT_SYMCOLOR(0xFA, 0xEB, 0xD7, "AntiqueWhite"),
    INIT_SYMCOLOR(0x7F, 0xFF, 0xD4, "Aquamarine"),
    INIT_SYMCOLOR(0xF0, 0xFF, 0xFF, "Azure"),
    INIT_SYMCOLOR(0xF5, 0xF5, 0xDC, "Beige"),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xC4, "Bisque"),
    INIT_SYMCOLOR(0x00, 0x00, 0x00, "Black"),
    INIT_SYMCOLOR(0xFF, 0xEB, 0xCD, "BlanchedAlmond"),
    INIT_SYMCOLOR(0x00, 0x00, 0xFF, "Blue"),
    INIT_SYMCOLOR(0x8A, 0x2B, 0xE2, "BlueViolet"),
    INIT_SYMCOLOR(0xA5, 0x2A, 0x2A, "Brown"),
    INIT_SYMCOLOR(0xDE, 0xB8, 0x87, "BurlyWood"),
    INIT_SYMCOLOR(0x5F, 0x9E, 0xA0, "CadetBlue"),
    INIT_SYMCOLOR(0x7F, 0xFF, 0x00, "Chartreuse"),
    INIT_SYMCOLOR(0xD2, 0x69, 0x1E, "Chocolate"),
    INIT_SYMCOLOR(0xFF, 0x7F, 0x50, "Coral"),
    INIT_SYMCOLOR(0x64, 0x95, 0xED, "CornflowerBlue"),
    INIT_SYMCOLOR(0xFF, 0xF8, 0xDC, "Cornsilk"),
    INIT_SYMCOLOR(0xDC, 0x14, 0x3C, "Crimson"),
    INIT_SYMCOLOR(0x00, 0xFF, 0xFF, "Cyan"),
    INIT_SYMCOLOR(0x00, 0x00, 0x8B, "DarkBlue"),
    INIT_SYMCOLOR(0x00, 0x8B, 0x8B, "DarkCyan"),
    INIT_SYMCOLOR(0xB8, 0x86, 0x0B, "DarkGoldenRod"),
    INIT_SYMCOLOR(0xA9, 0xA9, 0xA9, "DarkGray"),
    INIT_SYMCOLOR(0x00, 0x64, 0x00, "DarkGreen"),
    INIT_SYMCOLOR(0xBD, 0xB7, 0x6B, "DarkKhaki"),
    INIT_SYMCOLOR(0x8B, 0x00, 0x8B, "DarkMagenta"),
    INIT_SYMCOLOR(0x55, 0x6B, 0x2F, "DarkOliveGreen"),
    INIT_SYMCOLOR(0xFF, 0x8C, 0x00, "DarkOrange"),
    INIT_SYMCOLOR(0x99, 0x32, 0xCC, "DarkOrchid"),
    INIT_SYMCOLOR(0x8B, 0x00, 0x00, "DarkRed"),
    INIT_SYMCOLOR(0xE9, 0x96, 0x7A, "DarkSalmon"),
    INIT_SYMCOLOR(0x8F, 0xBC, 0x8F, "DarkSeaGreen"),
    INIT_SYMCOLOR(0x48, 0x3D, 0x8B, "DarkSlateBlue"),
    INIT_SYMCOLOR(0x2F, 0x4F, 0x4F, "DarkSlateGray"),
    INIT_SYMCOLOR(0x00, 0xCE, 0xD1, "DarkTurquoise"),
    INIT_SYMCOLOR(0x94, 0x00, 0xD3, "DarkViolet"),
    INIT_SYMCOLOR(0xFF, 0x14, 0x93, "DeepPink"),
    INIT_SYMCOLOR(0x00, 0xBF, 0xFF, "DeepSkyBlue"),
    INIT_SYMCOLOR(0x69, 0x69, 0x69, "DimGray"),
    INIT_SYMCOLOR(0x1E, 0x90, 0xFF, "DodgerBlue"),
    INIT_SYMCOLOR(0xB2, 0x22, 0x22, "FireBrick"),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xF0, "FloralWhite"),
    INIT_SYMCOLOR(0x22, 0x8B, 0x22, "ForestGreen"),
    INIT_SYMCOLOR(0xDC, 0xDC, 0xDC, "Gainsboro"),
    INIT_SYMCOLOR(0xF8, 0xF8, 0xFF, "GhostWhite"),
    INIT_SYMCOLOR(0xFF, 0xD7, 0x00, "Gold"),
    INIT_SYMCOLOR(0xDA, 0xA5, 0x20, "GoldenRod"),
    INIT_SYMCOLOR(0x80, 0x80, 0x80, "Gray"),
    INIT_SYMCOLOR(0x00, 0x80, 0x00, "Green"),
    INIT_SYMCOLOR(0xAD, 0xFF, 0x2F, "GreenYellow"),
    INIT_SYMCOLOR(0xF0, 0xFF, 0xF0, "HoneyDew"),
    INIT_SYMCOLOR(0xFF, 0x69, 0xB4, "HotPink"),
    INIT_SYMCOLOR(0xCD, 0x5C, 0x5C, "IndianRed"),
    INIT_SYMCOLOR(0x4B, 0x00, 0x82, "Indigo"),
    INIT_SYMCOLOR(0xFF, 0xFF, 0xF0, "Ivory"),
    INIT_SYMCOLOR(0xF0, 0xE6, 0x8C, "Khaki"),
    INIT_SYMCOLOR(0xE6, 0xE6, 0xFA, "Lavender"),
    INIT_SYMCOLOR(0xFF, 0xF0, 0xF5, "LavenderBlush"),
    INIT_SYMCOLOR(0x7C, 0xFC, 0x00, "LawnGreen"),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xCD, "LemonChiffon"),
    INIT_SYMCOLOR(0xAD, 0xD8, 0xE6, "LightBlue"),
    INIT_SYMCOLOR(0xF0, 0x80, 0x80, "LightCoral"),
    INIT_SYMCOLOR(0xE0, 0xFF, 0xFF, "LightCyan"),
    INIT_SYMCOLOR(0xFA, 0xFA, 0xD2, "LightGoldenRodYellow"),
    INIT_SYMCOLOR(0xD3, 0xD3, 0xD3, "LightGray"),
    INIT_SYMCOLOR(0x90, 0xEE, 0x90, "LightGreen"),
    INIT_SYMCOLOR(0xFF, 0xB6, 0xC1, "LightPink"),
    INIT_SYMCOLOR(0xFF, 0xA0, 0x7A, "LightSalmon"),
    INIT_SYMCOLOR(0x20, 0xB2, 0xAA, "LightSeaGreen"),
    INIT_SYMCOLOR(0x87, 0xCE, 0xFA, "LightSkyBlue"),
    INIT_SYMCOLOR(0x77, 0x88, 0x99, "LightSlateGray"),
    INIT_SYMCOLOR(0xB0, 0xC4, 0xDE, "LightSteelBlue"),
    INIT_SYMCOLOR(0xFF, 0xFF, 0xE0, "LightYellow"),
    INIT_SYMCOLOR(0x00, 0xFF, 0x00, "Lime"),
    INIT_SYMCOLOR(0x32, 0xCD, 0x32, "LimeGreen"),
    INIT_SYMCOLOR(0xFA, 0xF0, 0xE6, "Linen"),
    INIT_SYMCOLOR(0xFF, 0x00, 0xFF, "Magenta"),
    INIT_SYMCOLOR(0x80, 0x00, 0x00, "Maroon"),
    INIT_SYMCOLOR(0x66, 0xCD, 0xAA, "MediumAquaMarine"),
    INIT_SYMCOLOR(0x00, 0x00, 0xCD, "MediumBlue"),
    INIT_SYMCOLOR(0xBA, 0x55, 0xD3, "MediumOrchid"),
    INIT_SYMCOLOR(0x93, 0x70, 0xDB, "MediumPurple"),
    INIT_SYMCOLOR(0x3C, 0xB3, 0x71, "MediumSeaGreen"),
    INIT_SYMCOLOR(0x7B, 0x68, 0xEE, "MediumSlateBlue"),
    INIT_SYMCOLOR(0x00, 0xFA, 0x9A, "MediumSpringGreen"),
    INIT_SYMCOLOR(0x48, 0xD1, 0xCC, "MediumTurquoise"),
    INIT_SYMCOLOR(0xC7, 0x15, 0x85, "MediumVioletRed"),
    INIT_SYMCOLOR(0x19, 0x19, 0x70, "MidnightBlue"),
    INIT_SYMCOLOR(0xF5, 0xFF, 0xFA, "MintCream"),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xE1, "MistyRose"),
    INIT_SYMCOLOR(0xFF, 0xE4, 0xB5, "Moccasin"),
    INIT_SYMCOLOR(0xFF, 0xDE, 0xAD, "NavajoWhite"),
    INIT_SYMCOLOR(0x00, 0x00, 0x80, "Navy"),
    INIT_SYMCOLOR(0xFD, 0xF5, 0xE6, "OldLace"),
    INIT_SYMCOLOR(0x80, 0x80, 0x00, "Olive"),
    INIT_SYMCOLOR(0x6B, 0x8E, 0x23, "OliveDrab"),
    INIT_SYMCOLOR(0xFF, 0xA5, 0x00, "Orange"),
    INIT_SYMCOLOR(0xFF, 0x45, 0x00, "OrangeRed"),
    INIT_SYMCOLOR(0xDA, 0x70, 0xD6, "Orchid"),
    INIT_SYMCOLOR(0xEE, 0xE8, 0xAA, "PaleGoldenRod"),
    INIT_SYMCOLOR(0x98, 0xFB, 0x98, "PaleGreen"),
    INIT_SYMCOLOR(0xAF, 0xEE, 0xEE, "PaleTurquoise"),
    INIT_SYMCOLOR(0xDB, 0x70, 0x93, "PaleVioletRed"),
    INIT_SYMCOLOR(0xFF, 0xEF, 0xD5, "PapayaWhip"),
    INIT_SYMCOLOR(0xFF, 0xDA, 0xB9, "PeachPuff"),
    INIT_SYMCOLOR(0xCD, 0x85, 0x3F, "Peru"),
    INIT_SYMCOLOR(0xFF, 0xC0, 0xCB, "Pink"),
    INIT_SYMCOLOR(0xDD, 0xA0, 0xDD, "Plum"),
    INIT_SYMCOLOR(0xB0, 0xE0, 0xE6, "PowderBlue"),
    INIT_SYMCOLOR(0x80, 0x00, 0x80, "Purple"),
    INIT_SYMCOLOR(0x66, 0x33, 0x99, "RebeccaPurple"),
    INIT_SYMCOLOR(0xFF, 0x00, 0x00, "Red"),
    INIT_SYMCOLOR(0xBC, 0x8F, 0x8F, "RosyBrown"),
    INIT_SYMCOLOR(0x41, 0x69, 0xE1, "RoyalBlue"),
    INIT_SYMCOLOR(0x8B, 0x45, 0x13, "SaddleBrown"),
    INIT_SYMCOLOR(0xFA, 0x80, 0x72, "Salmon"),
    INIT_SYMCOLOR(0xF4, 0xA4, 0x60, "SandyBrown"),
    INIT_SYMCOLOR(0x2E, 0x8B, 0x57, "SeaGreen"),
    INIT_SYMCOLOR(0xFF, 0xF5, 0xEE, "SeaShell"),
    INIT_SYMCOLOR(0xA0, 0x52, 0x2D, "Sienna"),
    INIT_SYMCOLOR(0xC0, 0xC0, 0xC0, "Silver"),
    INIT_SYMCOLOR(0x87, 0xCE, 0xEB, "SkyBlue"),
    INIT_SYMCOLOR(0x6A, 0x5A, 0xCD, "SlateBlue"),
    INIT_SYMCOLOR(0x70, 0x80, 0x90, "SlateGray"),
    INIT_SYMCOLOR(0xFF, 0xFA, 0xFA, "Snow"),
    INIT_SYMCOLOR(0x00, 0xFF, 0x7F, "SpringGreen"),
    INIT_SYMCOLOR(0x46, 0x82, 0xB4, "SteelBlue"),
    INIT_SYMCOLOR(0xD2, 0xB4, 0x8C, "Tan"),
    INIT_SYMCOLOR(0x00, 0x80, 0x80, "Teal"),
    INIT_SYMCOLOR(0xD8, 0xBF, 0xD8, "Thistle"),
    INIT_SYMCOLOR(0xFF, 0x63, 0x47, "Tomato"),
    INIT_SYMCOLOR(0x40, 0xE0, 0xD0, "Turquoise"),
    INIT_SYMCOLOR(0xEE, 0x82, 0xEE, "Violet"),
    INIT_SYMCOLOR(0xF5, 0xDE, 0xB3, "Wheat"),
    INIT_SYMCOLOR(0xFF, 0xFF, 0xFF, "White"),
    INIT_SYMCOLOR(0xF5, 0xF5, 0xF5, "WhiteSmoke"),
    INIT_SYMCOLOR(0xFF, 0xFF, 0x00, "Yellow"),
    INIT_SYMCOLOR(0x9A, 0xCD, 0x32, "YellowGreen")
};
#endif

static double computeDelta(int fg, ColorDefinition &colorDef)
{
    int c1 = fg;
    int c2 = colorDef.m_rgb;
    double delta = sym_get_color_delta(c1, c2);
    //dbgsay("Delta Color: " colorDef.m_name ", FG: " dec2hex(fg) ", C2: " dec2hex(c2) ", Delta="delta);
    return delta;
}

static int _getTextColor(int &backGround)
{
    parse _default_color(CFG_WINDOW_TEXT) with auto fg auto bg auto fontFlags;

    backGround = (int) bg;
    return (int) fg;
}

#define MIN_BG_DELTA (1.0)
#define MIN_FG_DELTA (10.0)
static _str _getAnotherColor(int &colorIndex, int offset)
{
    double dbg;
    double dfg;

    int bg;
    int fg = _getTextColor(bg);
    int count = 0;
    do
    {
        colorIndex = (colorIndex + offset) % g_ColorDefinitions._length();
        dbg = computeDelta(bg, g_ColorDefinitions[colorIndex]);
        dfg = computeDelta(fg, g_ColorDefinitions[colorIndex]);
        if (dbg > MIN_BG_DELTA)
        {
            if (dfg > MIN_FG_DELTA)
            {
                break;
            }
        }
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
static int g_ColorIndex;

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
            say("Index is " index);
            int markerIndex = g_SymbolColors:[index].getScrollMarkerIndex();
            if (markerIndex != -1)
            {
                _ScrollMarkupRemoveAllType(markerIndex);
            }
        }
        else
        {
            say("INVALID Index is " index);
        }
    }
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


