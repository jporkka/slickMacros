#include "slick.sh"
#import "search.sh"
#import "stdprocs.e"

#ifndef CTLSEPARATOR
// This definition was removed from stdprocs.e in V22
#define CTLSEPARATOR  "\0"
#endif


/* 
Setup a complex RE to translate between terms 
 
First, create a block of text like this: 
 
    abc==>def 
    123==>576 
 
Select those lines of text and call translateTerms(). 
This will populate the gui-replace dialog with a Perl RE to replace all those terms on the left with those on the right. 
 
 
*/
int gui_replace_init_re(_str findstr="", _str replacestr="") 
{
   int formid;
   if (isEclipsePlugin()) {
      show('-xy _tbfind_form');
      formid = _find_object('_tbfind_form._findstring');
      if (formid) {
         formid._set_focus();
      }
   } else {
      tool_gui_replace();
      formid = activate_tool_window('_tbfind_form', true, '_findstring');
   }

   if (!formid) {
      return 0;
   }
   _control _findstring;
   _control _replacestring;
   _control _findre;
   _control _findre_type;
   _control _findbuffer;
   formid._findstring.p_text = findstr;
   formid._findstring._set_sel(1,length(findstr)+1);
   formid._replacestring.p_text = replacestr;
   formid._findre.p_value=1;
   formid._findre.call_event(formid._findre,LBUTTON_UP);
   formid._findbuffer.p_text = SEARCH_IN_CURRENT_BUFFER;
   formid._findre_type.p_text = RE_TYPE_PERL_STRING;
   formid._findre_type.call_event(formid._findre_type,LBUTTON_UP);
   return 1;
}

static _str gFrom[] = {""};
static _str gTo[] = {""};
static _str separatorChar = '==>'; // Maybe you like "\t" instead?
static _str translate_filter(_str s)
{
    split(s, separatorChar, auto parts);
    if (parts._length() < 2) 
    {
        int n = pos(separatorChar, s);
        if (n != 0) {
            parts :+= "";
        }
    }
    if (parts._length() == 2) 
    {
        gFrom :+= parts[1];
        gTo   :+= parts[0];
    }
    return s;
}

// Select a block of text with the Find/Replace terms - one pair on each line.
// Run translateTerms.
// It will open a find/replace dialog with the search strings initialized to do all the replacements.
//
// Example:
//     %windir%=C:\WINDOWS
//     %ProgramData%=C:\ProgramData
//
//  This will replace "C:\Windows" with "%windir%" and "C:\ProgramData" with "%ProgramData%"
_command void translateTerms() name_info(','VSARG2_MULTI_CURSOR|VSARG2_MARK|VSARG2_REQUIRES_EDITORCTL|VSARG2_REQUIRES_AB_SELECTION)
{
    boolean flip = true;
    boolean doRaw = false;

    if (!select_active()) {
        _message_box('No selection active');
        return;
    }

    typeless stype=_select_type();
    //say("Select Type is: " stype);
    if (stype=='CHAR') {
        // Convert char selections to line selections
        _select_type('','L','LINE');
        stype='LINE';
    }
    gFrom._makeempty();
    gTo._makeempty();
    filter_selection(translate_filter,'',doRaw);
    _str fromStr = "";
    if (flip) {
        auto temp = gFrom;
        gFrom = gTo;
        gTo = temp;
    }

    foreach (auto term in gFrom) {
        term = _escape_re_chars(term, 'U')
        if (length(fromStr) > 0) {
            fromStr = fromStr :+ "|";
        }
        fromStr = fromStr :+ '(' :+ term :+ ')';
    }

    int exprIndex = 1;
    _str toStr = "";

    foreach (term in gTo) {
        term = _escape_re_chars(term, 'U')
        if (length(toStr) == 0) {
            toStr = "$(";
        } else {
            toStr = toStr :+ '|';
        }
        toStr = toStr :+ '<' exprIndex '>' term;
        exprIndex++;
    }
    toStr = toStr :+ ')';
    #if 0
    // Push the replacement command to the clipboard
    _str cmd = "replace /" (fromStr) "/" (toStr) "/+IU%$"
    push_clipboard_itype( "CHAR",'',0,true);
    append_clipboard_text(cmd);
    #else
    // Open the replace dialog initialized with these regex's
    gui_replace_init_re(fromStr, toStr);
    #endif
}

_command int GetReplaceHistory() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_MDI_EDITORCTL|VSARG2_MACRO|VSARG2_MARK)
{
    _macro('R',1);

   _str form_name='_tbfind_form';
   if (form_name=='') return(1);
   int view_id=p_window_id;
   dialogs_view_id := _GetDialogHistoryViewId();
   p_window_id = dialogs_view_id;
   top();
   typeless status=search("^"form_name'\:',"@re");
   if (status) {
      activate_window(view_id);
      return(status);
   }
   _str line="";
   get_line(line);
//   say("LINE: " line);
   typeless NoflinesThatFollow="", NoflinesToCurRetrieve="";
   parse line with form_name':'NoflinesThatFollow NoflinesToCurRetrieve;
   save_pos(auto p);
   _str data="";
   _str findstr = '';
   _str replstr = '';
   int lineIndex = 0;
   while (lineIndex < NoflinesThatFollow) {
       ++lineIndex;
       down();
       get_line(data);
       boolean found = false;
       for (;;) {
          _str ctl_data="";
          parse data with (CTLSEPARATOR) ctl_data (CTLSEPARATOR) +0 data;
          if (ctl_data=="") break;
          typeless ctltype="", ctl_name="", value="";
          parse ctl_data with ctltype ctl_name':'value ;
          if (ctl_name=='') break;
          //say("ctltype:"ctltype", ctl_name: "ctl_name", value:" value);

          if (ctl_name == '_findtabs') {
              if (value == 2)
              {
                  found = true;
              }
          }
          if (ctl_name == '_findstring') {
              findstr = value;
          }
          if (ctl_name == '_replacestring') {
              replstr = value;
              //break;
          }
       }
       if (findstr != '' && replstr != '' && found) {
           say(findstr"==>"replstr);
       }
   }
   say("DONE index is "lineIndex);
   restore_pos(p);
   activate_window(view_id);
   return(rc);
}

