/*
 * encodings.e
 * joe porkka
 *
 * This macro prints the encoding and line ending format of the current buffer to the status line
 * It also places this information on the clipboard   
 *  
 */

#pragma option(pedantic,on)

#include "slick.sh"
#import "clipbd.e"

static _str encodingEnum:[] = {

    VSENCODING_AUTOUNICODE               => "VSENCODING_AUTOUNICODE            ",
    VSENCODING_AUTOXML                   => "VSENCODING_AUTOXML                ",
    VSENCODING_AUTOEBCDIC                => "VSENCODING_AUTOEBCDIC             ",
    VSENCODING_AUTOUNICODE2              => "VSENCODING_AUTOUNICODE2           ",
    VSENCODING_AUTOEBCDIC_AND_UNICODE    => "VSENCODING_AUTOEBCDIC_AND_UNICODE ",
    VSENCODING_AUTOEBCDIC_AND_UNICODE2   => "VSENCODING_AUTOEBCDIC_AND_UNICODE2",
    VSENCODING_AUTOHTML                  => "VSENCODING_AUTOHTML               ",
    VSCP_ACTIVE_CODEPAGE                 => "SBCS/DBCS",
    VSCP_EBCDIC_SBCS                     => "VSCP_EBCDIC_SBCS",

    VSCP_CYRILLIC_KOI8_R                 => "VSCP_CYRILLIC_KOI8_R",                      //
    VSCP_ISO_8859_1                      => "VSCP_ISO_8859_1",                           //
    VSCP_ISO_8859_2                      => "VSCP_ISO_8859_2",                           //
    VSCP_ISO_8859_3                      => "VSCP_ISO_8859_3",                           //
    VSCP_ISO_8859_4                      => "VSCP_ISO_8859_4",                           //
    VSCP_ISO_8859_5                      => "VSCP_ISO_8859_5",                           //
    VSCP_ISO_8859_6                      => "VSCP_ISO_8859_6",                           //
    VSCP_ISO_8859_7                      => "VSCP_ISO_8859_7",                           //
    VSCP_ISO_8859_8                      => "VSCP_ISO_8859_8",                           //
    VSCP_ISO_8859_9                      => "VSCP_ISO_8859_9",                           //
    VSCP_ISO_8859_10                     => "VSCP_ISO_8859_10",                          //
    //   Any valid Windows code page          => "Any valid Windows code page         ",
    VSENCODING_UTF8                      => "VSENCODING_UTF8",
    VSENCODING_UTF8_WITH_SIGNATURE       => "VSENCODING_UTF8_WITH_SIGNATURE",
    VSENCODING_UTF16LE                   => "VSENCODING_UTF16LE",
    VSENCODING_UTF16LE_WITH_SIGNATURE    => "VSENCODING_UTF16LE_WITH_SIGNATURE",
    VSENCODING_UTF16BE                   => "VSENCODING_UTF16BE",
    VSENCODING_UTF16BE_WITH_SIGNATURE    => "VSENCODING_UTF16BE_WITH_SIGNATURE",
    VSENCODING_UTF32LE                   => "VSENCODING_UTF32LE",
    VSENCODING_UTF32LE_WITH_SIGNATURE    => "VSENCODING_UTF32LE_WITH_SIGNATURE",
    VSENCODING_UTF32BE                   => "VSENCODING_UTF32BE",

   VSENCODING_UTF32BE_WITH_SIGNATURE                      => "VSENCODING_UTF32BE_WITH_SIGNATURE                     ",
   VSENCODING_AUTOUNICODE|VSENCODING_AUTOTEXT             => "VSENCODING_AUTOUNICODE|VSENCODING_AUTOTEXT            ",
   VSENCODING_AUTOUNICODE2|VSENCODING_AUTOTEXT            => "VSENCODING_AUTOUNICODE2|VSENCODING_AUTOTEXT           ",
   VSENCODING_AUTOEBCDIC|VSENCODING_AUTOTEXT              => "VSENCODING_AUTOEBCDIC|VSENCODING_AUTOTEXT             ",
   VSENCODING_AUTOEBCDIC_AND_UNICODE|VSENCODING_AUTOTEXT  => "VSENCODING_AUTOEBCDIC_AND_UNICODE|VSENCODING_AUTOTEXT ",
   VSENCODING_AUTOEBCDIC_AND_UNICODE2|VSENCODING_AUTOTEXT => "VSENCODING_AUTOEBCDIC_AND_UNICODE2|VSENCODING_AUTOTEXT",
   VSENCODING_AUTOHTML5                                   => "VSENCODING_AUTOHTML5                                  ",
   VSENCODING_AUTOTEXTUNICODE                             => "VSENCODING_AUTOTEXTUNICODE                            ",

};

_str jEncodingToOption(int encoding)
{
   _str result = "";
   switch (encoding) {
   case VSCP_ACTIVE_CODEPAGE:                                   result = '+ftext';                     break;
   case VSCP_EBCDIC_SBCS:                                       result = '+febcdic';                   break;
   case VSENCODING_UTF8:                                        result = '+futf8';                     break;
   case VSENCODING_UTF8_WITH_SIGNATURE:                         result = '+futf8s';                    break;
   case VSENCODING_UTF16LE:                                     result = '+futf16le';                  break;
   case VSENCODING_UTF16LE_WITH_SIGNATURE:                      result = '+futf16les';                 break;
   case VSENCODING_UTF16BE:                                     result = '+futf16be';                  break;
   case VSENCODING_UTF16BE_WITH_SIGNATURE:                      result = '+futf16bes';                 break;
   case VSENCODING_UTF32LE:                                     result = '+futf32le';                  break;
   case VSENCODING_UTF32LE_WITH_SIGNATURE:                      result = '+futf32les';                 break;
   case VSENCODING_UTF32BE:                                     result = '+futf32be';                  break;
   case VSENCODING_UTF32BE_WITH_SIGNATURE:                      result = '+futf32bes';                 break;
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
       return "([" :+ encoding :+ "] " :+ encodingEnum:[encoding] :+ ")";
   }

   return "([" :+ encoding :+ "] " :+ result :+ ")";
}

_command void show_encoding() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
    // See manual for "load_files" for an explanation of the encoding.
    _str ending = "<NA>";
    if (p_newline=="\n") ending = "Unix (LF)";
    if (p_newline=="\r\n") ending = "Windows (CRLF)";
    if (p_newline=="\r") ending = "Mac (CR)";

    int e1 = p_encoding_set_by_user;
    int e2 = p_encoding;
    _str msg = ending :+ ", Encoding:":+jEncodingToOption(e2);
    message(msg);

    push_clipboard_itype( "CHAR",'',0,true);
    append_clipboard_text(msg);
}


