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
#import "SymHighlightMain.e"
#include "SlickCompat.sh"

int g_windowId = -1;

/**
 * Add a highlight word.
 * <p>
 * Meant to be called at the command line or from a script.
 * <p>
 * Arguments:
 * <ul>
 * <li>word is the string to highlight</li>
 * <li>color is a color index or a color name</li>
 * <li>wholeWord is a boolean, default if true</li>
 * </ul>
 * 
 * @param word   The text to be highlighted
 * 
 * @return 
 * @example symtag_add_word(word [color] [wholeWord])
 */
_command boolean symtag_add_word(_str word=null, ...) name_info(',')
{
    if (word == null || length(word) == 0)
    {
        message("A word must be specified")
        return false;
    }
    dbgsay("Word is " word ", Args are:" arg() ", Arg1 is " arg(1));
    _str color = null;
    if (arg() >= 2)
    {
        if (isinteger(arg(1)))
        {
            int colorIndex = (int)arg(1);
            color = sym_color_get_color_by_index(colorIndex);
            if (color == null)
            {
                message("Invalid color index");
                return false;
            }
        }
        else
        {
            color = arg(1);
            if (!sym_color_is_valid_color(color))
            {
                message("Invalid colorname");
                return false;
            }
        }
    }
    else
    {
        color = sym_color_get_new_color();
    }
    boolean wholeWord = true;
    if (arg() >= 3)
    {
        wholeWord = 0 != (int)arg(2);
    }

    WordInfo sym(word,color,wholeWord);
    symTagDlgUpdateSymTag(sym);
    return true;
}

/**
 * Toggle debug printing for symtag
 * 
 * @author jporkka (9/11/2020)
 */
_command void symtag_toggle_debug() name_info(',')
{
    def_sym_enable_debug_print = !def_sym_enable_debug_print;
    def_sym_debug_print_filter = SYMTAG_DEBUG_WORDSELECTSAY;
    def_sym_debug_print_type = SYMTAG_DEBUG_TYPE_OUTPUT;
}

/**
 * Toggle the highlight of the word under the cursor or the
 * current selection.
 * <p>
 * This also cycles the color used to highlight this word.
 */
_command void symtag_toggle_sym_highlight() name_info(',')
{
    int i;
    WordInfo selSym = sym_get_curword_or_selection();

    if (selSym.toString() == "")
    {
        return;
    }
    _str key = selSym.getHashKey();
    WordInfo *sym = sym_get_wordinfo(key);
    if (sym != null)
    {
        selSym = *sym;
        selSym.setEnabled(false);
        sym_remove_symtag(key);
        //say("1");
        call_list(SYMTAB_NOTIFY_DELWORD, selSym);
    }
    else
    {
        sym_add_symtag(selSym);
        call_list(SYMTAB_NOTIFY_ADDWORD, selSym);
    }

    sym_update_screen(true /* update now */);
}

//_command void symtag_toggle_sym_line_highlight() name_info(',')
//{
//}
//
//

/**
 * Cycle the highlight color of the word under the cursor or the
 * current selection.
 */
_command void symtag_cycle_sym_highlight() name_info(',')
{
    WordInfo selSym = sym_get_curword_or_selection();

    //dbgsay("symtag_cycle_sym_highlight");
    // if not highlighted, do it.
    _str key = selSym.getHashKey();
    WordInfo *sym = sym_get_wordinfo(key);
    if (sym != null)
    {
        sym_set_next_color_symtag(sym);
        call_list(SYMTAB_NOTIFY_CYCLECOLOR, *sym);
    }
    else
    {
        sym_add_symtag(selSym);
        call_list(SYMTAB_NOTIFY_ADDWORD, selSym);
    }
    sym_update_screen(true /* update now */);
}

/**
 * Delete all existing symtag highlights.
 */
_command void symtag_clear_all_sym_highlights() name_info(',')
{
    _str result = IDYES;
    _str messageString = "Clear the following list?\n\n";
    int i;
    int j;

    if (def_sym_highlight_confirm_clear)
    {
        _str index;
        WordInfo sym;
        foreach ( index => sym in s_symTags )
        {
            messageString :+= index :+ "\n";
        }

        result = _message_box(messageString, '', MB_YESNO|MB_ICONQUESTION);
    }

    if (result == IDYES)
    {
        sym_do_clear_all_highlight_structs();
        sym_update_screen(true);
    }
}

#ifdef DEBUGGING
/** 
 *  symtag_dump_sym_highlight_table
 * Dump the set of highlights to the say window.
*/
_command void symtag_dump_sym_highlight_table() name_info(',')
{
    int i;
    dbgsay("---------------------------------------------------");
    dbgsay("--- SymHighlight dump: " :+ _time('L'));
    dbgsay("search string:");
    if (s_searchString == null)
    {
        dbgsay("   " :+ "null");
    }
    else
    {
        dbgsay("   '" :+ s_searchString :+ "'");
    }
    dbgsay("-------------------");
    dbgsay("word list:");

    i = 0;
    _str index;
    WordInfo sym;
    foreach ( index => sym in s_symTags )
    {
        dbgsay("   " :+ (i+1) :+ ": " :+ sym.toStringDbg() );
        dbgsay("Index is " index);
        i += 1;
    }

    dbgsay("-------------------");
    sym_color_debug_dump_colordefs();

    dbgsay("-------------------");
    sym_dlg_debug_dump_treelist();
    dbgsay("--- End SymHighlight dump");
}
#endif

/**
 * Open the highlights dialog
 */
_command void symtag_open_sym_highlights()
{
    // The -modal option displays other windows while the dialog box
    // is displayed.
    g_windowId = show("-mdi Highlights_form");
}

/** 
 * Close the highlights dialog
*/
_command void symtag_close_sym_highlights()
{
    // The -modal option displays other windows while the dialog box
    // is displayed.
    if (g_windowId != -1)
    {
        g_windowId._delete_window(0);
    }
}

// Called from HighlightDialog
void symTagDlgCycleColorNextSymTag(WordInfo &sym)
{
    _str key = sym.getHashKey();
    WordInfo *sym2 = sym_get_wordinfo(key);
    dlgsay("symTagDlgCycleColorNextSymTag: " key);

    if (sym2 != null)
    {
        sym_set_next_color_symtag(sym2);
        call_list(SYMTAB_NOTIFY_CYCLECOLOR, *sym2);
    }
    sym_update_screen(true /* update now */);
}

void symTagDlgCycleColorPrevSymTag(WordInfo &sym)
{
    _str key = sym.getHashKey();
    WordInfo *sym2 = sym_get_wordinfo(key);
    dlgsay("symTagDlgCycleColorPrevSymTag: " key);

    if (sym2 != null)
    {
        sym_set_prev_color_symtag(sym2);
        call_list(SYMTAB_NOTIFY_CYCLECOLOR, *sym2);
    }
    sym_update_screen(true /* update now */);
}

void symTagDlgUpdateSymTag(WordInfo &sym)
{
    _str key = sym.getHashKey();
    WordInfo *sym2 = sym_get_wordinfo(key);
    dlgsay("symTagDlgUpdateSymTag: " key ", "sym.toText());

    if (sym2 != null)
    {
        sym2->setEnabled(sym.enabled());
        sym2->setWholeWord(sym.isWholeWord());
        sym2->setColor(sym.getColor());
        call_list(SYMTAB_NOTIFY_CYCLECOLOR, *sym2);
        dlgsay("                       " key ", "sym2->toText());
    }
    else
    {
        sym_add_symtag(sym);
        call_list(SYMTAB_NOTIFY_ADDWORD, sym);
    }
    s_searchString = null;
    sym_update_screen(true /* update now */);
}

boolean symTagDlgRemoveSymTag(_str fromWord)
{
    dlgsay("symTagDlgRemoveSymTag: " fromWord);
    boolean result = sym_remove_symtag(fromWord);
    sym_update_screen(true /* update now */);
    return result;
}

boolean symTagDlgChangeSymTag(_str fromWord, WordInfo newWord)
{
    dlgsay("symTagDlgChangeSymTag: " fromWord ", To:" newWord.getHashKey());
    WordInfo *sym = sym_get_wordinfo(fromWord);
    if (sym != null)
    {
        WordInfo selSym = *sym;
        selSym.setEnabled(false);
        sym_remove_symtag(fromWord);
        //say("2");
        call_list(SYMTAB_NOTIFY_DELWORD, selSym);
    }
    sym_add_symtag(newWord);
    call_list(SYMTAB_NOTIFY_ADDWORD, newWord);
    sym_update_screen(true /* update now */);
    return true;
}

boolean symTagDlgAddHighlightWord(WordInfo &sym)
{
    _str key = sym.getHashKey();
    dlgsay("symTagDlgAddHighlightWord: " key);
    if (s_symTags._indexin(key) && s_symTags:[key] != null)
    {
    }
    else
    {
        sym_add_symtag(sym);
        call_list(SYMTAB_NOTIFY_ADDWORD, sym);
        sym_update_screen(true /* update now */);
    }
    return false;
}

void symTagDlgSetEnabled(WordInfo &sym, boolean enabled)
{
    if (sym.enabled() != enabled)
    {
        sym.setEnabled(enabled);
        //call_list(SYMTAB_NOTIFY_CYCLECOLOR, sym);
        sym_update_screen(true /* update now */);
    }
}

/*
 
// set shorcut keys in SlickEdit
_command void quick_SymHighlightsSetSEKeys() name_info(','VSARG2_EDITORCTL|VSARG2_MACRO)
{
  gui_bind_to_key("quick-SymHighlights-");
} 
     
*/


