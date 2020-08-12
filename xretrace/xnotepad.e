#include 'slick.sh'

static /*int*/ notepad_number()
{
   return('');
}

#define MAX_WIDTH_IN_PIXELS 800
#define INITIAL_HEIGHT    4000
#define INITIAL_WIDTH   3000

typeless def_notepad_font = '';


static int pix2scale(int pix,int wid)
{
   return _dx2lx(wid.p_xyscale_mode, pix);
}

static int scale2pix(int scale,int wid)
{
   return _lx2dx(wid.p_xyscale_mode, scale);
}



static _str get_the_longest_line() 
{
   int loops = 100000;
   int maxl = 0;
   int ll = 0;
   top();
   while (--loops) {
      end_line();
      if (p_col > maxl) {
         ll = p_line;
         maxl = p_col;
      }
      if (down())
         break;
   }
   goto_line(ll);
   get_line(ss);
   return ss;
}


_command void xnotepad_word() name_info(',')
{
   xnotepad(true);
}




/* places selected text in a floating 'notepad' window.  If a notepad window
   already exists, current selection is appended.
*/
_command xnotepad(boolean select_word = false, _str string1 = '') name_info(','MARK_ARG2|VSARG2_MULTI_CURSOR|VSARG2_REQUIRES_EDITORCTL|VSARG2_READ_ONLY)
{
   typeless p;
   save_pos(p);
   int pwin = p_window_id;
   boolean no_selection = false;

   if ( !select_active() ) {
      no_selection = true;
      if (select_word) 
         select_whole_word();
      else
         select_line();
   }

   if (select_active()) {
      _str select_type = _select_type();
      typeless oldsel = _duplicate_selection();
      wid = _find_object('notepadform','n');
      if (!wid) {

         _mdi.p_child._GetVisibleScreen(auto screen_x, auto screen_y, auto screen_width, auto screen_height);
         int screen_midpt_x = (screen_width intdiv 2);
         int screen_midpt_y = (screen_height intdiv 2);

         wid = _create_window(OI_FORM,
                              _mdi,
                              'Notepad 'notepad_number(),
                              _dx2lx(SM_TWIP, screen_midpt_x - 300),   // create window needs twips
                              _dy2ly(SM_TWIP, screen_midpt_y - 300),
                              INITIAL_WIDTH,//width
                              INITIAL_HEIGHT, //height
                              CW_PARENT,
                              BDS_SIZABLE);

         wid.p_name = 'notepadform';

         if (wid) {
            editorwid = _create_window(OI_EDITOR,
                                       wid,
                                       '', // Title
                                       - _twips_per_pixel_x(), // x - yep, this is negative
                                       - _twips_per_pixel_y(), // y
                                       wid.p_width - _twips_per_pixel_x(),
                                       wid.p_height - _twips_per_pixel_y(),
                                       CW_CHILD);
            int wid2 = p_window_id;
            p_window_id = editorwid;
            p_auto_size = 0;
            p_multi_select = MS_EDIT_WINDOW;
            p_scroll_bars = SB_BOTH;
            p_width = (wid.p_client_width + 2) * _twips_per_pixel_x();
            p_height = (wid.p_client_height + 2) * _twips_per_pixel_y();
            p_name = 'editwin';
            if (def_notepad_font != '') {
               parse def_notepad_font with fname','fsize;
               p_font_name = fname;
               if (fsize != '') {
                  p_font_size = fsize;
               }
            }
            else
            {
               def_notepad_font = p_font_name :+ ',' :+ p_font_size;
            }
            editorwid.top();
            editorwid.delete_line();

            if ( string1 != '' ) {
               editorwid.insert_line(string1);
            }
            else if ( select_type != 'LINE' ) 
               editorwid.insert_line('');

            p_window_id = wid2;
            index = find_index('notepad_resize', EVENTTAB_TYPE);
            if (index) {
               wid.p_eventtab = index;
            }
         }
      }
      else {
         _control editwin;
         editorwid = wid.editwin;
         if ( select_type == 'LINE' ) {
            editorwid.bottom();
            editorwid.up();
            editorwid.end_line();
         }
         else
         {
            editorwid.bottom();
            editorwid.begin_line();
         }
      }
      _mdi._set_focus();
      editorwid._copy_to_cursor();
      if (select_type == 'CHAR' || select_type == 'BLOCK') {
         editorwid.insert_line('');
      }
      _str ss = editorwid.get_the_longest_line();
      editorwid.bottom();
      editorwid.begin_line();
      int ww = editorwid._text_width(ss) + pix2scale(50, editorwid);
      editorwid.get_line(ss);
      if ( ss != '' ) {
         editorwid.end_line();
         editorwid.insert_line('');
      }
      if ( ww > pix2scale(MAX_WIDTH_IN_PIXELS, editorwid) ) {
         ww = pix2scale(MAX_WIDTH_IN_PIXELS, editorwid);
      }
      if ( ww > wid.p_width ) {
         wid.p_width = ww;
         editorwid.p_width = wid.p_width; 
      }
      _deselect();
      _mdi.p_child._set_focus();
      activate_window(pwin);
      restore_pos(p);
      if ( !no_selection ) 
         _show_selection(oldsel);
   }
}

defeventtab notepad_resize

notepad_resize.on_resize()
{
   int x = _control editwin;
   int wid = p_window_id;
   p_window_id = x;
   p_width = (wid.p_client_width + 2) * _twips_per_pixel_x();
   p_height = (wid.p_client_height + 2) * _twips_per_pixel_y();
   p_window_id = wid;
}


