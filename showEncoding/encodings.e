/*
 * encodings.e
 * joe porkka
 *
 * This macro prints the encoding and line ending format of the current buffer to the status line
 * It also places this information on the clipboard   
 *  
 */

//#pragma option(pedantic,on)
#pragma option(strict,on)
#pragma option(strict2,on)

#include "slick.sh"
#import "clipbd.e"
#import "files.e"
#import "listbox.e"

static _str encodingEnum:[] = {

    VSENCODING_AUTOUNICODE               => "AutoUnicode",
    VSENCODING_AUTOXML                   => "AutoXml",
    VSENCODING_AUTOEBCDIC                => "AutoEbcdic",
    VSENCODING_AUTOUNICODE2              => "AutoUnicode2",
    VSENCODING_AUTOEBCDIC_AND_UNICODE    => "AutoEbcdic and Unicode",
    VSENCODING_AUTOEBCDIC_AND_UNICODE2   => "AutoEbcdic and Unicode2",
    VSENCODING_AUTOHTML                  => "AutoHTML",
    VSCP_ACTIVE_CODEPAGE                 => "SBCS/DBCS",
    VSCP_EBCDIC_SBCS                     => "EBCDIC_SBCS",

    VSCP_CYRILLIC_KOI8_R                 => "CYRILLIC_KOI8_R",                      //
    VSCP_ISO_8859_1                      => "ISO_8859_1",                           //
    VSCP_ISO_8859_2                      => "ISO_8859_2",                           //
    VSCP_ISO_8859_3                      => "ISO_8859_3",                           //
    VSCP_ISO_8859_4                      => "ISO_8859_4",                           //
    VSCP_ISO_8859_5                      => "ISO_8859_5",                           //
    VSCP_ISO_8859_6                      => "ISO_8859_6",                           //
    VSCP_ISO_8859_7                      => "ISO_8859_7",                           //
    VSCP_ISO_8859_8                      => "ISO_8859_8",                           //
    VSCP_ISO_8859_9                      => "ISO_8859_9",                           //
    VSCP_ISO_8859_10                     => "ISO_8859_10",                          //
    //   Any valid Windows code page          => "Any valid Windows code page         ",
    VSENCODING_UTF8                      => "UTF-8",
    VSENCODING_UTF8_WITH_SIGNATURE       => "UTF-8-sig",
    VSENCODING_UTF16LE                   => "UTF-16LE",
    VSENCODING_UTF16LE_WITH_SIGNATURE    => "UTF-16LE-sig",
    VSENCODING_UTF16BE                   => "UTF-16BE",
    VSENCODING_UTF16BE_WITH_SIGNATURE    => "UTF-16BE-sig",
    VSENCODING_UTF32LE                   => "UTF-32LE",
    VSENCODING_UTF32LE_WITH_SIGNATURE    => "UTF-32LE-sig",
    VSENCODING_UTF32BE                   => "UTF-32BE",

   VSENCODING_UTF32BE_WITH_SIGNATURE                      => "UTF-32BE-sig",
   VSENCODING_AUTOUNICODE|VSENCODING_AUTOTEXT             => "AutoUnicode|autotext",
   VSENCODING_AUTOUNICODE2|VSENCODING_AUTOTEXT            => "AutoUnicode2|autotext",
   VSENCODING_AUTOEBCDIC|VSENCODING_AUTOTEXT              => "AutoEbcdic|autotext",
   VSENCODING_AUTOEBCDIC_AND_UNICODE|VSENCODING_AUTOTEXT  => "AutoEbcdic and Unicode|autotext",
   VSENCODING_AUTOEBCDIC_AND_UNICODE2|VSENCODING_AUTOTEXT => "AutoEbcdic and Unicode2|autotext",
   VSENCODING_AUTOHTML5                                   => "AutoHtml5",
   VSENCODING_AUTOTEXTUNICODE                             => "Auto Text Unicode",

};

static void DbgSay(_str saystring)
{
}

_command dumpinfo() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_MDI_EDITORCTL|VSARG2_MACRO|VSARG2_MARK)
{
    //_str msg;
    // p_buf_name

    DbgSay("------");
    DbgSay("BufName:" :+ p_buf_name);
    DbgSay("Encoding is " :+ encodingEnum:[p_encoding]);
    if (p_UTF8 == 0)
        DbgSay("UTF-8 ZERO" :+ p_UTF8);
    else
        DbgSay("UTF-8 " :+ p_UTF8);

    _str n1 = "";
    _str n2 = "";
    int l = length(p_newline);
    int c1=_asc(substr(p_newline,1,1));
    if (c1 == 10) {
        n1 = "LF";
    } else if (c1 == 13) {
        n1 = "CR";
    } else {
        n1 = "<" :+ c1 :+ ">";
    }
    if (l > 1) {
        int c2=_asc(substr(p_newline,2,1));
        if (c2 == 10) {
            n2 = ", LF";
        } else if (c2 == 13) {
            n2 = ", CR";
        } else {
            n2 = ", <" :+ c2 :+ ">";
        }
    }
    DbgSay("NEWLINES: length=" :+ l :+ ", " :+ n1 :+ n2);

    //if (l == 1) {
    //    p_newline = "\r\n";
    //    //DbgSay("NEWLINES: length=" :+ l :+ ", " :+ c1 :+ ", " :+ c2);
    //} else {
    //    p_newline = "\n";
    //    //DbgSay("NEWLINES: " :+ c1 :+ ", " :+ c2);
    //}
}

_str jEncodingToOption(int encoding)
{
   _str result = "";
   switch (encoding) {
   case VSCP_ACTIVE_CODEPAGE:                                   result = '+ftext';                     break;
   case VSCP_EBCDIC_SBCS:                                       result = '+febcdic';                   break;
   case VSENCODING_UTF8:                                        result = '+fUTF-8';                     break;
   case VSENCODING_UTF8_WITH_SIGNATURE:                         result = '+fUTF-8s';                    break;
   case VSENCODING_UTF16LE:                                     result = '+fUTF-16le';                  break;
   case VSENCODING_UTF16LE_WITH_SIGNATURE:                      result = '+fUTF-16les';                 break;
   case VSENCODING_UTF16BE:                                     result = '+fUTF-16be';                  break;
   case VSENCODING_UTF16BE_WITH_SIGNATURE:                      result = '+fUTF-16bes';                 break;
   case VSENCODING_UTF32LE:                                     result = '+fUTF-32le';                  break;
   case VSENCODING_UTF32LE_WITH_SIGNATURE:                      result = '+fUTF-32les';                 break;
   case VSENCODING_UTF32BE:                                     result = '+fUTF-32be';                  break;
   case VSENCODING_UTF32BE_WITH_SIGNATURE:                      result = '+fUTF-32bes';                 break;
   case VSENCODING_AUTOUNICODE:                                 result = '+fautounicode';              break;
   case VSENCODING_AUTOUNICODE|VSENCODING_AUTOTEXT:             result = '+fautounicode,text';         break;
   case VSENCODING_AUTOUNICODE2:                                result = '+fautounicode2';             break;
   case VSENCODING_AUTOUNICODE2|VSENCODING_AUTOTEXT:            result = '+fautounicode2,text';        break;
   case VSENCODING_AUTOEBCDIC:                                  result = '+fautoebcdic';               break;
   case VSENCODING_AUTOEBCDIC|VSENCODING_AUTOTEXT:              result = '+fautoebcdic,text';          break;
   case VSENCODING_AUTOEBCDIC_AND_UNICODE:                      result = '+fautoebcdic,unicode';       break;
   case VSENCODING_AUTOEBCDIC_AND_UNICODE|VSENCODING_AUTOTEXT:  result = '+fautoebcdic,unicode,text';  break;
   case VSENCODING_AUTOEBCDIC_AND_UNICODE2:                     result = '+fautoebcdic,unicode2';      break;
   case VSENCODING_AUTOEBCDIC_AND_UNICODE2|VSENCODING_AUTOTEXT: result = '+fautoebcdic,unicode2,text'; break;
   case VSENCODING_AUTOXML:                                     result = '+fautoxml';                  break;
   case VSENCODING_AUTOHTML:                                    result = '+fautohtml';                 break;
   case VSENCODING_AUTOHTML5:                                   result = '+fautohtml5';                break;
   case VSENCODING_AUTOTEXT:                                    result = '+fautotext';                 break;
   case VSENCODING_AUTOTEXTUNICODE:                             result = '+fautotextunicode';          break;
   default:                                                     result = '(+fcp'encoding')';           break;
   }

   if (encodingEnum._indexin(encoding))
   {
       return encodingEnum:[encoding];
   }

   return "[" :+ encoding :+ "] " :+ result;
}

_str getEncoding(int bufid)
{
    // See manual for "load_files" for an explanation of the encoding.
    auto orig_buf_id=p_buf_id;
    p_buf_id = bufid;
    _str ending = "<NA>";
    if (p_newline=="\n") ending = "Unix (LF)";
    if (p_newline=="\r\n") ending = "Windows (CRLF)";
    if (p_newline=="\r") ending = "Mac (CR)";

    int e1 = p_encoding_set_by_user;
    int e2 = p_encoding;
    //_str msg = ending :+ ", User:":+jEncodingToOption(e1):+", buffer:":+jEncodingToOption(e2);
    _str msg = ending :+ ", Encoding:":+jEncodingToOption(e2);

    p_buf_id = orig_buf_id;

    return msg;
}

_str getEncodingStatus(int bufid)
{
    // See manual for "load_files" for an explanation of the encoding.
    auto orig_buf_id=p_buf_id;
    p_buf_id = bufid;
    _str ending = "<NA>";
    if (p_newline=="\n") ending = "LF";
    if (p_newline=="\r\n") ending = "CRLF";
    if (p_newline=="\r") ending = "CR";

    int e1 = p_encoding_set_by_user;
    int e2 = p_encoding;
    //_str msg = ending :+ ", User:":+jEncodingToOption(e1):+", buffer:":+jEncodingToOption(e2);
    _str msg = ending :+ ", ":+jEncodingToOption(e2);

    p_buf_id = orig_buf_id;

    return msg;
}

_command void swap_encoding() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
    // See manual for "load_files" for an explanation of the encoding.
    int e1 = p_encoding_set_by_user;
    int e2 = p_encoding;
    //message("User:":+_EncodingToOption(e1):+", buffer:":+_EncodingToOption(e2));
    dumpinfo();

    _str savePath = p_buf_name;
    boolean saveUTF8 = p_UTF8;

    if (!close_buffer()) {

        if (saveUTF8 == true) {
            DbgSay("Reload as TEXT " :+ savePath);
            load_files("+U +FTEXT " :+ savePath);
        } else {
            DbgSay("Reload as UTF-16 " :+ savePath);
            load_files("+U +FUTF-16LE " :+ savePath);
        }
    }
}

_command void swap_ending() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
    _str savePath = p_buf_name;
    int l = length(p_newline);
    int c1=_asc(substr(p_newline,1,1));
    int c2=_asc(substr(p_newline,2,1));
    DbgSay("NEWLINES: length=" :+ l :+ ", " :+ c1 :+ ", " :+ c2);

    if (!close_buffer()) {

        if (l == 1) {
            DbgSay("Reload as DOS" :+ savePath);
            load_files("+U +FD " :+ savePath);
        } else {
            DbgSay("Reload as UNIX" :+ savePath);
            load_files("+U +FU " :+ savePath);
        }
    }
}


defeventtab _tbstatus_combo_etab;
_tbstatus_combo_etab.ENTER()
{

}
_tbstatus_combo_etab.on_create()
{
    //say("Created text control _tbstatus_combo_etab height="p_height);
    p_width = 2500;
    p_pic_point_scale=8;
    p_style=PSCBO_NOEDIT;
    p_enabled=false;
}

#define JPSTATUS_FORM "tbform4"

CTL_FORM status_gui_sessions_wid()
{
   static CTL_FORM form_wid;

   if (_iswindow_valid(form_wid) && !form_wid.p_edit &&
       form_wid.p_object==OI_FORM && form_wid.p_name==JPSTATUS_FORM) {
      return(form_wid);
   }

   form_wid=_find_formobj(JPSTATUS_FORM,'N');
   return(form_wid);
}

void _switchbuf_encodings(...)
{
    _str msg = getEncodingStatus(p_buf_id);
    auto form = status_gui_sessions_wid();
    //say ("_switchbuf_encodings: p_buf_name: " p_buf_name ", encoding:" msg);
    if (form) {
       // say("msg"msg", form"form", "form._tbstatus_combo_etab);
        auto wid = form._tbstatus_combo_etab;
        wid._lbclear();
        //wid._lbadd_item("no debugger sessions");
        wid._lbadd_item(msg);

        wid.p_text = msg;
    }
}

_command void show_encoding() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
    _str msg = getEncoding(p_buf_id);
    //say(msg);
    message(msg);

    push_clipboard_itype( "CHAR",'',0,true);
    append_clipboard_text(msg);
    
    auto form = status_gui_sessions_wid();
    if (form) {
       // say("msg"msg", form"form", "form._tbstatus_combo_etab);
        auto wid = form._tbstatus_combo_etab;
        wid._lbclear();
        //wid._lbadd_item("no debugger sessions");
        wid._lbadd_item(msg);

        wid.p_text = msg;
    }

    //    dumpinfo();
}


