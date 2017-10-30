////////////////////////////////////////////////////////////////////////////////////
// Revision: 1 
////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#import "slick.sh"
#import "stdprocs.e"
#require "sc/lang/IToString.e"
#require "sc/lang/IHashable.e"
#require "sc/lang/IEquals.e"
#include "slickCompat.h"

// , sc.lang.IHashable
class WordInfo : sc.lang.IEquals, sc.lang.IToString
{
    private _str m_Word;            // (hash) The text to be highlighted
    private _str m_Color;           // (hash) The name of the color
    private boolean m_WordMatch;    // (hash) Whole-word matching
    private boolean m_Enabled;      // If coloring is enabled
    //private _str m_HashKey;         // The hash code to uniquely define this word

    _str toText()
    {
        return "WordInfo('"m_Word"', Color:"m_Color", m_WordMatch:"m_WordMatch", m_Enabled:"m_Enabled")";
    }
    WordInfo(_str word = '', _str color = "", boolean wordMatch = true)
    {
        m_Word = word;
        m_Color = color;
        m_Enabled = true;
        m_WordMatch = wordMatch;
        //m_HashKey._makeempty();
    }

    boolean equals(sc.lang.IEquals &rhs)
    {
        if (rhs==null)
        {
            return(this==null);
        }

        if (!(rhs instanceof "WordInfo"))
        {
            return false;
        }

        return m_Word == ((WordInfo)rhs).m_Word &&             
            m_Color == ((WordInfo)rhs).m_Color &&
            m_WordMatch == ((WordInfo)rhs).m_WordMatch &&
            m_Enabled == ((WordInfo)rhs).m_Enabled;
    }

    boolean isWholeWord()
    {
        return m_WordMatch;
    }

    boolean sym_color_is_valid_color()
    {
        if (m_Color != null && length(m_Color) > 0)
        {
            return true;
        }
        return false;
    }
    boolean enabled()
    {
        return m_Enabled;
    }
    _str toString()
    {
        return m_Word;
    }

    _str toStringDbg()
    {
        return(m_Enabled ? "E":"e") :+
            (m_WordMatch ? "W":"w") :+
            " " m_Color " " :+
            m_Word;
    }

    _str getHashKey()
    {
        return m_Word;
        //if (m_HashKey._isempty())
        //{
        //    m_HashKey = m_Word;// m_Color m_WordMatch;
        //}
        //return m_HashKey;
    }

    _str getColor() 
    {
        return m_Color;
    }

    void setWholeWord(boolean wholeWord)
    {
        m_WordMatch = wholeWord;
    }

    void setColor(_str color) 
    {
        //m_HashKey._makeempty();
        m_Color = color;
    }

    void setWord(_str word) 
    {
        //m_HashKey._makeempty();
        m_Word = word;
    }

    void setEnabled(boolean enabled)
    {
        m_Enabled = enabled;
    }

    _str getRe()
    {
        //say("*GetRE");
        if (m_WordMatch)
        {
            return "\\b" _escape_re_chars(m_Word, 'U') "\\b";
        }
        else
        {
            return _escape_re_chars(m_Word, 'U');
        }
    }
};

static void initGlobals()
{
}

static _str _ModuleName = "WordInfo";
definit()
{
    initGlobals();
    if (arg(1) == "L")
    {
        // Module load
        initsay("defInit Load "_ModuleName);
    }
    else
    {
        // Editor initialize
        initsay("defInit Init "_ModuleName);
    }
}

defload()
{
    initsay("defload " _ModuleName);
}
