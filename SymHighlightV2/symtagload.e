#import "slick.sh"
#import "main.e"
#import "stdprocs.e"
#include "slickCompat.h"

static _str gRootPath;
static boolean joeLoad(_str moduleName)
{
    _str fullname = gRootPath moduleName;
    //say("Loading "  gRootPath moduleName);
    int status = load(fullname);
    if (status != 0)
    {
        say("Status " status " On load of " gRootPath moduleName);
        return false;
    }
    //say("Status OK " " On load of " gRootPath moduleName);
    return true;
}
static void SymTagload()
{
    _str vslickpathfilename=slick_path_search("SymDebug.e","MS");
    path := _strip_filename(vslickpathfilename, "N");
    gRootPath = path;//_ConfigPath();
    boolean ok = true;
    if (ok)
    {
        ok = joeLoad("SymDebug.e");
    }
    if (ok)
    {
        ok = joeLoad("ColorDistance.e");
    }
    if (ok)
    {
        ok = joeLoad("SymColors.e");
    }
    if (ok)
    {
        ok = joeLoad("WordInfo.e");
    }
    if (ok)
    {
        ok = joeLoad("SymHighlightMain.e");
    }
    if (ok)
    {
        ok = joeLoad("SymHighlightApi.e");
    }
    if (ok)
    {
        ok = joeLoad("HighlightDialog.e");
    }
}

void defmain()
{
    if (arg(1) :== "debug")
    {
        ok := joeLoad("SymDebug.e");
    }
    else
    {
        execute("HighlightsDlgDef",'a');
        SymTagload();
    }
}

