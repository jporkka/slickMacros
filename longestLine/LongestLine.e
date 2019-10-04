/*
 * LongestLine.e
 * joe porkka
 *
 * This macro scans the current buffer for the longest line.
 *   
 * Soft-wrap doesn't affect which line is the longest.
 * 
 * It also detects "hard wrap". In Tools > Options > File Options > Load "Wrap line length". In cases other than simple SBCS/DBCS buffers Slick will break really long lines into shorter lines.
 * 
 * This function can detect these lines and will correctly find the real longest line.
 * This is and enhancement of the code posted by Graeme: https://community.slickedit.com/index.php/topic,11383.msg48081.html#msg48081 
 *  
 */

//#pragma option(pedantic,on)
#pragma option(strict,on)
#pragma option(strict2,on)
#include "slick.sh"    
#import "pushtag.e"
#import "util.e"
#import "markfilt.e"
#import "stdprocs.e"

/**
 * retrieves selected text, first and last line number of an existing normal or line selection
 *
 * @param seltext    [out] selected text if any
 * @param bline      [out] line number begin of selection
 * @param eline      [out] line number end of selection
 * @param doDeselect [in]  clear current selection [default: true]
 *
 * @return  0  -> OK
 *          TEXT_NOT_SELECTED_RC
 */
static int get_sel_text_range( int &bline, int &eline)
{
   int rc = TEXT_NOT_SELECTED_RC;
   if ( select_active2() )
   {
      typeless p; _save_pos2( p );

      _begin_select( '', false, true);
      bline = p_RLine;

      _end_select( '', false, true);
      eline = p_RLine;

      _restore_pos2( p );
      rc = 0;

      //say(" bline: " bline " eline:" eline ", end col:" p_col);
      if (p_col == 1 && eline > bline) {
          --eline;
      }
      //seltext = get_text( (int)(epos - bpos), (int)bpos );
      //say("bline="bline", eline="eline);
   }

   return rc;
}
_command void column_select() name_info(','VSARG2_MARK|VSARG2_REQUIRES_EDITORCTL|VSARG2_READ_ONLY)
{
    say("T '" _select_type('', "T") "'");
    say("S '" _select_type('', "S") "'");
    say("P '" _select_type('', "P") "'");
    say("I '" _select_type('', "I") "'");
    int bline;
    int eline;

    get_sel_text_range(bline, eline);
    say("bline="bline", eline="eline);
}

static void findLongest(int loops, int eline, int &maxSpannedLength, int &longestRLineSpanned, boolean &isWrapped)
{
    isWrapped = false;
    maxSpannedLength = 0;
    longestRLineSpanned = 0;

    int maxLineLength = 0;
    int longestRLine = 0;
    int previousLineNo = -1;
    boolean isSpanningLine = false;
    int spanLength = 0;
    int eof = 0;
    int pcolSave = 0;

    while (--loops && !eof && (eline == -1 || p_line <= eline)) {
        _end_line();
        pcolSave = p_col - 1;
        if (pcolSave > maxLineLength) {
            if ((_lineflags() & (HIDDEN_LF | NOSAVE_LF)) == 0) {
                longestRLine = p_RLine;
                maxLineLength = pcolSave;
            }
        }

        eof = down();

        if (previousLineNo == p_RLine) {
            // A single "real" line may span multiple lines in the buffer.
            // See "Wrap Line Length" in Tools > Options > File Options > Load
            // This is not soft-wrap.
            // In this case, down() will not change the value of "p_RLine".
            isSpanningLine = true;
            spanLength += pcolSave;
        } else {
            if (isSpanningLine) {
                // Just past end of split line.
                if (spanLength > maxSpannedLength) {
                    if ((_lineflags() & (HIDDEN_LF | NOSAVE_LF)) == 0) {
                        spanLength += pcolSave;
                        longestRLineSpanned = previousLineNo;
                        maxSpannedLength = spanLength;
                    }
                }

                isSpanningLine = false;
                spanLength = 0;
            }
        }
        previousLineNo = p_RLine;
    }
    if (maxLineLength > maxSpannedLength) {
        longestRLineSpanned = longestRLine;
        maxSpannedLength = maxLineLength;
    }
    if (maxLineLength != maxSpannedLength) {
        isWrapped = true;
    }
}

_command void find_the_longest_line() name_info(','VSARG2_MARK|VSARG2_MACRO|VSARG2_READ_ONLY)
{
    int bline = -1;
    int eline = -1;

    int linesLimit = 9000000; // Prevent endless search...

    int maxSpannedLength = 0;
    int longestRLineSpanned = 0;
    boolean isWrapped = false;

    push_bookmark();

    int old_mark;
    _str mark_status=save_selection(old_mark);
    if (get_sel_text_range(bline, eline) == 0)
    {
        typeless p; _save_pos2( p );
        goto_line(bline);

        findLongest(linesLimit, eline, maxSpannedLength, longestRLineSpanned, isWrapped);

        if ( ! mark_status ) {
           restore_selection(old_mark);
        }
        _restore_pos2( p );
    }
    else
    {
        top();
        findLongest(linesLimit, eline, maxSpannedLength, longestRLineSpanned, isWrapped);
        goto_line(longestRLineSpanned);
        _end_line();
    }


    _str msg = "Longest line length:" :+ maxSpannedLength :+ "\nLine:" :+ longestRLineSpanned;
    if (isWrapped) {
        msg = "Longest line is wrapped.\n" :+ msg;
    }

    int loops = 1;
    if (loops <= 0) {
        msg = "Line limit exceeded!! (limit is " linesLimit " lines.)\n" :+ msg;
    }
    _message_box(msg);
}

