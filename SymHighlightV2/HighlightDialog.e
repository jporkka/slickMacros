////////////////////////////////////////////////////////////////////////////////////
// Revision: 1 
////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#include "slick.sh"
#import "stdprocs.e"
#import "WordInfo.e"
#import "SymColors.e"
#import "SymDebug.e"
#import "SymHighlightMain.e"
#import "SymHighlightApi.e"

#define COLOR_DEF_BG 0x80000008         // Default background for that control
#define COLOR_DEF_FG 0x80000005         // Default foreground for that control
#define COLOR_DEF_DLG_BG 0x80000022     // Default dialog background color

/// Begin Dialog Support
#define DLGINFO_CURRENT_HIGHLIGHT_WID 0
#define DLGINFO_CURRENT_BUFFER 1
void xTreeSetUserInfo(typeless s_list_ctrl, int ItemIndex, typeless info)
{
    if (info == null)
    {
        dlgsay("TreeSetUserInfo: index " ItemIndex ", Info is type: <NULL>" );
    }
    else
    {
        dlgsay("TreeSetUserInfo: index " ItemIndex ", Info is type: " info._typename());
    }
    s_list_ctrl._TreeSetUserInfo(ItemIndex, info);
}

enum FinderColumns
{
    FC_ENABLED,
    FC_WHOLEWORD,
    FC_COLOR,
    FC_NEEDLE
};

//#define DEBUGGING
//#define CHECK_SWITCH
#define CHECK_BOXEN true
//#define CHECK_TEXTONLY
#define CHECK_STRING_ENABLED "[+]"
#define CHECK_STRING_DISABLED "[ ]"

typedef typeless (*onEventFn)(int reason, int index, _str &value, int wid);
static onEventFn s_EventTable:[];
static typeless s_form1_p = 0;
static typeless s_list_ctrl = 0;
static int s_NewIndex = 0;

#ifdef DEBUGGING
static _str s_EventNames:[] = 
{
CHANGE_OTHER => "CHANGE_OTHER 0",
CHANGE_CLINE => "CHANGE_CLINE 1",
CHANGE_CLINE_NOTVIS => "CHANGE_CLINE_NOTVIS 2",
CHANGE_CLINE_NOTVIS2 => "CHANGE_CLINE_NOTVIS2 3",
CHANGE_BUTTON_PRESS => "CHANGE_BUTTON_PRESS 4",
CHANGE_BUTTON_SIZE => "CHANGE_BUTTON_SIZE 5",
CHANGE_BUTTON_SIZE_RELEASE => "CHANGE_BUTTON_SIZE_RELEASE 6",
CHANGE_HIGHLIGHT => "CHANGE_HIGHLIGHT 7",
CHANGE_SELECTED => "CHANGE_SELECTED 10",
CHANGE_PATH => "CHANGE_PATH 11",
CHANGE_FILENAME => "CHANGE_FILENAME 12",
CHANGE_DRIVE => "CHANGE_DRIVE 13",
CHANGE_EXPANDED => "CHANGE_EXPANDED 14",
CHANGE_COLLAPSED => "CHANGE_COLLAPSED 15",
CHANGE_LEAF_ENTER => "CHANGE_LEAF_ENTER 16",
CHANGE_SCROLL => "CHANGE_SCROLL 17",
CHANGE_EDIT_OPEN => "CHANGE_EDIT_OPEN 20",
CHANGE_EDIT_CLOSE => "CHANGE_EDIT_CLOSE 21",
CHANGE_EDIT_QUERY => "CHANGE_EDIT_QUERY 22",
CHANGE_EDIT_OPEN_COMPLETE => "CHANGE_EDIT_OPEN_COMPLETE 23",
CHANGE_EDIT_PROPERTY => "CHANGE_EDIT_PROPERTY 24",
CHANGE_NODE_BUTTON_PRESS => "CHANGE_NODE_BUTTON_PRESS 25",
CHANGE_CHECK_TOGGLED => "CHANGE_CHECK_TOGGLED 26",
CHANGE_SWITCH_TOGGLED => "CHANGE_SWITCH_TOGGLED 27",
CHANGE_SCROLL_MARKER_CLICKED => "CHANGE_SCROLL_MARKER_CLICKED 28",
CHANGE_NEW_FOCUS => "CHANGE_NEW_FOCUS 20",
CHANGE_CLICKED_ON_HTML_LINK => "CHANGE_CLICKED_ON_HTML_LINK 32",
CHANGE_AUTO_SHOW => "CHANGE_AUTO_SHOW 34",
CHANGE_FLAGS => "CHANGE_FLAGS 35",
};
#endif

static typeless get_tree_object()
{
    if (s_form1_p != 0)
    {
        if (_iswindow_valid(s_form1_p))
        {
            return s_form1_p;
        }
        else
        {
            dlgsay("No form 2!");
            s_form1_p = 0;
            s_list_ctrl = 0;
        }
    }
    //dlgsay("No form!" s_form1_p);
    return null;
}

static int findItem(int s_list_ctrl, _str key)
{
    int found = -1;
    int index = s_list_ctrl._TreeGetNextIndex(0);
    while (index != -1)
    {
        _str text =  s_list_ctrl._TreeGetCaption(index, FC_NEEDLE);
        if (text == key)
        {
            found = index;
            break;
        }
        index = s_list_ctrl._TreeGetNextIndex(index);
    }
    return found;
}

//static int dumpTable(int s_list_ctrl)
//{
//    int found = -1;
//    int index = s_list_ctrl._TreeGetNextIndex(0);
//    dlgsay("---------------   dumpTable   ------------");
//    while (index != -1)
//    {
//        WordInfo itemSym = s_list_ctrl._TreeGetUserInfo(index);
//        SymbolColor symColor = GetSymColor(itemSym.getColor());
//        _str colorName = "<none>";
//        if (symColor != null)
//        {
//            colorName = symColor.m_name;
//        }
//        //items = items " " text;
//        dlgsay("    Item: (" index ") is '" itemSym.getHashKey() "', Color: " itemSym.getColor() ", " colorName);
//        index = s_list_ctrl._TreeGetNextIndex(index);
//    }
//    //dlgsay("ITEMS: " items);
//
//    return found;
//}

static boolean getCheckState(int ctrlid, int index, int col)
{
#ifdef CHECK_BOXEN
    return ctrlid._TreeGetCheckState(index, col) !=0;
#endif

#ifdef CHECK_TEXTONLY
    _str text =  ctrlid._TreeGetCaption(index, col);
    dlgsay("CHECK_TEXTONLY("index") text:" text ", testis+:" (text == CHECK_STRING_ENABLED));
    return text == CHECK_STRING_ENABLED;
#endif

#ifdef CHECK_SWITCH
    return(ctrlid._TreeGetSwitchState(index, col)) ? true : false;
#endif
}

static void setCheckState(int ctrlid, int index, int col, boolean state)
{
#ifdef CHECK_BOXEN
    ctrlid._TreeSetCheckState(index, (int)state, col);
#endif

#ifdef CHECK_TEXTONLY
    dlgsay("SCS TREESETCAPTION: ("index") " (state ? CHECK_STRING_ENABLED : CHECK_STRING_DISABLED) ", col: " col);
    ctrlid._TreeSetCaption(index, state ? CHECK_STRING_ENABLED : CHECK_STRING_DISABLED, col);
#endif

#ifdef CHECK_SWITCH
    ctrlid._TreeSetSwitchState(index, col, state);
#endif
}

static void addEventHandler(int reason, FinderColumns col, onEventFn fn)
{
    _str id = "" reason "," col;
    s_EventTable:[id] = fn;
    dlgsay("addEventHandler EVENTID: " id);
}

static typeless onToggleEnabled(int reason, int index)
{
    if (!get_tree_object())
    {
        return 0;
    }

    boolean enabled = getCheckState(s_list_ctrl, index, FC_ENABLED);
#ifdef CHECK_TEXTONLY
    //setCheckState(s_list_ctrl, index, FC_ENABLED, !enabled);
#endif

    _str text =  s_list_ctrl._TreeGetCaption(index, FC_NEEDLE);
    WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
    dlgsay("Enabled ("index") is :" enabled " caption:" text ", WORD:" wordSym.toStringDbg());

    wordSym.setEnabled(!enabled);
    symTagDlgUpdateSymTag(wordSym);
    //xTreeSetUserInfo(s_list_ctrl, index, wordSym);
    return 0;
}

static typeless onToggleWord(int reason, int index, _str &value="",int wid=0)
{
    if (!get_tree_object())
    {
        return 0;
    }

    boolean enabled = getCheckState(s_list_ctrl, index, FC_WHOLEWORD);
#ifdef CHECK_TEXTONLY
    //setCheckState(s_list_ctrl, index, FC_WHOLEWORD, !enabled);
#endif

    _str text =  s_list_ctrl._TreeGetCaption(index, FC_NEEDLE);
    WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
    wordSym.setWholeWord(!enabled);
    //xTreeSetUserInfo(s_list_ctrl, index, wordSym);
    //dlgsay("WordMatch is :" enabled " caption:" text ", WORD:" wordSym.toStringDbg());

    symTagDlgUpdateSymTag(wordSym);

    //xTreeSetUserInfo(s_list_ctrl, index, wordSym);
    return 0;
}

void sym_dlg_debug_dump_treelist()
{
    if (!get_tree_object())
    {
        return;
    }
    say("   DumpDlgEntries   ");
    int index = 1;
    while (s_list_ctrl._TreeIndexIsValid(index))
    {
        _str text =  s_list_ctrl._TreeGetCaption(index, FC_NEEDLE);
        WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
        say("    "index", Text:'"text"', "wordSym.toText());
        s_list_ctrl._TreeSetCaption(index, text :+ "X", FC_NEEDLE);
        index++;
    }
}
static typeless onNeedle(int reason, int index, _str &value="",int wid=0)
{
    dlgsay("onNeedle TEXT: " value ", Index:" index ", Value: " value);
    if (!s_form1_p)
    {
        return 0;
    }

    WordInfo sym = s_list_ctrl._TreeGetUserInfo(index);
    if (value == null || length(value) == 0 || findItem(s_list_ctrl, value) != -1)
    {
        setItemState(s_list_ctrl, index, sym);
        dlgsay("DUPLICATE!");
    }
    else
    {
        _str oldWord = sym.getHashKey();
        sym.setWord(value);
        setItemState(s_list_ctrl, index, sym);
        symTagDlgChangeSymTag(oldWord, sym);
    }
    return 0;
}

static int addItem(int treectrl, WordInfo &sym, boolean append = true)
{
    int index = treectrl._TreeGetNextIndex(TREE_ROOT_INDEX);

#ifdef CHECK_BOXEN
    _str item = "\t\t"  sym.getHashKey();
#endif

#ifdef CHECK_SWITCH
    _str item = "\t\t"  sym.getHashKey();
#endif

#ifdef CHECK_TEXTONLY
    _str word = sym.isWholeWord() ? CHECK_STRING_ENABLED : CHECK_STRING_DISABLED;
    _str item = "+\t" word "\t" sym.getHashKey();
#endif

    dlgsay("Add item: " item);
    if (index == -1 || append)
    {
        index = treectrl._TreeAddItem(TREE_ROOT_INDEX, item, TREE_ADD_AS_CHILD, 0, 0, TREE_NODE_LEAF);
    }
    else
    {
        index = treectrl._TreeAddItem(index, item, TREE_ADD_BEFORE, 0, 0, TREE_NODE_LEAF);
    }
    treectrl._TreeSetNodeEditStyle(index, FC_NEEDLE, TREE_EDIT_TEXTBOX);
    setItemState(treectrl, index, sym);
    return index;
}

static void setItemState(int treectrl, int index, WordInfo &sym)
{
    _str key = sym.getHashKey();
    treectrl._TreeSetCaption(index, key, FC_NEEDLE);
    dlgsay("setItemState I:" index ", word:" key);
    setCheckState(treectrl, index, FC_WHOLEWORD, sym.isWholeWord());
    setCheckState(treectrl, index, FC_ENABLED, sym.enabled());
    xTreeSetUserInfo(treectrl, index, sym);

    int fg = 0;
    int bg = 0;
    treectrl._TreeGetColor(index, 0, fg, bg, 0);
    treectrl._TreeSetColor(index, FC_COLOR, fg, bg, 0 );

    SymbolColor *symColor = sym_get_symcolor_from_sym(sym);
    if (symColor != null)
    {
        ColorDefinition *colorDef = symColor->getColorDef();
        if (colorDef != null)
        {
            treectrl._TreeSetColor(index, FC_COLOR, fg, colorDef->m_rgb, F_INHERIT_FG_COLOR);
            treectrl._TreeSetCaption(index, colorDef->m_name, FC_COLOR);
        }
    }
}

static void setupState(int activeForm, int listCtrl)
{
    s_form1_p = activeForm;
    s_list_ctrl = listCtrl;
    dlgsay("Form is: " s_form1_p);
//    DialogBufferFocus c1("Highlights", s_form1_p, listCtrl);
//    _SetDialogInfoHt("MyThis", c1, s_form1_p, true);
    addEventHandler(CHANGE_EDIT_CLOSE, FC_NEEDLE, onNeedle);
//#ifndef CHECK_BOXEN
//    addEventHandler(CHANGE_SWITCH_TOGGLED, FC_ENABLED, onToggleEnabled);
//    addEventHandler(CHANGE_SWITCH_TOGGLED, FC_WHOLEWORD, onToggleWord);
//    addEventHandler(CHANGE_EDIT_PROPERTY, FC_ENABLED, onToggleEnabled);
//    addEventHandler(CHANGE_EDIT_PROPERTY, FC_WHOLEWORD, onToggleWord);
//#endif
}

defeventtab Highlights;
//void ctlcommand1.lbutton_up()
//{
//    _delete_window(0);
//}
void ctl_new_button.lbutton_up()
{
    WordInfo sym;
    sym.setColor(sym_color_get_new_color());
    // 139 is the nr of s_symColour elements from SymHighlightMain.e
    int index = -1;
    do
    {
        _str key = "text" :+ s_NewIndex++
        sym.setWord(key);
        index = findItem(s_list_ctrl, key);
    } while (index != -1);

    symTagDlgAddHighlightWord(sym);
}

void Highlights.on_resize()
{
    int xbuff=ctl_tree.p_x;
    int ybuff=ctl_tree.p_y;
    int form_width=_dx2lx(SM_TWIP,p_client_width);
    int form_height=_dy2ly(SM_TWIP,p_client_height);
    ctl_tree.p_width=form_width-(xbuff+xbuff+ctl_new_button.p_width+xbuff);
    ctl_tree.p_height=form_height-ybuff*2;

    ctl_new_button.p_x=ctl_tree.p_x+ctl_tree.p_width+xbuff;
    ctl_del_button.p_x=ctl_tree.p_x+ctl_tree.p_width+xbuff;
}

void ctl_del_button.lbutton_up()
{
    if (!get_tree_object())
    {
        return;
    }
    int index = ctl_tree._TreeCurIndex();
    if (index > 0)
    {
        boolean enabled = (s_list_ctrl._TreeGetSwitchState(index, FC_ENABLED)) ? true : false;
        _str text =  s_list_ctrl._TreeGetCaption(index, FC_NEEDLE);
        dlgsay("Delete, Enabled: " enabled ", TEXT:" text);
        symTagDlgRemoveSymTag(text);
        ctl_tree._TreeDelete(index);
    }
}

void  Highlights.'F2'()
{
    dlgsay("*** Event E ***");
    int info = 0;
    int index = _TreeGetNextSelectedIndex(1, info);
    if (index != -1)
    {
        _TreeEditNode(index, FC_NEEDLE);
    }
}

void  Highlights.'e'()
{
    dlgsay("*** Event E ***");
    int info = 0;
    int index = _TreeGetNextSelectedIndex(1, info);
    if (index != -1)
    {
        onToggleEnabled(CHANGE_EDIT_PROPERTY, index) ;
    }
}

void  Highlights.'w'()
{
    dlgsay("*** Event W ***");
    int info = 0;
    int index = _TreeGetNextSelectedIndex(1, info);
    if (index != -1)
    {
        onToggleWord(CHANGE_EDIT_PROPERTY, index);
    }
}

void  Highlights.'c'()
{
    dlgsay("*** Event c ***");
    int info = 0;
    int index = _TreeGetNextSelectedIndex(1, info);
    if (index != -1)
    {
        WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
        symTagDlgCycleColorNextSymTag(wordSym);
    }
}

void  Highlights.'C'()
{
    dlgsay("*** Event C ***");
    int info = 0;
    int index = _TreeGetNextSelectedIndex(1, info);
    if (index != -1)
    {
        WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
        symTagDlgCycleColorPrevSymTag(wordSym);
    }
}

typeless ctl_tree.on_change(int reason, int index,int col=-1,_str &value="",int wid=0)
{
    if (s_list_ctrl == 0)
    {
        dlgsay("NO LIST!");
        setupState(p_active_form, p_window_id);
    }

    _str reasonName = "(R:" reason ")";
    #ifdef DEBUGGING
    if (s_EventNames._indexin(reason ))
    {
        reasonName = "(R:" s_EventNames:[reason] ")";
    }
    #endif

#ifdef CHECK_BOXEN
    if (reason == CHANGE_CHECK_TOGGLED || reason == CHANGE_SELECTED || reason == CHANGE_EDIT_PROPERTY)
    {
        dlgsay("EVENTID(1): I:("index") " reasonName "," (FinderColumns)col ", col = " col);// ", Enabled=" enabled ", WW=" ww);
        #ifdef DEBUGGING
        dlgsay("EVENTID(1): I:("index") " reasonName "," (FinderColumns)col ", col = " col);// ", Enabled=" enabled ", WW=" ww);
        #endif
        WordInfo wordSym = s_list_ctrl._TreeGetUserInfo(index);
        if (wordSym == null)
        {
            dlgsay("Wordsym is null");
            return 0;
        }
        int result = 0;
        if (wordSym instanceof "WordInfo")
        {
            boolean enabled = getCheckState(s_list_ctrl, index, FC_ENABLED);
            boolean ww = getCheckState(s_list_ctrl, index, FC_WHOLEWORD);
            if (col == FC_COLOR)
            {
                if (_IsKeyDown(SHIFT) )
                {  
                    dlgsay("1 DIALOG WordInfo type is:  " wordSym._typename());
                    symTagDlgCycleColorPrevSymTag(wordSym);
                }
                else
                {
                    dlgsay("2 DIALOG WordInfo type is:  " wordSym._typename());
                    symTagDlgCycleColorNextSymTag(wordSym);
                }
            }
            if (enabled != wordSym.enabled() || ww != wordSym.isWholeWord())
            {
                dlgsay("3 DIALOG WordInfo type is:  " wordSym._typename());
                wordSym.setEnabled(enabled);
                wordSym.setWholeWord(ww);
                symTagDlgUpdateSymTag(wordSym);
            }
        }
        return result;
    }
#endif

    dlgsay("EVENTID(2): I:("index") " reasonName "," (FinderColumns)col ", col = " col);// ", Enabled=" enabled ", WW=" ww);
    _str id = "" reason "," (FinderColumns)col;
    onEventFn fn = s_EventTable:[id];
    if (fn != null)
    {
        typeless result = (*fn)(reason,  index,  value, wid);
        //hl_dump_sym_highlight_table();
        //dumpTable(s_list_ctrl);
        return result;
    }

    return 0;
}

void ctl_tree.on_create()
{
    //execute('slickc-debug-start');
    dlgsay("ctl_tree.on_create()");

    // TREE_BUTTON_SORT
    _TreeSetColButtonInfo(FC_ENABLED, 550, 0, -1, "Enabled" );
    _TreeSetColButtonInfo(FC_WHOLEWORD, 550, 0, -1, "Word" );
    _TreeSetColButtonInfo(FC_COLOR, 350, 0, -1, "Color" );
    _TreeSetColButtonInfo(FC_NEEDLE, 350, 0, -1, "Text" );

    auto prev = null;
    //auto container1 = prev = _TreeAddItem(0,"Container1\tColum\tData",TREE_ADD_AS_CHILD, _pic_fldclos, _pic_fldaop,0);

    p_EditInPlace = true;
    setupState(p_active_form, p_window_id);

    WordInfo i;
    WordInfo sym;
    auto symTags = sym_get_highlight_words();
    foreach ( i => sym in symTags)
    {
        addItem(s_list_ctrl, sym);
    }

    _TreeAdjustColumnWidthsByColumnCaptions();
    _TreeExpandAll();

    p_NeverColorCurrent = false;

    parse _default_color(CFG_WINDOW_TEXT) with auto fg auto bg auto fontFlags;
    dlgsay("CFG_WINDOW_TEXT: fg:"dec2hex(fg)", bg:"dec2hex(bg)"");

    dlgsay("CREATED");
}

/////////////////////////////////////////////////////////////////////////// 
//// Notifications 
void _highlight_cyclecolor_tb(WordInfo &sym) // called by SymHighlight
{
    dlgsay("_highlight_cyclecolor_tb: " sym);
    _highlight_addword_tb(sym);
}

void _highlight_addword_tb(WordInfo &sym) // called by SymHighlight
{
    _str key = sym.getHashKey();
    if (!get_tree_object())
    {
        return;
    }
//    if (p)
    {
        //int index = s_list_ctrl._TreeSearch(0,  key, "IST", 0, FC_NEEDLE);
        int index = findItem(s_list_ctrl, key);
        if (index == -1)
        {
            dlgsay("Item not found: " key);
            index = addItem(s_list_ctrl, sym, true);
        }
        else
        {
            WordInfo itemSym = s_list_ctrl._TreeGetUserInfo(index);
            if (!itemSym.equals(sym))
            //if (!(itemSym == sym))
            {
                setItemState(s_list_ctrl, index, sym);
            }
            else
            {
                dlgsay("Sym==" itemSym.getColor() " == " sym.getColor());
                //setItemState(s_list_ctrl, index, sym);
                dlgsay("ADDWORD AVOIDED");
            }
        }
    }
}

void _highlight_clear_tb() // called by SymHighlight
{
    //say("HEY 1");
    if (!get_tree_object())
    {
        //say("_highlight_delword notree");
        return;
    }
    //say("active form:" p_active_form", s_form1_p:"s_form1_p", p_window_id:"p_window_id);
    //s_list_ctrl._TreeBeginUpdate(0);
    //sym_dlg_debug_dump_treelist();
    index = s_list_ctrl._TreeGetNextIndex(0);
    while (index != -1)
    {
        setCheckState(s_list_ctrl, index, FC_ENABLED, false);
        index = s_list_ctrl._TreeGetNextIndex(index);
    }
    //s_list_ctrl._TreeEndUpdate(0);
    s_list_ctrl._TreeRefresh();
}
void _highlight_delword_tb(WordInfo &sym) // called by SymHighlight
{
    //say("HEY");
    //_post_call( def_highlight_delword_tb, sym);
    if (!get_tree_object())
    {
        //say("_highlight_delword notree");
        return;
    }
    //say("active form:" p_active_form", s_form1_p:"s_form1_p", p_window_id:"p_window_id);
    //say("_highlight_delword_tb: " sym.getHashKey());
    int index = findItem(s_list_ctrl, sym.getHashKey());
    dbgsay("_highlight_delword_tb: " sym.getHashKey() ", index:"index", Enabled:"sym.enabled());
    if (index != -1)
    {
        //xTreeSetUserInfo(s_list_ctrl, index, sym);
        //setCheckState(s_list_ctrl, index, FC_WHOLEWORD, sym.enabled());
        setItemState(s_list_ctrl, index, sym);
        //setCheckState(s_list_ctrl, index, FC_ENABLED, sym.enabled());
        //symTagDlgSetEnabled(sym, false);
        //_post_call( DeferredDisable, index );
    }
    //s_list_ctrl._TreeBeginUpdate(0);
    //index = s_list_ctrl._TreeGetNextIndex(0);
    //while (index != -1)
    //{
    //    setCheckState(s_list_ctrl, index, FC_ENABLED, false);
    //    index = s_list_ctrl._TreeGetNextIndex(index);
    //}
    //s_list_ctrl._TreeEndUpdate(0);
}
/////////////////////////////////////////////////////////////////////////// 
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
    s_EventTable = null;
    s_form1_p = 0;
    s_list_ctrl = 0;
    s_NewIndex = 0;
}

static _str _ModuleName = "HighlightDialog";
defload()
{
    initsay("DIALOG DEFLOAD: " _ModuleName);
    initGlobals();
}

definit()
{
    initsay("DIALOG DEFINIT: " _ModuleName);
}


