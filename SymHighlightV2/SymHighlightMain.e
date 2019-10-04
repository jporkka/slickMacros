////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#import "slick.sh"
#import "main.e"
#import "stdprocs.e"
#import "sc/lang/IToString.e"
#import "sc/lang/IHashable.e"
#import "ColorDistance.e"
#import "markers.sh"
#import "SymColors.e"
#import "WordInfo.e"
#import "SymDebug.e"

#include "slickCompat.h"

//#define STREAM_LINE
#define USE_STREAM_MARKER
//#define USE_LINE_MARKER
//#define USE_SCROLL_MARKER

#define STREAM_MARKER_TYPE VSMARKERTYPEFLAG_DRAW_BOX
//#define STREAM_MARKER_TYPE VSMARKERTYPEFLAG_DRAW_FOCUS_RECT
//#define STREAM_MARKER_TYPE 0

#define SYMTAB_NOTIFY_DELWORD '_highlight_delword'
#define SYMTAB_NOTIFY_CLEAR   '_highlight_clear'
#define SYMTAB_NOTIFY_ADDWORD '_highlight_addword'
#define SYMTAB_NOTIFY_CYCLECOLOR '_highlight_cyclecolor'

WordInfo s_symTags:[];
boolean sym_debug_output = false;
_str s_searchString = null;
int s_timerSymHighlight = -1;
int s_markertypeSymHighlight = -1;

int def_sym_highlight_delay = 500; 
int def_sym_highlight_max_buffer_size = 250 * 1000 * 1000;
boolean def_sym_highlight_use_scrollmarkers = 1;
boolean def_sym_highlight_confirm_clear = 0;
boolean def_sym_highlight_persist_across_sessions = 0;

static int s_modtimeSymHighlight = 0; // Tracks changes to highlights and updates buffers with out of date highlights.
static boolean gSymAutoUpdate = true;
static boolean gSymUpdateTimer = false;
static _str s_bufferModTimeKey = "sym_tag_updatetime";

_command void symtag_toggle_word_select() name_info(',')
{
    if (!def_sym_enable_debug_print) {
        sym_debug_output = true;
        def_sym_enable_debug_print = true;
        def_sym_debug_print_filter |= SYMTAG_DEBUG_WORDSELECTSAY;
    } else {
        sym_debug_output = false;
        def_sym_enable_debug_print = false;
    }
}

static void clearSearchString()
{
    if (s_searchString != null)
    {
        s_modtimeSymHighlight += 1;
        s_searchString = null;
    }
}

static void createSearchString()
{
    s_searchString = '';

    WordInfo i;
    WordInfo sym;
    foreach ( i => sym in s_symTags )
    {
        if (sym.enabled())
        {
            _str sRegEx = "(" :+ sym.getRe() :+ ")";
            if (s_searchString :== "")
            {
                s_searchString = sRegEx;
            }
            else
            {
                s_searchString :+= '|' :+ sRegEx;
            }
        }
    }
    dbgsay("createSearchString: "s_searchString);
    s_modtimeSymHighlight += 1;
}

static SymbolColor *getSymColorFromTag(_str &key)
{
    if (s_symTags._indexin(key) && s_symTags:[key] != null)
    {
        WordInfo sym = s_symTags:[key];
        dbgsay("Found tag for " key", "sym.toText());
        return sym_color_get(sym.getColor());
    }
    dbgsay("WHOOPS! sym not found: " key);
    return null;
}

WordInfo *sym_get_wordinfo(_str &key)
{
    if (s_symTags._indexin(key) && s_symTags:[key] != null)
    {
        return &s_symTags:[key];
    }
    else
    {
        return null;
    }
}

boolean sym_add_symtag(WordInfo &sym)
{
    boolean fAdd = false;

    dbgsay("ADDSYMTAG " sym.getHashKey() ", Color is " sym.getColor());
    _str newColor = sym.getColor();
    if (newColor == "")
    {
        newColor = sym_color_get_new_color();
    }
    sym.setColor(""); // Prevent assignColorToSym() from freeing the color
    assignColorToSym(&sym, newColor);
    _str key = sym.getHashKey();
    if (length(key) != 0)
    {
        if (s_symTags._indexin(key) && s_symTags:[key] != null)
        {
            dbgsay("sym_add_symtag (replaced): " key);
        }
        else
        {
            dbgsay("sym_add_symtag (added): " key);
        }
        s_symTags:[key] = sym;
        clearSearchString();
    }
    return fAdd;
}

boolean sym_remove_symtag(_str key)
{
    dbgsay("sym_remove_symtag: " key);
    if (length(key) != 0)
    {
        SymbolColor *c = getSymColorFromTag(key);
        if (c != null)
        {
            if (!c->free())
            {
                dbgsay("sym_remove_symtag: Free failed on " key);
            }
        }
        s_symTags._deleteel(key);
        clearSearchString();
        return true;
    }
    return false;
}

static void assignColorToSym(WordInfo *sym, _str newColor)
{
    _str color = sym->getColor(); 
    SymbolColor *c = null;
    if (color != "")
    {
        c = sym_color_get(color);
    }

    SymbolColor *cNew = sym_color_get(newColor);
    cNew->alloc();
    sym->setColor(newColor);
    if (c != null)
    {
        if (!c->free())
        {
            dbgsay("assignColorToSym: Free failed on " sym->toText());
        }
    }
}

void sym_set_next_color_symtag(WordInfo *sym)
{
    _str newColor = sym_color_get_next_color(sym->getColor());
    assignColorToSym(sym, newColor);
} 

void sym_set_prev_color_symtag(WordInfo *sym)
{
    _str newColor = sym_color_get_prev_color(sym->getColor());
    assignColorToSym(sym, newColor);
} 

//////////////////////////////////////////////////////////
// Called from HighlightDialog
WordInfo sym_get_highlight_words():[]
{
    return s_symTags;
}

SymbolColor *sym_get_symcolor_from_sym(WordInfo &sym)
{
    return sym_color_get(sym.getColor());
}

/*----------------------------------------------------------------------------
   Goes through the current buffer and updates the highlights based on current
   information.
----------------------------------------------------------------------------*/
void sym_update_screen(boolean fNow, _str updateMethod="sym_symtag_update_window")
{
    int orig_view = p_window_id;
    int childId = _mdi.p_child;
    p_window_id = _mdi.p_child;
    //get_window_id( auto orig_view);
    //activate_window (_mdi.p_child);

    if (s_searchString == null)
    {
        createSearchString();
    }

    if (gSymAutoUpdate)
    {
        typeless modTime = _GetBufferInfoHt(s_bufferModTimeKey)
        if (modTime != s_modtimeSymHighlight )//|| fNow)
        {
            _SetBufferInfoHt(s_bufferModTimeKey, s_modtimeSymHighlight);
        
            for_each_mdi_child(updateMethod,'');
        }

    }
    //activate_window(orig_view); 
    p_window_id = orig_view;
}

void _switchbuf_tbhighlight(_str oldbuffname, _str flag, _str swold_pos=null, _str swold_buf_id= -1)
{
    if (flag=='Q') 
    {
        return; // Ignore buffers being closed.
    }
    int childId = _mdi.p_child;
    p_window_id = _mdi.p_child;

    if (s_searchString == null)
    {
        createSearchString();
    }
    typeless modTime = _GetBufferInfoHt(s_bufferModTimeKey)
    if (_isdiffed(p_buf_id))
    {
        //say("ISDIFF:"p_buf_name);
        //say("ISDIFF SwitchBuf update, Old:" swold_buf_id ", New:" p_buf_name);
    }
    else
    {
        //say("nodiff SwitchBuf update, Old:" oldbuffname ", New:" p_buf_name);
    }
    if (gSymAutoUpdate)
    {
        if (modTime == null || modTime != s_modtimeSymHighlight)
        {
            // _macro_call
            //say("SwitchBuf update, Old:" oldbuffname ", New:" p_buf_name);
            _SetBufferInfoHt(s_bufferModTimeKey, s_modtimeSymHighlight);
            sym_symtag_update_window();
        }
    }
}

// Capture the current word or current selection for highlighting.
WordInfo sym_get_curword_or_selection()
{
    int start_col = -1;
    int end_col = -1;
    boolean isSelection = false;
    _str word = "NOWORD";

    if ( !(_select_type() == "CHAR" || _select_type() == ""))
    {
        WordInfo wordInfo("", "", true);
        return wordInfo;
    }
    if (_select_type() == "CHAR")
    {
        int dummy;
        _str dummy2;
        int numLines;
        _get_selinfo(start_col, end_col, dummy, '', dummy2, dummy, dummy, numLines);
        if (numLines == 1 && start_col != end_col)
        {
            word = _expand_tabsc(start_col, end_col - start_col, 'S'); // TODO: If tabs are changed to spaces, then the string will never match will it?
            isSelection = true;
            WordInfo wordInfo(word, "", false);
            if (sym_debug_output)
            {
                wordselectsay("_get_selinfo1 start_col=" start_col \
                              ", end_col=" end_col \
                              ", p_col=" p_col \
                              ", numLines=" numLines \
                              ", curword is=" word \
                              ", p_word_chars=" p_word_chars \
                              ", _select_type()=" _select_type());
            }
            //wordselectsay("a1Sym is " :+ wordInfo.toString());
            return wordInfo;
        } else {
            if (sym_debug_output)
            {
                wordselectsay("_get_selinfo2 start_col=" start_col \
                              ", end_col=" end_col \
                              ", p_col=" p_col \
                              ", numLines=" numLines \
                              ", p_word_chars=" p_word_chars\
                              ", _select_type()=" _select_type());
            }
        }
    }

    word = cur_word(start_col);
    if (sym_debug_output)
    {
        wordselectsay("_get_selinfo3 start_col=" start_col \
                      ", end_col=" end_col \
                      ", p_col=" p_col \
                      ", curword is=" word \
                      ", p_word_chars=" p_word_chars \
                      ", _select_type()=" _select_type());
    }
    WordInfo wordInfo(word, "", true);
    if (sym_debug_output)
    {
        wordselectsay("a2Sym is " :+ wordInfo.toString());
    }
    return wordInfo;
}

static boolean isSystemBuffer()
{
    _str name = _mdi.p_child.p_buf_name;
    if (p_buf_flags & VSBUFFLAG_HIDDEN)
    {
        return true;
    }
    if (_isGrepBuffer(name) || name == '.process' )
    {
        return true;
    }
    if (_isInterleavedDiffBufferName(name) || _isDSBuffer(name))
    {
        return true;
    }
    //focus_wid._isEditorCtl()
    return false;
}

_command void symtag_next_tag() name_info(',')
{
    say(",...");
      _StreamMarkerFindList(auto markerIdList,p_window_id,_QROffset(),1000,-1000,s_markertypeSymHighlight);
      // markerId is the StreamMarkerIndex returned by _StreamMarkerAdd
      foreach (auto markerId in markerIdList) {
         _StreamMarkerGet(markerId, auto markerInfo);
         //VSSTREAMMARKERINFO
         // maybe strip off the symbol color prefix
         say("MARKER qr=" _QROffset() ", Marker.start=" markerInfo.StartOffset ", len" markerInfo.Length ", ColorIndex " markerInfo.ColorIndex ", markerId=" markerId);
      }
}
/*-------------------------------------------------------------------------------
    sym_symtag_update_window
-------------------------------------------------------------------------------*/
void sym_symtag_update_window()
{
//    say("sym_symtag_update_window Current WID is"p_window_id);
    if (p_object != OI_EDITOR)
    {
        ///say("sym_symtag_update_window Current Object is"p_object);
        return;
    }
    if (isSystemBuffer())
    {
        return;
    }

    if (p_buf_size > def_sym_highlight_max_buffer_size) 
    {
        dbgsay("Skip sym_symtag_update_window: " p_buf_size " : buf " p_buf_name);
        return;
    }

    typeless p,m,ss,sf,sw,sr,sf2;
    _save_pos2(p);
    save_selection(m);
    save_search(ss, sf, sw, sr, sf2);
    _StreamMarkerRemoveType(p_window_id, s_markertypeSymHighlight); // Remove all highlights from this window
    _LineMarkerRemoveType(p_window_id, s_markertypeSymHighlight);   // Remove all highlights from this window
    sym_color_remove_highlight_markers(p_window_id); // Remove all scrollbar marks from this window

    dbgsay("Update: " p_buf_name);

    if (s_symTags._length() != 0)
    {
        _str searchArgs;
        //  +   Forward Search
        //  E   Case sensitive search
        //  I   Case insensitive search
        //  <   Place cursor at beginning of string found.
        //  U   Perl regular expression
        //  @   No error message.
        //  XC  Not color
        //  CC  Require Color
        //searchArgs = '+,E,<,U,@,XCC';
        searchArgs = '+,E,<,U,@';
        _deselect();
        top();

        if ( s_searchString :!= '' && !search(s_searchString, searchArgs) )
        {
            dbgsay("==============================");
            do
            {
                boolean isRealOffset = false;

                _str s = get_match_text(); //(match_length(), (int)_QROffset());
                long offset_highlight = match_length('S');//_QROffset();
                int length_Highlight  = match_length(); //s._length();

                #if defined(STREAM_LINE) && defined(USE_STREAM_MARKER)
                typeless po;
                save_pos(po);
                _begin_line();
                offset_highlight = _QROffset();
                _end_line();
                offset_end := _QROffset();
                length_Highlight = (int)(offset_end - offset_highlight);
                isRealOffset = true;
                restore_pos(po);
                #endif

                int colorIndex = -1;
                dbgsay("ML " match_length() ", _QROffset:"(int)_QROffset() ", offset_highlight ="offset_highlight ", MatchText is:"s);
                //dbgsay("s_searchString:" s_searchString ", S is " s);

                // Note: The "isRealOffset" parameter for _StreamMarkerAdd is related to 
                //       what offset is used for the text.
                //       _QROffset() returns the "real" offset.
                //       while match_length('S') does not.
                //
                //       Real offsets exclude imaginary text.
                //       I think that _QROffset() <= match_length('S') is true.

                if (s != "")
                {
                    dbgsay("1");
                    SymbolColor *c = getSymColorFromTag(s);
                    if (c != null)
                    {
                        #ifdef USE_LINE_MARKER
                        int rgb = 0x00ff00;
                        ColorDefinition *colorDef = c->getColorDef();
                        if (colorDef != null)
                        {
                            rgb = colorDef->m_rgb;
                        }
                        #endif
                        dbgsay("2");
                        colorIndex = c->getMarkerIndex();
                        if (colorIndex != -1)
                        {
                            #ifdef USE_STREAM_MARKER
                            int pos_marker = _StreamMarkerAdd( p_window_id, offset_highlight, length_Highlight, isRealOffset, 0, s_markertypeSymHighlight, '');
                            _StreamMarkerSetTextColor(pos_marker, colorIndex);
                            #endif 

                            #ifdef USE_LINE_MARKER
                            line_maker:=_LineMarkerAdd(p_window_id, p_line, false, 1, 0, s_markertypeSymHighlight, "MESSAGE");
                            _LineMarkerSetStyleColor(line_maker, rgb);
                            #endif

                            #ifdef USE_SCROLL_MARKER
                            int line_marker = _ScrollMarkupAdd(p_window_id, p_line, c->getScrollMarkerIndex(), 1);
                            #endif
                            dbgsay("3");
                        }
                        if (def_sym_highlight_use_scrollmarkers)
                        {
                            dbgsay("4");
                            colorIndex = c->getScrollMarkerIndex();
                            if (colorIndex != -1)
                            {
                                dbgsay("5");
                                int line=(int)_QLineNumberFromOffset(offset_highlight);
                                _ScrollMarkupAdd(p_window_id, line, colorIndex);
                            }
                        }
                    }
                }
            } while (!repeat_search(searchArgs));
        }
    }

    restore_search( ss, sf, sw, sr, sf2); 
    restore_selection(m);
    _restore_pos2(p);

    //refresh();
}

static void symTagResetWindow()
{
    _StreamMarkerRemoveType(p_window_id, s_markertypeSymHighlight);
    _LineMarkerRemoveType(p_window_id, s_markertypeSymHighlight);
    sym_color_remove_highlight_markers(p_window_id);

    refresh();
}

static void SymHighlightCallback()
{
    if ( !p_mdi_child || command_state())
    {
        return;
    }
    if (_idle_time_elapsed() < def_sym_highlight_delay)
    {
        return;
    }

    sym_update_screen(false /* update now */);
}

static void DeferredInitSymHighlight()
{
    initsay("DeferredInitSymHighlight");
    if ( !pos( "-mdihide", _editor_cmdline, 1, 'i' ) )
    {
        initsay("DeferredInitSymHighlight 2 s_markertypeSymHighlight:"s_markertypeSymHighlight);
        if ( s_markertypeSymHighlight == -1 )
        {
            s_markertypeSymHighlight = _MarkerTypeAlloc();
            _MarkerTypeSetFlags(s_markertypeSymHighlight, VSMARKERTYPEFLAG_AUTO_REMOVE | STREAM_MARKER_TYPE);
            //MarkerTypeSetFlags(s_markertypeSymHighlight, VSMARKERTYPEFLAG_DRAW_BOX);
            initsay("DeferredInitSymHighlight 2.5 s_markertypeSymHighlight:"s_markertypeSymHighlight);
        }

        if ( s_timerSymHighlight >= 0 )
        {
            _kill_timer( s_timerSymHighlight );
            s_timerSymHighlight = -1;
        }

        initsay("DeferredInitSymHighlight3");
        //_InitSymColor();
        //if (!def_sym_highlight_persist_across_sessions)
        //{
        //    sym_do_clear_all_highlight_structs();
        //}
        if (gSymUpdateTimer)
        {
            s_timerSymHighlight = _set_timer( def_sym_highlight_delay, SymHighlightCallback );
        }
    }
}


/*-------------------------------------------------------------------------------
    sym_do_clear_all_highlight_structs
-------------------------------------------------------------------------------*/
void delayed_clear_all(int current)
{
    int i;

    WordInfo x_symTags:[] = s_symTags;

    WordInfo sym;
    dbgsay("delayed_clear_all:" current);
    _str index;
    if (current == 0)
    {
        return;
    }
    foreach ( index => sym in x_symTags )
    {
        sym_remove_symtag(index);
        sym.setEnabled(false);
        //say("3: "sym.getHashKey());
        call_list(SYMTAB_NOTIFY_DELWORD, sym);
        _post_call( delayed_clear_all, current - 1 );
        break;
    }
}
void sym_do_clear_all_highlight_structs()
{
//    _post_call( delayed_clear_all, 10 );
    int i;

    WordInfo x_symTags:[] = s_symTags;

    _str index;
    WordInfo sym;
    foreach ( index => sym in x_symTags )
    {
        sym_remove_symtag(index);
        sym.setEnabled(false);
        //say("3: "sym.getHashKey());
    }
    call_list(SYMTAB_NOTIFY_CLEAR);

    //sym_color_reset();
}

/*
    definit():  Run each time the editor is loaded
        arg(1) == 'L' when the module is loaded - and defload will be called.
        arg(1) ==  '' when the editor is loaded.
 
    defload():  Run when the module is loaded, after definit
 
    global variables state is saved in vslick.sta
    static global variables state is also saved.
 
    static global variables are reinitialized when the module is loaded.
*/
static void initGlobals()
{
    s_symTags                                 = null;
    s_modtimeSymHighlight                     = -1;
    s_markertypeSymHighlight                  = -1;
    s_timerSymHighlight                       = -1;
    s_searchString                            = null;
    gSymAutoUpdate                            = true;
    gSymUpdateTimer                           = false;

    def_sym_highlight_delay                   = 500;
    def_sym_highlight_use_scrollmarkers       = 1;
    def_sym_highlight_confirm_clear           = 0;
    def_sym_highlight_persist_across_sessions = 0;
}


static _str _ModuleName = "SymhighlightMain";
definit()
{
    if (arg(1) == 'L')
    {
        // On module reload, kill the timer and release the colors
        initsay("definit load "_ModuleName);
        if ( s_timerSymHighlight >= 0 )
        {
            _kill_timer( s_timerSymHighlight );
            s_timerSymHighlight = -1;
        }
        if (s_markertypeSymHighlight != -1)
        {
            //sym_update_screen(true, "symTagResetWindow");
            initsay("Remove MarkerType on DefInit");
            _StreamMarkerRemoveAllType( s_markertypeSymHighlight );
            sym_color_remove_all_highlight_marker_types();

            _MarkerTypeFree(s_markertypeSymHighlight);
            s_markertypeSymHighlight  = -1;
        }
    }

    initGlobals();
    initsay("defInit "_ModuleName);
    sym_color_sym_initc();

    _post_call( DeferredInitSymHighlight );
}

defload()
{
    initsay("defload Reset "_ModuleName);
}

