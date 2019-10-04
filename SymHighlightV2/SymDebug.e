////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#import "slick.sh"
#include "slickCompat.h"

#define SYMTAG_DEBUG_TYPE_OUTPUT  0x0001
#define SYMTAG_DEBUG_TYPE_SAY     0x0002
#define SYMTAG_DEBUG_TYPE_MB      0x0004

#define SYMTAG_DEBUG_DLGSAY 0x0001
#define SYMTAG_DEBUG_DLGSAYC 0x0002
#define SYMTAG_DEBUG_SAY 0x0004
#define SYMTAG_DEBUG_SAYV 0x0008
#define SYMTAG_DEBUG_INITSAY 0x0010
#define SYMTAG_DEBUG_WORDSELECTSAY 0x0020

bool def_sym_enable_debug_print = false;
int def_sym_debug_print_filter = 0;
int def_sym_debug_print_type = SYMTAG_DEBUG_TYPE_OUTPUT;

boolean getF()
{
    return 1;
}

static void debugsay(int enabler, _str msg)
{
    if (def_sym_enable_debug_print && (def_sym_debug_print_filter & enabler)) {
        if (def_sym_debug_print_type & SYMTAG_DEBUG_TYPE_OUTPUT) {
            _SccDisplayOutput("DLG: " msg, false, false, false);
        }

        if (def_sym_debug_print_type & SYMTAG_DEBUG_TYPE_MB) {
            _message_box(msg);
        }

        if (def_sym_debug_print_type & SYMTAG_DEBUG_TYPE_SAY) {
            say("DLG: " msg);
        }
    }
}

void wordselectsay(_str msg)
{
    //say("wordselectsay " msg);
    debugsay(SYMTAG_DEBUG_WORDSELECTSAY, msg);
}

void dlgsay(_str msg)
{
    debugsay(SYMTAG_DEBUG_DLGSAY, msg);
}

void dbgsayc(_str msg)
{
    debugsay(SYMTAG_DEBUG_DLGSAYC, msg);
}

void dbgsay(_str msg)
{
    debugsay(SYMTAG_DEBUG_SAY, msg);
}

void dbgsayv(_str msg)
{
    debugsay(SYMTAG_DEBUG_SAYV, msg);
}

void initsay(_str msg)
{
    debugsay(SYMTAG_DEBUG_INITSAY, msg);
} 


