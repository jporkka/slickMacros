#import "slick.sh"
#import "main.e"
#import "stdprocs.e"
#include "slickCompat.h"

static _str gRootPath;
static void joeUnload(_str name)
{
    if (pos(name, def_macfiles) > 0)
    {
        unload(name);
    }
}

static void SymTagUnload() 
{
    _str vslickpathfilename=slick_path_search("SymDebug.e","MS");
    path := _strip_filename(vslickpathfilename, "N");
    gRootPath = path;//_ConfigPath();
    joeUnload("HighlightDialog.ex");
    joeUnload("SymHighlightApi.ex");
    joeUnload("SymHighlightMain.ex");
    joeUnload("WordInfo.ex");
    joeUnload("SymColors.ex");
    joeUnload("ColorDistance.ex");
    joeUnload("SymDebug.ex");
}

void defmain()
{
    SymTagUnload();
    // Avoid bug in call_list -- it doesn't flush its
    // cache on module unload, so after unloading
    // everything, load one module to force the cache flush
    // then unload everything again.
    //execute("symtagload debug",'a');
    //SymTagUnload();
}

