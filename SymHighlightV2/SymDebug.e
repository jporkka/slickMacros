////////////////////////////////////////////////////////////////////////////////////
// Revision: 1 
////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#import "slick.sh"
#include "slickCompat.h"

//#define DEBUGGING

boolean getF()
{
    return 1;
}

void wordselectsay(_str msg)
{
    _SccDisplayOutput("DLG: " msg, false, false, false);
//    _message_box(msg);
//    say("DLG: " msg);
}

void dlgsay(_str msg)
{
//    _SccDisplayOutput("DLG: " msg, false, false, false);
//    _message_box(msg);
//    say("DLG: " msg);
}

void dbgsayc(_str msg)
{
//    _SccDisplayOutput("DBG: " msg);
//    _message_box(msg);
//    say("SYM: " msg);
}

void dbgsay(_str msg)
{
//    _SccDisplayOutput("DBG: " msg);
//    _message_box(msg);
//    say("SYM: " msg);
}

void dbgsayv(_str msg)
{
//    _SccDisplayOutput("DBGV: " msg);
//    _message_box(msg);
//    say("SYM: " msg);
}

void initsay(_str msg)
{
//    _SccDisplayOutput("INIT: " msg);
//    _message_box(msg);
//    say("SYM: " msg);
}


