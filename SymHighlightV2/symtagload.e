#import "slick.sh"
#import "main.e"
#import "stdprocs.e"
#pragma pedantic on
#pragma strict on
#pragma strict2 on

static _str gRootPath = _ConfigPath();
static boolean joeLoad(_str moduleName)
{
    int status = load(gRootPath moduleName);
    if (status != 0)
    {
        say("Status " status " On load of " moduleName);
        return false;
    }
    //say("Status OK " " On load of " moduleName);
    return true;
}
static void SymTagload()
{
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
        ok = joeLoad("SymDebug.e");
    }
    else
    {
        execute("HighlightsDlgDef",'a');
        SymTagload();
    }
}

