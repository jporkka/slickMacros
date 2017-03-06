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

#pragma option(pedantic,on)
#include "slick.sh"    
#import "pushtag.e"
#import "util.e"

_command void find_the_longest_line() name_info(','VSARG2_MACRO|VSARG2_REQUIRES_EDITORCTL|VSARG2_READ_ONLY)
{
    int linesLimit = 9000000; // Prevent endless search...
    int loops = linesLimit;

    push_bookmark();
    top();

    int maxLineLength = 0;
    int longestRLine = 0;

    int maxSpannedLength = 0;
    int longestRLineSpanned = 0;

    int previousLineNo = -1;
    boolean isSpanningLine = false;
    int spanLength = 0;

    int longestSplit = 0;

    int eof = 0;
    while (--loops && !eof) {
        _end_line();
        if (p_col > maxLineLength) {
            longestRLine = p_RLine;
            maxLineLength = p_col;
        }

        eof = down();

        if (previousLineNo == p_RLine) {
            isSpanningLine = true;
            spanLength += p_col;
        } else {
            if (isSpanningLine) {
                // Just past end of split line.
                if (spanLength > maxSpannedLength) {
                    longestRLineSpanned = previousLineNo;
                    maxSpannedLength = spanLength;
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
    goto_line(longestRLineSpanned);
    _end_line();

    _str msg = "Longest line length:" :+ maxSpannedLength :+ "\nLine:" :+ longestRLineSpanned;
    if (maxLineLength != maxSpannedLength) {
        msg = "Longest line is wrapped.\n" :+ msg;
    }

    if (loops <= 0) {
        msg = "Line limit exceeded!! (limit is " linesLimit " lines.)\n" :+ msg;
    }
    _message_box(msg);
}


