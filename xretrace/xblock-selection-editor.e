#include "slick.sh"

#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)



_form xblock_selection_editor_form {
   p_backcolor=0x80000005;
   p_border_style=BDS_DIALOG_BOX;
   p_caption="xblock selection editor form";
   p_forecolor=0x80000008;
   p_height=5800;
   p_width=3930;
   p_x=11130;
   p_y=3675;
   p_eventtab=xblock_selection_editor_form;
   _command_button goto_top_left_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto top left";
      p_default=false;
      p_height=465;
      p_tab_index=1;
      p_tab_stop=true;
      p_width=1530;
      p_x=360;
      p_y=120;
   }
   _command_button goto_top_right_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto top right";
      p_default=false;
      p_height=465;
      p_tab_index=2;
      p_tab_stop=true;
      p_width=1530;
      p_x=2040;
      p_y=120;
   }
   _command_button goto_maxline_start_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto maxline start";
      p_default=false;
      p_height=465;
      p_tab_index=3;
      p_tab_stop=true;
      p_width=1530;
      p_x=360;
      p_y=760;
   }
   _command_button goto_maxline_end_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto maxline end";
      p_default=false;
      p_height=465;
      p_tab_index=4;
      p_tab_stop=true;
      p_width=1530;
      p_x=2040;
      p_y=760;
   }
   _command_button goto_bottom_left_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto bottom left";
      p_default=false;
      p_height=465;
      p_tab_index=5;
      p_tab_stop=true;
      p_width=1530;
      p_x=360;
      p_y=1400;
   }
   _command_button goto_bottom_right_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="goto bottom right";
      p_default=false;
      p_height=465;
      p_tab_index=6;
      p_tab_stop=true;
      p_width=1530;
      p_x=2040;
      p_y=1400;
   }
   _command_button continue_selection_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="continue selection";
      p_default=false;
      p_height=465;
      p_tab_index=7;
      p_tab_stop=true;
      p_width=1530;
      p_x=330;
      p_y=4290;
   }
   _command_button clear_selection_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="clear selection";
      p_default=false;
      p_height=465;
      p_tab_index=8;
      p_tab_stop=true;
      p_width=1560;
      p_x=2010;
      p_y=4290;
   }
   _command_button close_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="close    close   close";
      p_default=false;
      p_height=540;
      p_tab_index=9;
      p_tab_stop=true;
      p_width=3255;
      p_x=345;
      p_y=4875;
   }
   _command_button top_up_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="top up";
      p_default=false;
      p_height=450;
      p_tab_index=10;
      p_tab_stop=true;
      p_width=1020;
      p_x=900;
      p_y=2055;
   }
   _command_button top_down_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="top down";
      p_default=false;
      p_height=450;
      p_tab_index=11;
      p_tab_stop=true;
      p_width=1050;
      p_x=1980;
      p_y=2055;
   }
   _command_button left_left_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="left left";
      p_default=false;
      p_height=435;
      p_tab_index=12;
      p_tab_stop=true;
      p_width=975;
      p_x=525;
      p_y=2565;
   }
   _command_button left_right_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="left right";
      p_default=false;
      p_height=435;
      p_tab_index=13;
      p_tab_stop=true;
      p_width=975;
      p_x=525;
      p_y=3075;
   }
   _command_button right_left_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="right left";
      p_default=false;
      p_height=435;
      p_tab_index=14;
      p_tab_stop=true;
      p_width=960;
      p_x=2370;
      p_y=2565;
   }
   _command_button right_right_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="right right";
      p_default=false;
      p_height=435;
      p_tab_index=15;
      p_tab_stop=true;
      p_width=960;
      p_x=2370;
      p_y=3060;
   }
   _command_button bottom_up_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="bottom up";
      p_default=false;
      p_height=450;
      p_tab_index=16;
      p_tab_stop=true;
      p_width=990;
      p_x=900;
      p_y=3585;
   }
   _command_button bottom_down_btn {
      p_auto_size=false;
      p_cancel=false;
      p_caption="bottom down";
      p_default=false;
      p_height=450;
      p_tab_index=17;
      p_tab_stop=true;
      p_width=1065;
      p_x=1950;
      p_y=3585;
   }
}

defeventtab xblock_selection_editor_form;


static void find_longest_line(
   int & the_line = 0, int & max_col = 0, int start_line = 0, int endline = 2000000)
{
   int max_loops = 1000000;
   max_col = 1;
   the_line = start_line;
   typeless p2;
   save_pos(p2);
   goto_line(start_line);
   while (--max_loops) {
      end_line();
      if (p_col > max_col) {
         the_line = p_line;
         max_col = p_col;
      }
      if (down() || p_line > endline)
         break;
   }
   restore_pos(p2);
}

struct xregion {
   int top_left_pcol;
   int top_left_pline;
   int bottom_right_pcol;
   int bottom_right_pline;
   int max_line;
   int max_col;
};


static void reselect_region(xregion ra)
{
   _deselect();
   _mdi.p_child.p_line = ra.top_left_pline; 
   _mdi.p_child.p_col = ra.top_left_pcol;
   _mdi.p_child.select_block();
   _mdi.p_child.p_line = ra.bottom_right_pline; 
   _mdi.p_child.p_col = ra.bottom_right_pcol;
}

static void reselect_and_lock_region(xregion ra)
{
   reselect_region(ra);
   _mdi.p_child.select_block();
}


_command xregion xblock_resize_right() name_info(','VSARG2_REQUIRES_EDITORCTL|VSARG2_READ_ONLY|VSARG2_MARK|VSARG2_REQUIRES_BLOCK_SELECTION|VSARG2_REQUIRES_AB_SELECTION)
{
   typeless p1;
   save_pos(p1);
   xregion ra;

   _begin_select();
   ra.top_left_pcol = p_col;
   ra.top_left_pline = p_line;
   _end_select();
   ra.bottom_right_pcol = p_col;
   ra.bottom_right_pline = p_line;

   find_longest_line(ra.max_line, ra.max_col, ra.top_left_pline, ra.bottom_right_pline);
   if (ra.max_col != ra.bottom_right_pcol) {
      ra.bottom_right_pcol = ra.max_col - 1;
      reselect_and_lock_region(ra);
   }
   return ra;
}


static xregion xra;
static int xblock_editor_wid;

_command void xblock_resize_editor() name_info(','VSARG2_REQUIRES_EDITORCTL|VSARG2_READ_ONLY|VSARG2_MARK|VSARG2_REQUIRES_BLOCK_SELECTION|VSARG2_REQUIRES_AB_SELECTION)
{
   xregion ra;
   ra = xblock_resize_right();
   xblock_editor_wid = show( "-mdi  xblock_selection_editor_form", ra );
}


xblock_selection_editor_form.on_create(xregion ra)
{
   xra = ra;
}

static void goto_bottom_right()
{
   _mdi.p_child.p_line = xra.bottom_right_pline;
   _mdi.p_child.p_col = xra.bottom_right_pcol;
   _mdi.p_child._set_focus();
}
void goto_bottom_right_btn.lbutton_up()
{
   goto_bottom_right();
}

static void goto_bottom_left()
{
   _mdi.p_child.p_line = xra.bottom_right_pline;
   _mdi.p_child.p_col = xra.top_left_pcol;
   _mdi.p_child._set_focus();
}
void goto_bottom_left_btn.lbutton_up()
{
   goto_bottom_left();
}

static void goto_maxline_end()
{
   _mdi.p_child.p_line = xra.max_line;
   _mdi.p_child.p_col = xra.max_col;
   _mdi.p_child._set_focus();
}
void goto_maxline_end_btn.lbutton_up()
{
   goto_maxline_end();
}

static void goto_maxline_start()
{
   _mdi.p_child.p_line = xra.max_line;
   _mdi.p_child.p_col = xra.top_left_pcol;
   _mdi.p_child._set_focus();
}
void goto_maxline_start_btn.lbutton_up()
{
   goto_maxline_start();
}

static void goto_top_right()
{
   _mdi.p_child.p_line = xra.top_left_pline;
   _mdi.p_child.p_col = xra.bottom_right_pcol;
   _mdi.p_child._set_focus();
}
void goto_top_right_btn.lbutton_up()
{
   goto_top_right();
}

static void goto_top_left()
{
   _mdi.p_child.p_line = xra.top_left_pline;
   _mdi.p_child.p_col = xra.top_left_pcol;
   _mdi.p_child._set_focus();
}
void goto_top_left_btn.lbutton_up()
{
   goto_top_left();
}

void bottom_down_btn.lbutton_up()
{
   typeless p2;
   _mdi.p_child.save_pos(p2);
   _mdi.p_child.bottom_of_buffer();
   if (_mdi.p_child.p_line > xra.bottom_right_pline) {
      ++xra.bottom_right_pline;
      reselect_and_lock_region(xra);
   }
   else
   {
      _mdi.p_child.restore_pos(p2);
   }
}

void bottom_up_btn.lbutton_up()
{
   if (xra.bottom_right_pline > (xra.top_left_pline + 1)) {
      --xra.bottom_right_pline;
      reselect_and_lock_region(xra);
   }
}

void right_right_btn.lbutton_up()
{
   ++xra.bottom_right_pcol;
   reselect_and_lock_region(xra);
}

void left_right_btn.lbutton_up()
{
   if (xra.top_left_pcol < (xra.bottom_right_pcol - 1)) {
      ++xra.top_left_pcol;
      reselect_and_lock_region(xra);
   }
}

void right_left_btn.lbutton_up()
{
   if (xra.bottom_right_pcol > (xra.top_left_pcol + 1)) {
      --xra.bottom_right_pcol;
      reselect_and_lock_region(xra);
   }
}

void left_left_btn.lbutton_up()
{
   if (xra.top_left_pcol > 1) {
      --xra.top_left_pcol;
      reselect_and_lock_region(xra);
   }
}

void top_down_btn.lbutton_up()
{
   if (xra.top_left_pline < (xra.bottom_right_pline - 1)) {
      ++xra.top_left_pline;
      reselect_and_lock_region(xra);
   }
   goto_top_left();
}

void top_up_btn.lbutton_up()
{
   if (xra.top_left_pline > 0) {
      --xra.top_left_pline;
      reselect_and_lock_region(xra);
   }
   goto_top_left();
}

void close_btn.lbutton_up()
{
   xblock_editor_wid._delete_window();
}

void clear_selection_btn.lbutton_up()
{
   _deselect();
   _mdi.p_child.p_line = xra.top_left_pline;
   _mdi.p_child.p_col = xra.top_left_pcol;
   xblock_editor_wid._delete_window();
}

void continue_selection_btn.lbutton_up()
{
   reselect_region(xra);
   xblock_editor_wid._delete_window();
}



