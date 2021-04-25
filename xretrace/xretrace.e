
#include "slick.sh"

#import 'DLinkList.e'

#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)

#import "xload-macros.e"


#define XRETRACE_MODULE_NAME XRETRACE_PATH :+ 'xretrace.e'

#define  XRETRACE_DATA_PATH  'c:/temp'
#define  XRETRACE_USE_SUBFOLDER YES

#define XRETRACE_INCLUDING
#include "xretrace_control_panel.e"

// xretrace_control_panel is normally #INCLUDEd by xretrace.e 


/******************************************************************************
 *  
 * xretrace allows you to retrace cursor movement or retrace modified lines.
 *  
 * 
 * << retrace regions >>
 * =====================
 * The retrace doesn't go to every single line that was modified or visited. 
 * Instead, it steps through "regions" where the size of a region is set by a 
 * configurable parameter - "retrace cursor line distance recording 
 * granularity".  Retrace also skips lines or regions where the cursor didn't 
 * remain for very long - according to parameters "retrace cursor min 
 * region pause time intervals" and "retrace cursor min line pause time". 
 *  
 * The main commands provided by xretrace are 
 * 1. xretrace_modified_line    - go to the most recently modified line/region
 * 2. xretrace_cursor           - go to the most recent cursor location/region 
 * 3. xretrace_modified_line_steps  - step through modified regions using an event loop 
 * 4. xretrace_cursor_steps         - step through visited regions using an event loop 
 *  
 * 5. xretrace_show_control_panel - shows the xretrace configuration options dialog 
 * 6. xretrace_reset  - re-initialises xretrace 
 * 7. xretrace_clear_all_markers  - clears all line markers created by xretrace 
 *  
 *  
 * << xretrace timer >> 
 * ====================
 * xretrace uses a timer callback to check where the cursor is and record its 
 * movement.  The timer rate is set by a parameter "retrace timer interrupt 
 * sampling interval" in units of milliseconds.  The faster the rate, the less 
 * chance that xretrace will miss recording a line modification or a visited 
 * line but the higher the overhead on your system. 
 *  
 *  
 *  
 * << color modified lines issue >> 
 * ================================
 * xretrace keeps track of the order that lines/regions have been modified by 
 * clearing the "modified line" line-flag when the cursor first arrives on a 
 * line.  THIS MEANS THAT THE "COLOR MODIFIED LINES" INDICATION OF A MODIFIED 
 * LINE THAT APPEARS AS A DIFFERENT COLOR IN THE MARGIN IS DEFEATED. 
 * i.e. when the cursor first lands on a line, the indication in the margin that 
 * the line has been modified will be cleared (if the line had been modified). 
 * xretrace provides two means of keeping track of lines that have had their 
 * modify status cleared by xretrace  - one uses a line flag and the other uses 
 * a line marker.  These allow the modify status of a line to be restored. 
 * see configuration options 4,5 and 6. 
 *  
 *  
 *  
 * << delayed start >> 
 * ===================
 * When you first start SlickEdit, by default, xretrace doesn't immediately 
 * start running but there is a parameter that allows changing this.  If you use 
 * a retrace command and xretrace isn't already running, you are prompted to 
 * start xretrace - the xretrace timer will then become active.  The reason for 
 * the delayed start is just to avoid the possibility of xretrace causing 
 * problems when SlickEdit starts  - especially useful when the xretrace code is 
 * being developed/modified. 
 *  
 *  
 *  
 * << xretrace source files >> 
 * ===========================
 * The following three files need to be loaded 
 * DLinkList.e
 * xretrace_popup.e
 * xretrace.e 
 *  
 * xretrace.e #imports DLinkList.e and #INCLUDEs xretrace_control_panel.e 
 * and xretrace_control_panel.e #INCLUDEs xretrace_form.e 
 *  
 * The source file xretrace_form.e provides the dialog (xretrace control panel) 
 * that allows xretrace to be configured. 
 *  
 *  
 *  
 * << line markers and bitmaps >> 
 * ==============================
 * xretrace uses SlickEdit line markers to keep track of lines that have been 
 * visited or modified.  Associated with each line marker is a bitmap. The 
 * xretrace control panel lets you select whether the line marker bitmaps are 
 * visible or not.  Once a line is marked with a line marker, the line can be 
 * still be found correctly if it has moved due to other lines being inserted or 
 * deleted.  If you delete a line that has been marked with a line marker, the 
 * line marker is also deleted and lost.  If xretrace finds that a line marker 
 * is invalid, it uses the last known actual line number to go to that line, 
 * which is not as accurate as using the line marker. 
 * xretrace control panel contains several "show line markers" checkboxes.  When 
 * you check or uncheck one of these, the bitmaps associated with the line 
 * markers are swapped to make the line marker visible or invisible. 
 *  
 *  
 *  
 * << event loop popup window >> 
 * =============================
 * When the commands xretrace_cursor_steps and xretrace_modified_line_steps are 
 * used, an event loop executes that allows you to step through the cursor 
 * retrace list or the modified lines list.  A popup window appears that shows 
 * the keys that can be used while the event loop is active.  The popup window 
 * can be hidden using the F5 key. 
 *  
 * ESC         - exits the event loop and restores the cursor to the buffer/line 
 *               that it was at before the command was initiated
 *  
 * ENTER       - exits the event loop and leaves the cursor at the currently 
 *               selected line/buffer.  The UP key does the same thing.
 *  
 * LEFT        - goes to the previous item in the list but skips lines that are 
 *               closer then the "min viewing granularity" 
 * C-LEFT      - goes to the previous item skipping none and wrapping to the start 
 *               of the list
 * A-LEFT      - goes to a previous item in the list that is a different buffer 
 *  
 * RIGHT       - "right" options are same as "left" options but in the opposite
 * C-RIGHT       direction 
 * A-RIGHT 
 *  
 * HOME        - goes to the start of the list 
 * END         - goes to the end of the list 
 * DOWN        - expands or collapses part of the popup window
 *          
 * R-CLICK     - The popup window is positioned where mouse right click is used.
 * INS         - The retrace control panel is shown.
 * F1          - Help - the xretrace.e source file is shown with the cursor on 
 *               this "help" info.
 * F2          - The xretrace.e source file is shown
 * F5          - Hide/ show the popup window
 * F6          - Switch between the cursor retrace list and the modified lines list
 * F7          - 
 * F8          - Switches between "all buffers" or the "same buffer".  When "same 
 *               buffer is selected, only items from the current buffer are shown. 
 * C-F4        - Resets xretrace, empties the retrace lists and clears all line markers
 * A-F4        - Disables xretrace
 * PGDN        - Toggles a bookmark at the current cursor location
 * C-PGDN      - Sets a bookmark at the current cursor location
 *  
 */


#define XRETRACE_KEYS_HELP_LINE 144
#define XRETRACE_SETTINGS_HELP_LINE 174

/*****************************************************************************  
 *  
 * << configuration parameters >> 
 * ==============================
 * 1. retrace cursor max history length 
 *       - max items in the cursor retrace list 
 * 2. retrace modified lines max history length 
 *       - max items in the modified lines retrace list
 * 3. retrace timer sampling interval 
 *       - sets the rate in milliseconds that the retrace timer executes
 * 4. retrace cursor line distance recording granularity 
 *       - the size of a "region" (number of lines) that determines how far the
 *         cursor has to move (number of lines) before a new item is added to the retrace list.
 * 5. retrace cursor line distance viewing granularity 
 *       - when the retrace history is being viewed, an item in the retrace history will be skipped
 *         if it is closer to the current line than the viewing granularity.  The retrace history
 *         recall mechanism allows skipping or no skipping.
 * 6. retrace cursor min region pause time intervals 
 *       - a line number/region will be added to the retrace list only if the cursor has been
 *         within the region for a minimum time.  The length of this time is set by the value
 *         of this parameter multiplied by the "retrace timer sampling interval parameter"
 * 7. retrace cursor min line pause time 
 *       - a line number/region will be added to the retrace list only if the cursor has stayed
 *         on the same line for a minimum length of time.  The length of this time is set by the value
 *         of this parameter multiplied by the "retrace timer sampling interval parameter"
 *  
 *  
 * << configuration options >> 
 * ===========================
 * 1. show retrace modified line markers 
 *       - selects whether the line markers used to track modified lines are indicated
 *         with an icon in the margin (see <<line markers and bitmaps>>)
 * 2. show retrace most recent modified line markers 
 *       - this is an alternative to item 1 where instead of all the line markers that
 *         correspond to modified lines are indicated, only the most recent one is.
 * 3. show retrace cursor line markers 
 *       - selects whether that line markers used to retrace cursor movement are
 *         indicated with an icon in the margin (this is normally off and is mainly
 *         for debugging or curiousity)
 * 4. track de-modified lines with line markers 
 *       - selects whether lines that have had their "modify status" cleared are
 *         tracked with line markers.  If you have "color modified lines" enabled,
 *         xretrace will sometimes destroy the modified line indication but allows
 *         you to see such lines by enabling this option, along with the following
 *         option.  In the retrace cursor event loop, function key F7 can be used
 *         to restore the line modify status using these line markers.
 * 5. show de-modified line markers 
 *       - see the previous option
 * 6. track de-modified lines with lineflags 
 *       - this is an alternative to option 4.  Enabling this option means that lines
 *         that have had their "modify status" cleared by xretrace can be kept track
 *         of using a "SlickEdit lineflag" which is used to restore the "modify status"
 *         of the line at a later time (every time you use an xretrace retrace command)
 *         >>>>>>>>>>>>>   WARNING   <<<<<<<<<<<<<
 *         This uses the VIMARK_LF line flag so VIM users should probably not
 *         enable this option.
 * 7. retrace delayed start 
 *       - if this option is enabled, xretrace won't become automatically enabled
 *         when SlickEdit first starts.  If you use an xretrace retrace command and
 *         xretrace isn't active, you will be prompted to start xretrace.  Normally,
 *         this option should be disabled.  An alternative means of stopping xretrace
 *         from being started automatically is to place a file named DontRunMyMacros.txt
 *         in your configuration folder.
 * 8. track_modified_lines 
 *       - If this option is disabled, xretrace won't track modified lines.
 *         This might be desirable if you have "color modified lines" enabled
 *         and don't want xretrace clearing the modified line flags but still
 *         want to use xretrace_cursor.
 * 9. capture retrace data to disk 
 *       - This is disabled by default.  If enabled, cursor retrace data and local
 *         bookmarks will be captured to disk.  Set XRETRACE_USE_SUBFOLDER and
 *         XRETRACE_DATA_PATH according to where you want the data files to go.
 *  
*/

 

struct xretrace_item
{
   _str buf_name;
   int mid_line;
   int last_line;
   int flags;
   int col;
   int line_marker_id;
   boolean marker_id_valid;
   int window_id;
};
// xretrace_item::flags 
#define RETRACE_MOD_FLAG 1
#define RETRACE_MOD_LIST_FLAG 2
#define MARKER_WAS_ALREADY_HERE_ON_OPENING 4

struct track_demodified_line_item
{
   _str buf_id;
   int line_marker_id;
   int window_id;
};



// DEMODIFY_LF is same flag as VIMARK_LF. The unused "high-bit" line-flags don't work.
#define DEMODIFY_LF VIMARK_LF    // 0x400000

// the timer must not be static
int         retrace_timer_handle;


//*****************************************************************************
// local variables
//*****************************************************************************


// the lists
static dlist      retrace_cursor_list;
static dlist      retrace_modified_lines_list;

static dlist *    ptr_retrace_cursor_list_for_buffer;
static dlist *    ptr_retrace_modified_lines_list_for_buffer;
static dlist *    ptr_bookmark_list_for_buffer;
static dlist      track_demodified_list;


// where the cursor is now
static int retrace_current_buf_id;
static _str retrace_current_buf_name;
static int retrace_current_line;
static int retrace_current_col;

// the current cursor region info
static int retrace_lower_line;
static int retrace_upper_line;
//static int retrace_max_line_range;

// the current modified lines region info
//static int retrace_mod_max_line_range;
static int retrace_mod_upper_line;
static int retrace_mod_lower_line;

// modified lines handling
static boolean retrace_use_line_modify_flag;
static boolean retrace_line_was_modified;
static int retrace_modified_line;
static int retrace_modified_col;

// undo
static boolean retrace_undo_flag;
static int retrace_undo_line_num;

// line marker id
static int retrace_region_line_marker_id;
static int buffer_retrace_region_line_marker_id;
static boolean retrace_region_line_marker_set;
static int retrace_region_line_marker_window_id;

static int modified_region_line_marker_id;
static int buffer_modified_region_line_marker_id;
static int modified_region_line_marker_window_id;
static boolean modified_region_line_marker_set;

// miscellaneous
static boolean xretrace_history_enabled;
static boolean retrace_ignore_current_buffer;
static int retrace_startup_counter;
static int retrace_no_re_entry = 0;
static int retrace_timer_rate;

// line marker info
static int retrace_marker_type_id;
static int retrace_marker_type_id_mod;
static int retrace_marker_type_id_demod;

static int retrace_line_marker_pic_index_inv;
static int retrace_line_marker_pic_index_mod;
static int retrace_line_marker_pic_index_cur;
static int retrace_line_marker_pic_index_demod;

static int retrace_line_marker_pic_index_cur_now;
static int retrace_line_marker_pic_index_mod_now;


static int restore_modify_buf_line;
static int restore_modify_buf_id;
static _str restore_modify_buffer_name;


static boolean retrace_option_land_on_line_clear_modify;
static boolean retrace_option_clear_modify_continually;


static int retrace_cursor_min_region_pause_time_counter;
static int retrace_cursor_min_line_pause_time_counter;
static boolean retrace_cursor_min_line_pause_time_occurred;

static boolean xretrace_not_running;
static boolean goback_is_loaded;

static dlist_iterator fwd_back_iter;
static int xretrace_cursor_fwd_back_state;


#define xcfg xretrace_config_data

static int xretrace_has_been_started_id;
#define XRETRACE_HAS_BEEN_STARTED_ID 12345678

static int number_of_lines_in_buffer;
static int previous_number_of_lines_in_buffer;


// the following hash arrays are all indexed by filename
static dlist    buffer_retrace_modified_lines_list:[]; 
static dlist    buffer_retrace_cursor_list:[]; 
static _str     files_active_since_startup:[];
static dlist    buffer_bookmark_list:[]; 

// update_retrace_line_numbers updates the recorded line number using the line
// marker to get the latest actual line marker
static void update_retrace_line_numbers(dlist & alist)
{
   xretrace_item * ip;
   VSLINEMARKERINFO info1;
   dlist_iterator iter = dlist_begin(alist);
   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      if (ip->marker_id_valid && (_LineMarkerGet(ip->line_marker_id, info1) == 0)) {
         ip->last_line = info1.LineNum;
      }
   }
}


// step through all the line markers in the "de-modified" line marker list
// and restore the modify flag
static void restore_demodified_line_marker_modified_lineflags()
{
   track_demodified_line_item * ip;
   VSLINEMARKERINFO info1;

   if (_no_child_windows()) {
      return;
   }
   int window_id = p_window_id;
   int buf_id = _mdi.p_child.p_buf_id;
   dlist_iterator iter = dlist_begin(track_demodified_list);

   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      // if the line marker still exists then assume the buf_id is valid
      if (_LineMarkerGet(ip->line_marker_id, info1) == 0) {
         _mdi.p_child.p_buf_id = info1.buf_id;
         _mdi.p_child.p_line = info1.LineNum;
         _mdi.p_child._lineflags(MODIFY_LF, MODIFY_LF);
      }
   }
   dlist_reset(track_demodified_list);
   _LineMarkerRemoveAllType(retrace_marker_type_id_demod);
   p_window_id = window_id;
   _mdi.p_child.p_buf_id = buf_id;
}


// used to hide/show the line markers that are tracking modified lines
static void swap_demodified_line_bitmaps(int pic_index, int range = -1)
{
   track_demodified_line_item * ip;
   VSLINEMARKERINFO info1;

   if (_no_child_windows()) {
      return;
   }
   int window_id = p_window_id;
   int buf_id = _mdi.p_child.p_buf_id;
   dlist_iterator iter = dlist_begin(track_demodified_list);

   for( ; dlist_iter_valid(iter) && (range-- != 0); dlist_next(iter)) {
      ip = dlist_getp(iter);
      // if the line marker still exists then assume the buf_id is valid
      if (_LineMarkerGet(ip->line_marker_id, info1) == 0) {
         _mdi.p_child.p_buf_id = info1.buf_id;
         _LineMarkerRemove(ip->line_marker_id);
         ip->line_marker_id = _LineMarkerAdd(ip->window_id, info1.LineNum, 1, 1, 
                                             pic_index, info1.type, info1.msg );
         continue;
      }
   }
   p_window_id = window_id;
   _mdi.p_child.p_buf_id = buf_id;
}


_command void xretrace_show_demodified_line_markers() name_info(',')
{
   swap_demodified_line_bitmaps(retrace_line_marker_pic_index_demod);
}


_command void xretrace_hide_demodified_line_markers() name_info(',')
{
   swap_demodified_line_bitmaps(retrace_line_marker_pic_index_inv);
}


_command void xretrace_clear_all_demodified_line_markers() name_info(',')
{
   _LineMarkerRemoveAllType(retrace_marker_type_id_demod);
}



static void swap_retrace_line_bitmaps(dlist & alist, int pic_index, int range = -1)
{
   xretrace_item * ip;
   VSLINEMARKERINFO info1;

   if (_no_child_windows()) {
      return;
   }
   int window_id = p_window_id;
   int buf_id = _mdi.p_child.p_buf_id;
   dlist_iterator iter = dlist_begin(alist);

   for( ; dlist_iter_valid(iter) && (range-- != 0); dlist_next(iter)) {
      ip = dlist_getp(iter);
      // if the line marker still exists then assume the buf_id is valid
      if (ip->marker_id_valid && (_LineMarkerGet(ip->line_marker_id, info1) == 0)) {
         ip->last_line = info1.LineNum;
         _mdi.p_child.p_buf_id = info1.buf_id;
         _LineMarkerRemove(ip->line_marker_id);
         if (ip->buf_name :== _mdi.p_child.p_buf_name) {
            ip->line_marker_id = _LineMarkerAdd(ip->window_id, ip->last_line, 1, 1, 
                                                pic_index, info1.type, info1.msg );
            continue;
         }
      }
   }
   p_window_id = window_id;
   _mdi.p_child.p_buf_id = buf_id;
}



/*******************************************************************************
 *  add_new_retrace_item
 *  
 *  adds a new entry to the front of the list and removes any duplicate.  The
 *  line marker_id passed in is always saved in the new list entry ensuring that
 *  it is not orphaned.
*******************************************************************************/
static void add_new_retrace_item(dlist & alist, _str bufname, int marker_id, int mid_line, 
                                 int last_line, int col, int flags, int window_id, boolean skip_dup = false)
{
   xretrace_item * ip;
   VSLINEMARKERINFO info1;
   int max_range = ((flags & RETRACE_MOD_LIST_FLAG) ? 
                    (int)xcfg.retrace_cursor_line_distance_recording_granularity : 
                    (int)xcfg.retrace_cursor_line_distance_recording_granularity);
                     // maybe have separate granularity one day

   if (flags & RETRACE_MOD_LIST_FLAG) {
      if (xcfg.show_most_recent_modified_line_markers) {
         // change the bitmap for the last entry added to make it invisible
         swap_retrace_line_bitmaps(alist, retrace_line_marker_pic_index_mod_now, 1);
      }
   }
   // remove duplicates
   dlist_iterator iter = dlist_begin(alist);
   // if skip_dup is true we don't inspect the first item in the list because
   // we want to go there, but we do inspect the second item onwards because
   // we might be alternating between the same two places.  dlist_next can be
   // called with an invalid iterator.
   if (skip_dup) 
      dlist_next(iter);
   alabel:
   for ( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      if (ip->marker_id_valid && 
          (_LineMarkerGet(ip->line_marker_id, info1) == 0)) {
         //say('dup ' :+ info1.LineNum);
         if ((abs(info1.LineNum - last_line) < max_range) &&
             (ip->buf_name :== bufname)  ) {
            _LineMarkerRemove(ip->line_marker_id);
            dlist_erase(iter);
            break alabel;
         }
      }
   }

   xretrace_item item;
   item.buf_name = bufname;
   item.line_marker_id = marker_id;
   item.marker_id_valid = true;
   item.mid_line = mid_line;
   item.last_line = last_line;
   item.col = col;
   item.flags = flags;
   item.window_id = window_id;

   if (!dlist_push_front(alist, item))
   {
      // if the list is full we remove the oldest and clear its line marker.
      dlist_iterator it = dlist_end(alist);
      xretrace_item * mp = dlist_getp(it);
      if (mp->marker_id_valid) {
         _LineMarkerRemove(mp->line_marker_id);
      }
      dlist_pop_back(alist);
      // push_front should never fail here
      if (!dlist_push_front(alist, item))
         _LineMarkerRemove(marker_id);
   }
}


static void check_and_remove_first_entry_in_retrace_cursor_list()
{
   VSLINEMARKERINFO info1;
   xretrace_item * ip;
   dlist_iterator iter = dlist_begin(retrace_cursor_list);
   if (dlist_iter_valid(iter)) {
      ip = dlist_getp(iter);
      if (ip->buf_name != _mdi.p_child.p_buf_name) 
         return;
      if (ip->marker_id_valid && (_LineMarkerGet(ip->line_marker_id, info1) == 0)) {
         if (info1.LineNum == _mdi.p_child.p_line) {
            _LineMarkerRemove(ip->line_marker_id);
            dlist_erase(iter);
         }
      }
   }
}


static void set_retrace_region_line_marker()
{
   if (retrace_region_line_marker_set) {
      _LineMarkerRemove(retrace_region_line_marker_id);
      _LineMarkerRemove(buffer_retrace_region_line_marker_id);
   }
   retrace_region_line_marker_window_id = _mdi.p_child.p_window_id;
   retrace_region_line_marker_id =
      _LineMarkerAdd(retrace_region_line_marker_window_id, retrace_current_line, 1, 1,
                     retrace_line_marker_pic_index_cur_now, retrace_marker_type_id, "xretrace" );
   buffer_retrace_region_line_marker_id =
      _LineMarkerAdd(retrace_region_line_marker_window_id, retrace_current_line, 1, 1,
                     retrace_line_marker_pic_index_cur_now, retrace_marker_type_id, "xretrace" );

   retrace_region_line_marker_set = true;
}


static void update_modified_lines_list()
{
   if (modified_region_line_marker_set) {

      modified_region_line_marker_set = false;

      add_new_retrace_item(
         retrace_modified_lines_list, retrace_current_buf_name, modified_region_line_marker_id,
         retrace_mod_lower_line + ((retrace_mod_upper_line - retrace_mod_lower_line) >> 1),
         retrace_modified_line, retrace_modified_col, RETRACE_MOD_FLAG | RETRACE_MOD_LIST_FLAG, 
         modified_region_line_marker_window_id);

      if ( ptr_retrace_modified_lines_list_for_buffer ) {
         add_new_retrace_item(
            * ptr_retrace_modified_lines_list_for_buffer, retrace_current_buf_name, buffer_modified_region_line_marker_id,
            retrace_mod_lower_line + ((retrace_mod_upper_line - retrace_mod_lower_line) >> 1),
            retrace_modified_line, retrace_modified_col, RETRACE_MOD_FLAG | RETRACE_MOD_LIST_FLAG, 
            modified_region_line_marker_window_id);
      }
      add_markup_to_xbar_for_edwin(_mdi.p_child, *ptr_retrace_cursor_list_for_buffer, 
                                   *ptr_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);
   }
   retrace_undo_flag = false;
}


static void update_retrace_cursor_list(boolean force_update = false)
{
   if (force_update && !retrace_region_line_marker_set) 
      set_retrace_region_line_marker();

   if (retrace_region_line_marker_set && 
       (((retrace_cursor_min_region_pause_time_counter <= 0) && retrace_cursor_min_line_pause_time_occurred) 
          || modified_region_line_marker_set || force_update)) {

      retrace_region_line_marker_set = false;

      add_new_retrace_item(
         retrace_cursor_list, retrace_current_buf_name, retrace_region_line_marker_id,
         retrace_lower_line + ((retrace_upper_line - retrace_lower_line) >> 1),
         retrace_current_line, retrace_current_col, modified_region_line_marker_set ? RETRACE_MOD_FLAG : 0, 
         retrace_region_line_marker_window_id, force_update);

      if ( ptr_retrace_cursor_list_for_buffer ) {
         add_new_retrace_item(
            * ptr_retrace_cursor_list_for_buffer, retrace_current_buf_name, buffer_retrace_region_line_marker_id,
            retrace_lower_line + ((retrace_upper_line - retrace_lower_line) >> 1),
            retrace_current_line, retrace_current_col, modified_region_line_marker_set ? RETRACE_MOD_FLAG : 0, 
            retrace_region_line_marker_window_id, force_update);

         add_markup_to_xbar_for_edwin(_mdi.p_child, *ptr_retrace_cursor_list_for_buffer, 
                                      *ptr_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);

      }


   }



   retrace_cursor_min_region_pause_time_counter = (int)xcfg.retrace_cursor_min_region_pause_time;
   retrace_cursor_min_line_pause_time_counter = (int)xcfg.retrace_cursor_min_line_pause_time;
}


_command undo_via_retrace() name_info(','VSARG2_MARK|VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL|VSARG2_LINEHEX/*|VSARG2_NOEXIT_SCROLL*/)
{
   retrace_undo_flag = true;
   undo();
   if (!_no_child_windows()) 
      retrace_undo_line_num = _mdi.p_child.p_line;
}


static void clear_demodified_lineflags_in_buffer()
{
   if (!xcfg.track_demodified_lines_with_lineflags) 
      return;

   typeless p;
   _save_pos2(p);
   top();
   do
   {
      if (_mdi.p_child._lineflags() & DEMODIFY_LF)
         _mdi.p_child._lineflags(0, DEMODIFY_LF);
   }
   while (!down());
   _restore_pos2(p);
}



static void restore_demodified_lineflags_in_buffer()
{
   if (!xcfg.track_demodified_lines_with_lineflags) 
      return;

   typeless p;
   _save_pos2(p);
   top();
   do
   {
      if (_mdi.p_child._lineflags() & DEMODIFY_LF)
         _mdi.p_child._lineflags(MODIFY_LF, MODIFY_LF | DEMODIFY_LF);
   }
   while (!down());
   _restore_pos2(p);
}


// _cb call-list when a buffer is saved
void _cbsave_xretrace()
{
   restore_demodified_lineflags_in_buffer();
}


static void clear_line_modify_flag_and_track()
{
   if (!xcfg.track_modified_lines) {
      return;
   }
   // clear MODIFY_LF
   _mdi.p_child._lineflags(0, MODIFY_LF);
   if (xcfg.track_demodified_lines_with_lineflags) {
      // set DEMODIFY_LF
      _mdi.p_child._lineflags(DEMODIFY_LF, DEMODIFY_LF);
   }
   if (xcfg.track_demodified_lines_with_line_markers != 0) {
      track_demodified_line_item item;
      int pic = xcfg.show_demodified_line_markers ? 
         retrace_line_marker_pic_index_demod : retrace_line_marker_pic_index_inv;
      item.buf_id = _mdi.p_child.p_buf_id;
      item.window_id = _mdi.p_child.p_window_id;
      item.line_marker_id = 
         _LineMarkerAdd(_mdi.p_child.p_window_id, retrace_current_line, 1, 1, 
                        pic, retrace_marker_type_id_demod, "xretrace track mod" );
      if (!dlist_push_front(track_demodified_list, item))
      {
         _LineMarkerRemove(item.line_marker_id);
      }
   }
}


static void do_modified_line_processing()
{
   if (!xcfg.track_modified_lines) {
      return;
   }
   if (retrace_option_clear_modify_continually) {
      // continually clear the line modify flag as soon as it gets set
      if (retrace_undo_flag) {
         // once undo has been used on a line, the lineflags modify flag is left
         // set, because clearing it results in "fighting" with undo!
         if (retrace_undo_line_num != retrace_current_line)
            retrace_undo_flag = false;
      } else {
         // clear the line modify flag
         _mdi.p_child._lineflags(0, MODIFY_LF);
      }
   }

   if (!modified_region_line_marker_set) {
      // start new "modified" region
      retrace_mod_lower_line = retrace_mod_upper_line = _mdi.p_child.p_line;
   }

   if (!retrace_line_was_modified) {
      retrace_line_was_modified = true;
      if (modified_region_line_marker_set) {
         _LineMarkerRemove(modified_region_line_marker_id);
         _LineMarkerRemove(buffer_modified_region_line_marker_id);
      }
      int mod_pic;
      if (xcfg.show_most_recent_modified_line_markers) 
         mod_pic = retrace_line_marker_pic_index_mod;
      else
         mod_pic = retrace_line_marker_pic_index_mod_now;
      
      modified_region_line_marker_window_id = _mdi.p_child.p_window_id;
      modified_region_line_marker_id = 
         _LineMarkerAdd(modified_region_line_marker_window_id, retrace_current_line,1,1, 
                        mod_pic, retrace_marker_type_id_mod, "retrace mod" );
      buffer_modified_region_line_marker_id = 
         _LineMarkerAdd(modified_region_line_marker_window_id, retrace_current_line,1,1, 
                        mod_pic, retrace_marker_type_id_mod, "retrace mod" );
      modified_region_line_marker_set = true;

   }
   retrace_modified_line = retrace_current_line;
   retrace_modified_col = retrace_current_col;
}



static boolean check_for_new_retrace_mod_region()
{
   int line_now = _mdi.p_child.p_line;

   if (line_now < retrace_mod_lower_line) {
      if ((retrace_mod_upper_line - line_now) > 
             (int)xcfg.retrace_cursor_line_distance_recording_granularity) {
         return true;
      }
      retrace_mod_lower_line = line_now;
   }
   else if (line_now > retrace_mod_upper_line) {
      if ((line_now - retrace_mod_lower_line) > 
                  (int)xcfg.retrace_cursor_line_distance_recording_granularity) {
         return true;
      }
      retrace_mod_upper_line = line_now;
   }
   return false;  
}


static boolean check_buffer_ignore()
{
   _str fn = strip_filename(_mdi.p_child.p_buf_name,'P');
   if (substr(fn,1,4) == 'grep') {
      retrace_ignore_current_buffer = true;
      return true;
   }
   if (substr(fn,1,1) == '.' || (_mdi.p_child.p_buf_flags & HIDE_BUFFER)) {
      retrace_ignore_current_buffer = true;
      return true;
   }
   if (strip_filename(_mdi.p_child.p_buf_name,'NE') == '') {
      retrace_ignore_current_buffer = true;
      return true;
   }
   retrace_ignore_current_buffer = false;
   return false;
}


/****************************************************************************** 
 * check_for_new_retrace_region :
 *  
 * checks whether the range of lines the cursor has traversed through exceeds 
 * the max range.  
 *  
 * retrace_current_line and retrace_current_col are updated ONLY if the cursor 
 * has stayed in the range  - if the cursor has gone outside the range, then we 
 * need to keep the previous values until they have been saved on the retrace 
 * lists. i.e. retrace_current_line and retrace_current_col are updated only if 
 * the return value is false. 
******************************************************************************/
static boolean check_for_new_retrace_region()
{
   int line_now = _mdi.p_child.p_line;

   if (line_now < retrace_lower_line) {
      if ((retrace_upper_line - line_now) > 
            (int)xcfg.retrace_cursor_line_distance_recording_granularity) {
         return true;
      }
      retrace_lower_line = line_now;
   }
   else if (line_now > retrace_upper_line) {
      if ((line_now - retrace_lower_line) > 
             (int)xcfg.retrace_cursor_line_distance_recording_granularity) {
         return true;
      }
      retrace_upper_line = line_now;
   }
 
   retrace_current_line = line_now;
   retrace_current_col = _mdi.p_child.p_col;
   return false;  
}


static boolean check_for_change_in_no_of_lines()
{
   if (previous_number_of_lines_in_buffer > number_of_lines_in_buffer) {
      return true;
   }
   return false;
}
 
 
// TODO do we need to do anything here when a buffer is opened
//  
//  static _str check_name;
//  static int check_buf_id;
//  static boolean found_duplicate;
//  
//  int xretrace_buffer_add_for_each()
//  {
//     if ( p_buf_name == check_name && p_buf_id != check_buf_id ) {
//        found_duplicate = true;
//        return p_buf_id;
//     }
//     return 0;  // keep going
//  }
//   
//  
//  // _buffer_add_xretrace_markers will be called via a call_list when a new buffer is created
//  void _buffer_add_xretrace_markers(int newBuffID, _str name, int flags = 0)
//  {
//     check_name = name;
//     check_buf_id = newBuffID;
//     found_duplicate = false;
//     _mdi.p_child.for_each_buffer( 'xretrace_buffer_add_for_each' );
//     if ( !found_duplicate ) {
//        // the file has just been opened so remove it from the active list
//        // so that line markers are re-generated
//        files_active_since_startup._deleteel(name);       // TODO
//     }
//  }
 

void _cbquit_xretrace(int buffid, _str name, _str docname= "", int flags = 0)
{
   save_retrace_data_for_file(name);
}



void _cbsave_xretrace_data_files()
{
   if ( _no_child_windows() || !xretrace_history_enabled ) 
      return;

   save_retrace_data_for_file(p_buf_name);
}
 

// TODO save the data when buffer is closed or when slick closes.
static void save_retrace_data_for_file(_str fn)
{
   if (!xcfg.capture_retrace_data_to_disk) {
      return;
   }

   int new_wid, orig_wid;
   _str s1;
   xretrace_item * ip;
   typeless * active = files_active_since_startup._indexin(fn);
   if ( !active ) {
      return;
   }

   dlist *    ptr_retrace_cursor_list  = buffer_retrace_cursor_list._indexin(fn);
   dlist *    ptr_retrace_modified_list  = buffer_retrace_modified_lines_list._indexin(fn);
   dlist *    ptr_bookmark_list = buffer_bookmark_list._indexin(fn);

   if ( !ptr_retrace_modified_list || !ptr_retrace_cursor_list || !ptr_bookmark_list ) {
      return;  // no lists, this may be an error TODO
   }

   if ( file_exists(*active)) {
      if (_open_temp_view(_maybe_quote_filename(*active), new_wid, orig_wid) == 0)  {
         top();
         get_line(s1);
         if ( s1 == 'xretrace rev 001' ) {
            if ( down() == 0 ) {
               get_line(s1);
               if ( s1 == fn ) {
                  delete_all();
                  top();
                  insert_line('xretrace rev 001');
                  insert_line(fn);

                  dlist_iterator iter = dlist_begin(*ptr_retrace_cursor_list);
                  for( ; dlist_iter_valid(iter); dlist_next(iter)) {
                     ip = dlist_getp(iter);
                     insert_line( (_str)ip->last_line :+ ' ' :+ (_str)ip->col ); 
                  }

                  insert_line('<modified>');
                  iter = dlist_begin(*ptr_retrace_modified_list);
                  for( ; dlist_iter_valid(iter); dlist_next(iter)) {
                     ip = dlist_getp(iter);
                     insert_line( (_str)ip->last_line :+ ' ' :+ (_str)ip->col ); 
                  }

                  insert_line('<bookmark>');
                  iter = dlist_begin(*ptr_bookmark_list);
                  for( ; dlist_iter_valid(iter); dlist_next(iter)) {
                     ip = dlist_getp(iter);
                     insert_line( (_str)ip->last_line :+ ' ' :+ (_str)ip->col ); 
                  }
                  insert_line('<end>');
                  _save_file(maybe_quote_filename(p_buf_name));
               }
            }
         }
         _delete_temp_view(new_wid);
         activate_window(orig_wid);
      }
   }
}
 
 
static void process_file_k_data_read()
{
   xretrace_item * ip;
   dlist_iterator iter = dlist_begin(*ptr_retrace_cursor_list_for_buffer);
   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      ip->window_id = _mdi.p_child.p_window_id;
      ip->flags = 0;
      ip->line_marker_id = _LineMarkerAdd(ip->window_id, ip->last_line, 1, 1,
                                 retrace_line_marker_pic_index_cur_now, retrace_marker_type_id, "xretrace" );
      ip->marker_id_valid = true;
   }

   iter = dlist_begin(*ptr_retrace_modified_lines_list_for_buffer);
   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      ip->window_id = _mdi.p_child.p_window_id;
      ip->flags = MARKER_WAS_ALREADY_HERE_ON_OPENING;   // show a different icon in the scrollbar
      ip->line_marker_id = _LineMarkerAdd(ip->window_id, ip->last_line, 1, 1,
                                 retrace_line_marker_pic_index_cur_now, retrace_marker_type_id_mod, "xretrace mod" );
      ip->marker_id_valid = true;
   }

   // we add line markers for bookmarks when the buffer is opened so that the
   // bookmark stays on the correct line
   iter = dlist_begin(*ptr_bookmark_list_for_buffer);
   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      ip->window_id = _mdi.p_child.p_window_id;
      ip->flags = 0;   
      ip->line_marker_id = _LineMarkerAdd(ip->window_id, ip->last_line, 1, 1,
                                 retrace_line_marker_pic_index_cur_now, retrace_marker_type_id_mod, "xretrace book" );
      ip->marker_id_valid = true;
   }

}
 
 
static boolean read_file_k_part2()
{
   boolean result = false;
   _str s1, ln, col;
   xretrace_item item;
   item.buf_name = retrace_current_buf_name;
   item.line_marker_id = 0;
   item.marker_id_valid = false;
   item.flags = 0;
   item.window_id = 0;

   top();
   get_line(s1);
   if ( s1 == 'xretrace rev 001' ) {
      if ( down() == 0  ) {
         // the first line is a fully qualified pathname
         get_line(s1);

         #ifdef XRETRACE_USE_SUBFOLDER
         // we check only the name - the path might not match
         if ( strip_filename(s1,'PD')  == strip_filename(retrace_current_buf_name, 'PD') ) 
         #else
         if ( s1 == retrace_current_buf_name ) 
         #endif
         {
            result = true;
            // read "cursor list" data until <modified>
            if ( down() != 0 ) {
               return true;
            }
            get_line(s1);
            while ( s1 != '<modified>' ) {
               parse s1 with ln col;
               item.mid_line = (int)ln;
               item.last_line = (int)ln;
               item.col = (int)col;
               if (!dlist_push_front(*ptr_retrace_cursor_list_for_buffer, item)) {  }
               if ( down() != 0 ) return true;
               get_line(s1);
            }

            // read "modified list" data until <bookmark>
            if ( down() != 0 ) return true;
            get_line(s1);
            while ( s1 != '<bookmark>' ) {
               parse s1 with ln col;
               item.mid_line = (int)ln;
               item.last_line = (int)ln;
               item.col = (int)col;
               if (!dlist_push_front(*ptr_retrace_modified_lines_list_for_buffer, item)) {  }
               if ( down() != 0 ) return true;
               get_line(s1);
            }  // processing modified

            // read "bookmark list" data until <end>
            if ( down() != 0 ) return true;
            get_line(s1);
            while ( s1 != '<end>' ) {
               parse s1 with ln col;
               item.mid_line = (int)ln;
               item.last_line = (int)ln;
               item.col = (int)col;
               if (!dlist_push_front(*ptr_bookmark_list_for_buffer, item)) {  }
               if ( down() != 0 ) return true;
               get_line(s1);
            }  // processing modified



         }
         else {  // error filename not match  TODO
         }
      }
      else {  // file is empty (error) make a new one TODO
      }
   }
   else {  // header record invalid TODO
   }
   return result;
}
 

static void create_new_file_k(_str fn)
{
   int new_wid, orig_wid;
   boolean was;
   if (_open_temp_view(_maybe_quote_filename(fn), new_wid, orig_wid, '', was, true, false, 0, true) == 0)
   {
      insert_line('xretrace rev 001');

      // we insert the full path and name of the file even though this might not match at some point
      // in the future if the project source folders are copied to another location.
      // if XRETRACE_USE_SUBFOLDER is defined then the project source can be copied to a different location
      // and the xretrace marker data gets copied with it and is usable.
      // if XRETRACE_USE_SUBFOLDER is not defined then all xretrace marker data files are stored in
      // one single folder and the marker data files are valid only if the project source files
      // remain in their original location

      insert_line(retrace_current_buf_name);
      files_active_since_startup:[retrace_current_buf_name] = fn;
      _save_file(maybe_quote_filename(p_buf_name));
      _delete_temp_view(new_wid);
      activate_window(orig_wid);
   }
}


static void read_file_k_part1(_str fn)
{
   int new_wid, orig_wid;
   dlist_reset(* ptr_retrace_cursor_list_for_buffer);
   dlist_reset(* ptr_retrace_modified_lines_list_for_buffer);
   dlist_reset(* ptr_bookmark_list_for_buffer);

   if (_open_temp_view(_maybe_quote_filename(fn), new_wid, orig_wid) == 0)
   {
      if ( read_file_k_part2() )
      {
         process_file_k_data_read();
         files_active_since_startup:[retrace_current_buf_name] = fn;
      }
      _delete_temp_view(new_wid);
      activate_window(orig_wid);
   }
   else {
      create_new_file_k(fn);
   }
}
 


// When a new buffer is switched to, this function creates two lists for this buffer if they
// don't already exist and it reads the retrace data from disk.
// retrace_current_buf_name must be assigned to the full name of the current buffer before calling this
//
// NOTE the current _mdi.p_child is used to get the window id to add the line markers to.
//
// This function is called from two places only  - when a new buffer is switched to
// and from retrace_timer_callback1 (startup).
static void buffer_switch_setup_buffer_retrace_lists()
{
   typeless * active = files_active_since_startup._indexin(retrace_current_buf_name);

   ptr_retrace_cursor_list_for_buffer = buffer_retrace_cursor_list._indexin(retrace_current_buf_name);
   if ( !ptr_retrace_cursor_list_for_buffer ) {
      // create a new list for this buffer and add it to the hash array
      dlist temp;
      dlist_construct(temp, (int)xcfg.buffer_retrace_cursor_max_items, false);
      buffer_retrace_cursor_list:[retrace_current_buf_name] = temp;
      ptr_retrace_cursor_list_for_buffer = buffer_retrace_cursor_list._indexin(retrace_current_buf_name);
   }

   ptr_retrace_modified_lines_list_for_buffer = buffer_retrace_modified_lines_list._indexin(retrace_current_buf_name);
   if ( !ptr_retrace_modified_lines_list_for_buffer ) {
      // create a new list for this buffer and add it to the hash array
      dlist temp;
      dlist_construct(temp, (int)xcfg.buffer_retrace_modified_max_items, false);
      buffer_retrace_modified_lines_list:[retrace_current_buf_name] = temp;
      ptr_retrace_modified_lines_list_for_buffer = buffer_retrace_modified_lines_list._indexin(retrace_current_buf_name);
   }

   ptr_bookmark_list_for_buffer = buffer_bookmark_list._indexin(retrace_current_buf_name);
   if ( !ptr_bookmark_list_for_buffer ) {
      // create a new list for this buffer and add it to the hash array
      dlist temp;
      dlist_construct(temp, (int)xcfg.buffer_retrace_bookmarks_max_items, false);
      buffer_bookmark_list:[retrace_current_buf_name] = temp;
      ptr_bookmark_list_for_buffer = buffer_bookmark_list._indexin(retrace_current_buf_name);
   }

   if (!xcfg.capture_retrace_data_to_disk) {
      return;
   }

   if ( !active ) {
      // the file has just been opened so read its retrace data from disk
      // there can be multiple buffers open for the same file but there's only ever one retrace data file for it
      int new_wid, orig_wid;
      boolean was;

      #ifdef XRETRACE_USE_SUBFOLDER
      _str xretrace_data_path = strip_filename(retrace_current_buf_name, 'N') :+ FILESEP :+ 'xretrace_data';
      #else
      _str xretrace_data_path = XRETRACE_DATA_PATH;
      #endif

      _str name1 = strip_filename(retrace_current_buf_name, 'PD');
      _str name2 = xretrace_data_path :+ FILESEP :+ name1 :+ '.xr';
      if ( !file_exists(name2) ) {
         // create and open
         make_path(xretrace_data_path);
         if (_open_temp_view(_maybe_quote_filename(name2), new_wid, orig_wid, '', was, true, false, 0, true) == 0)
         {
            insert_line('xretrace rev 001');
            insert_line('Total 1');
            insert_line(retrace_current_buf_name);
            //say('zz1 ' :+ name2);
            //say('zz2 ' :+ retrace_current_buf_name);
            _save_file(maybe_quote_filename(p_buf_name));
            _delete_temp_view(new_wid);
            activate_window(orig_wid);
            // file "k" might exist even though the master file didn't
            // TODO iterate through all files (if any) and rebuild the index
            read_file_k_part1(name2 :+ '1');
         }
      }
      else {
         if (_open_temp_view(_maybe_quote_filename(name2), new_wid, orig_wid) == 0)
         {
            _str s1, fc;
            top();
            get_line(s1);
            if ( s1 == 'xretrace rev 001' ) {
               if ( down() == 0 ) {
                  get_line(s1);
                  parse s1 with 'Total' fc;
                  int fcount = (int)fc;
                  if ( (fcount + 2) <= p_Noflines && (down() == 0) ) {
                     int k;
                     for ( k = 0; k < fcount; ++k ) {
                        get_line(s1);
                        //say('zz4 ' :+ s1 ' ' :+ s1._length());
                        //say('zz5 ' :+ retrace_current_buf_name :+ ' ' :+ retrace_current_buf_name._length());

                        #ifdef XRETRACE_USE_SUBFOLDER
                        // we check only the name - the path might not match
                        if ( strip_filename(s1,'PD')  == strip_filename(retrace_current_buf_name, 'PD') ) 
                        #else
                        if ( s1 == retrace_current_buf_name ) 
                        #endif
                        {
                           // the data is in file "k + 1"
                           _delete_temp_view(new_wid);
                           activate_window(orig_wid);
                           name2 :+= (_str)(k + 1);
                           read_file_k_part1(name2);
                           return;
                        }
                        else if ( down() != 0 ) {
                           break;
                        }
                     }  // for loop
                     // didn't find a string matching retrace_current_buf_name, add it
                     insert_line(retrace_current_buf_name);
                     top();
                     down();
                     replace_line('Total ' :+ (_str)(fcount + 1));
                     // save this buffer
                     _save_file(maybe_quote_filename(p_buf_name));
                     // the data is in file "k + 1"
                     _delete_temp_view(new_wid);
                     activate_window(orig_wid);
                     name2 :+= (_str)(k + 1);
                     read_file_k_part1(name2);
                     return;
                  }
                  else {
                     // something wrong, not enough lines  TODO
                  }
               }
               else {
                  // something wrong, not enough lines
               }
            }
            else {
               // something wrong, header line is invalid   'xretrace rev 001'
            }
         }  // _open_temp_view
         _delete_temp_view(new_wid);
         activate_window(orig_wid);
      }  // file_exists
   }  // (not active) the retrace data has already been read previously for this file
}
 

/******************************************************************************
 * maintain_cursor_retrace_history() 
 *  
 * This is the heart of the retrace mechanism. 
 *  
 * This function checks if the current line or buffer have changed or if the 
 * line modify flag has changed and updates the retrace lists if necessary.
 * 
 *****************************************************************************/
void maintain_cursor_retrace_history()
{
   if ( _no_child_windows() || !xretrace_history_enabled ) 
      return;

   // update_xbar_forms returns a non zero value if there is an xretrace scrollbar that doesn't have markup yet
   int edwin = update_xbar_forms();
   if ( edwin > 0 ) {
      // edwin.p_buf_name might not be the current active editor window
      dlist * ptr2_retrace_cursor_list_for_buffer = buffer_retrace_cursor_list._indexin(edwin.p_buf_name);
      dlist * ptr2_retrace_modified_lines_list_for_buffer = buffer_retrace_modified_lines_list._indexin(edwin.p_buf_name);
      if ( ptr2_retrace_cursor_list_for_buffer && ptr2_retrace_modified_lines_list_for_buffer ) {
         add_markup_to_xbar_for_edwin(edwin, *ptr2_retrace_cursor_list_for_buffer, 
                                      *ptr2_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);
      }
   }

   // if the focus isn't in the editor window, we're not interested because the cursor isn't
   // being moved by the programmer
   if ( (_get_focus() != _mdi.p_child) ) {
      return;
   }

   --retrace_cursor_min_region_pause_time_counter;
   previous_number_of_lines_in_buffer = number_of_lines_in_buffer;
   number_of_lines_in_buffer = _mdi.p_child.p_Noflines;

   if (xretrace_cursor_fwd_back_state > 0) {
      // last operation was xretrace_cursor_back or xretrace_cursor_fwd so don't
      // update retrace lists unless the cursor has moved off the line
      if (dlist_iter_valid(fwd_back_iter)) {
         VSLINEMARKERINFO info1;
         int xline;
         xretrace_item * ip = (xretrace_item*)dlist_getp(fwd_back_iter);
         if (ip->marker_id_valid && _LineMarkerGet(ip->line_marker_id, info1) == 0)
            xline = info1.LineNum;
         else
            xline = ip->last_line;
   
         if ((_mdi.p_child.p_line == xline) && (_mdi.p_child.p_buf_name == ip->buf_name)) 
            return;
      }
      xretrace_cursor_fwd_back_state = 0;
   }

   if ((_mdi.p_child.p_buf_id != retrace_current_buf_id) || 
       (_mdi.p_child.p_buf_name != retrace_current_buf_name)) {

      // switched buffers.  Were we ignoring the previous buffer?
      if (!retrace_ignore_current_buffer) {
         // save the previous cursor location to the lists and to disk
         update_retrace_cursor_list();  
         update_modified_lines_list();
         // TODO avoid rewriting the retrace data file if it hasn't changed.
         save_retrace_data_for_file(retrace_current_buf_name);
      }

      retrace_current_buf_id = _mdi.p_child.p_buf_id;
      retrace_current_buf_name = _mdi.p_child.p_buf_name;
      previous_number_of_lines_in_buffer = number_of_lines_in_buffer;

      // start new regions
      retrace_mod_lower_line = 
         retrace_mod_upper_line = 
            retrace_current_line =
               retrace_lower_line = 
                  retrace_upper_line = _mdi.p_child.p_line;
      retrace_cursor_min_region_pause_time_counter = (int)xcfg.retrace_cursor_min_region_pause_time;
      retrace_cursor_min_line_pause_time_counter = (int)xcfg.retrace_cursor_min_line_pause_time;
      retrace_cursor_min_line_pause_time_occurred = false;

      retrace_current_col = _mdi.p_child.p_col;
      retrace_line_was_modified = false;
      if (check_buffer_ignore())  
         return;

      set_retrace_region_line_marker();
      // clear the line modify flag when we first land on the line
      if (retrace_option_land_on_line_clear_modify && (_mdi.p_child._lineflags() & MODIFY_LF))
         clear_line_modify_flag_and_track();

      buffer_switch_setup_buffer_retrace_lists();
      //say("yyy2 " :+ _mdi.p_child.p_buf_name);
      add_markup_to_xbar_for_edwin(_mdi.p_child, *ptr_retrace_cursor_list_for_buffer, 
                                   *ptr_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);
      return;
   } 
   else {
      // same buffer.  Are we ignoring it?
      if (retrace_ignore_current_buffer) {
         if (check_buffer_ignore()) 
            return;
      }
      if (retrace_current_line != _mdi.p_child.p_line) {
         retrace_line_was_modified = false;
         retrace_cursor_min_line_pause_time_counter = (int)xcfg.retrace_cursor_min_line_pause_time;
         if (check_for_new_retrace_region()) {
            update_retrace_cursor_list();  
            retrace_lower_line = retrace_upper_line = _mdi.p_child.p_line;
         }
         if (modified_region_line_marker_set && check_for_new_retrace_mod_region()) {
            update_modified_lines_list();
            retrace_mod_lower_line = retrace_mod_upper_line = _mdi.p_child.p_line;
         }
         retrace_current_line = _mdi.p_child.p_line;
         retrace_current_col = _mdi.p_child.p_col;
         set_retrace_region_line_marker();
         // clear the line modify flag when we first land on the line
         if (retrace_option_land_on_line_clear_modify && (_mdi.p_child._lineflags() & MODIFY_LF))
            clear_line_modify_flag_and_track();
         if (check_for_change_in_no_of_lines())
            do_modified_line_processing();
         return;
      }
   }
   // on the same line as last time
   retrace_current_col = _mdi.p_child.p_col;
   if (--retrace_cursor_min_line_pause_time_counter < 0)
      retrace_cursor_min_line_pause_time_occurred = true;

   if ((_mdi.p_child._lineflags() & MODIFY_LF) || check_for_change_in_no_of_lines())
      do_modified_line_processing();
}


// re-entry protection isn't currently needed.
static void retrace_timer_callback2()
{
   if (!_use_timers || retrace_timer_handle < 0) 
      return;
   if (retrace_no_re_entry > 0) {
      return;
   }
   ++retrace_no_re_entry;
   if (retrace_no_re_entry == 1) {
      maintain_cursor_retrace_history();
   }
   --retrace_no_re_entry;
}

_command void xretrace_reset();

_command void xretrace_disable() name_info(',')
{
   xretrace_kill_timer();
   restore_demodified_lineflags_in_buffer();
   xretrace_clear_all_markers();
   xretrace_not_running = true;
}


static void retrace_steps_event_loop2(boolean list_selector, int popup_wid, boolean one_shot = false, dlist_iterator xiter = null, boolean step_buffers = false)
{
   int lpos, xline;
   dlist_iterator iter, save_iter;
   int startline = _mdi.p_child.p_line;
   int startcol = _mdi.p_child.p_col;
   int start_buf_id = _mdi.p_child.p_buf_id;
   _str msg, same_buffer_name;
   VSLINEMARKERINFO info1;
   dlist * list_ptr ;
   static boolean show_all_recorded;
   boolean want_same_buffer = false;
   boolean wrapped_once;
   static boolean hide_popup;
   boolean first_time = true;
   static boolean popup_show_more_or_less;  // true = less

   if (list_selector) 
      list_ptr = &retrace_cursor_list;
   else
      list_ptr = &retrace_modified_lines_list;

   update_retrace_line_numbers(retrace_cursor_list);
   update_retrace_line_numbers(retrace_modified_lines_list);
   same_buffer_name = _mdi.p_child.p_buf_name;

   if (dlist_is_empty(*list_ptr)) 
   {
      message('List is empty.');
      return;
   }
   if (xiter != null && dlist_iter_valid(xiter)) {
      iter = xiter;
   }
   else
   {
      iter = dlist_begin(*list_ptr);
      if (list_selector && !step_buffers) 
      {
         // retrace cursor list, go to the second item in the list because the
         // first item is where we are now - the one we just pushed.
         if (!dlist_next(iter)) {
            message('List is empty.');
            return;
         }
      }
   }

   if (step_buffers) {
      xretrace_item * ip2;
      if (dlist_next(iter)) {
         while(1) {
            ip2 = (xretrace_item*)dlist_getp(iter);
            if (ip2->buf_name != same_buffer_name) 
               break;
            if (!dlist_next(iter)) {
               iter = dlist_begin(*list_ptr);
               break;
            }
         } 
      }
      else
         iter = dlist_begin(*list_ptr);
      ip2 = (xretrace_item*)dlist_getp(iter);
      same_buffer_name = ip2->buf_name;
   }

   while (true) {
      lpos = dlist_get_distance(iter, true);
      xretrace_item * ip = (xretrace_item*)dlist_getp(iter);
      if (ip->marker_id_valid && _LineMarkerGet(ip->line_marker_id, info1) == 0)
         xline = info1.LineNum;
      else
         xline = ip->last_line;

      if (first_time && !list_selector) {
         // modified lines list.  If the current line is the first item in the list
         // then go to the second item in the list
         first_time = false;
         if ((_mdi.p_child.p_line == xline) && (_mdi.p_child.p_buf_name == ip->buf_name)) {
            if (dlist_next(iter)) {
               continue;
            }
            iter = dlist_begin(*list_ptr);
         }
      }
      first_time = false;

      if (edit(maybe_quote_filename(ip->buf_name)) != 0)
         return;

      if (xcfg.track_demodified_lines_with_lineflags)
         restore_demodified_lineflags_in_buffer();

      _mdi.p_child.p_col = ip->col;
      _mdi.p_child.p_line = xline;
      center_line(); 

      if (list_selector) 
         msg = 'Retrace cursor : ';
      else 
         msg = 'Retrace modified : ';

      retrace_current_buf_id = _mdi.p_child.p_buf_id;
      retrace_current_buf_name = _mdi.p_child.p_buf_name;
      buffer_switch_setup_buffer_retrace_lists();
      //say("yyy2 " :+ _mdi.p_child.p_buf_name);
      add_markup_to_xbar_for_edwin(_mdi.p_child, *ptr_retrace_cursor_list_for_buffer, 
                                   *ptr_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);

      if (one_shot) {
         message(msg :+ lpos :+ '/' :+ dlist_size(*list_ptr) :+ ' : ' :+ strip_filename(_mdi.p_child.p_buf_name,'DP'));
         return;
      }

      if (hide_popup) 
         xretrace_hide_popup_window();
      else
         xretrace_popup_update_text(popup_wid, want_same_buffer, popup_show_more_or_less);

      message(msg :+ lpos :+ '/' :+ dlist_size(*list_ptr) :+ ' : ' :+ strip_filename(_mdi.p_child.p_buf_name,'DP'));

      // make numpad keys work properly
      int orig_auto_map_pad_keys=_default_option(VSOPTION_AUTO_MAP_PAD_KEYS);
      _default_option(VSOPTION_AUTO_MAP_PAD_KEYS,0);
      double startTime = (double)_time('B');
      _str key = get_event('N');   // refresh screen and get a key
      _str keyt = event2name(key);
      _default_option(VSOPTION_AUTO_MAP_PAD_KEYS,orig_auto_map_pad_keys);
      switch (keyt) {
         case 'HOME' :
            // go back to the beginning
            iter = dlist_begin(*list_ptr);
            continue;

         case 'END' :
            // go to the end
            iter = dlist_end(*list_ptr);
            continue;

         case 'PAD-STAR' :
         case '\' :
            popup_show_more_or_less = !popup_show_more_or_less;
            continue;

         case 'RBUTTON-DOWN' :
            if (hide_popup) 
            {   
               hide_popup = !hide_popup;
               xretrace_show_popup_window();
            }
            else {
               int x,y;
               mou_get_xy(x,y);
               set_popup_window_pos(x,y);
            }
            continue;

         case 'F5' :
            hide_popup = !hide_popup;
            if (!hide_popup) 
               xretrace_show_popup_window();
            break;
         case 'F6' :
            // switch lists
            dlist * lptr;
            if (!list_selector) 
               lptr = &retrace_cursor_list;
            else
               lptr = &retrace_modified_lines_list;
            if (dlist_is_empty(*lptr))
               break;
            list_selector = !list_selector;
            list_ptr = lptr; 
            iter = dlist_begin(*list_ptr);
            continue;
         case 'F7' :
            restore_demodified_line_marker_modified_lineflags();
            break;
         case 'A-PAD-MINUS' :
         case 'F8' :
            // toggle the "stay on the same buffer" setting
            want_same_buffer = !want_same_buffer;
            same_buffer_name = _mdi.p_child.p_buf_name;
            break;

         case 'C-PAD-MINUS' :
         case 'A-LEFT' :
            // skip to first entry for next buffer
            same_buffer_name = _mdi.p_child.p_buf_name;
            if (dlist_next(iter)) {
               while(1) {
                  ip = (xretrace_item*)dlist_getp(iter);
                  if (ip->buf_name != same_buffer_name) 
                     break;
                  if (!dlist_next(iter)) {
                     iter = dlist_begin(*list_ptr);
                     break;
                  }
               } 
            }
            else
               iter = dlist_begin(*list_ptr);
            ip = (xretrace_item*)dlist_getp(iter);
            same_buffer_name = ip->buf_name;
            break;

         case 'C-PAD-PLUS' :
         case 'A-RIGHT' :
            // skip to prev entry for next buffer
            same_buffer_name = _mdi.p_child.p_buf_name;
            if (dlist_prev(iter)) {
               while(1) {
                  ip = (xretrace_item*)dlist_getp(iter);
                  if (ip->buf_name != same_buffer_name) 
                     break;
                  if (!dlist_prev(iter)) {
                     iter = dlist_end(*list_ptr);
                     break;
                  }
               } 
            }
            else
               iter = dlist_end(*list_ptr);
            ip = (xretrace_item*)dlist_getp(iter);
            same_buffer_name = ip->buf_name;
            break;

         case 'PAD-MINUS' :
         case 'C-LEFT' :
         case 'LEFT' :
         case ' ' :
            // step to "next" item
            show_all_recorded = (keyt == 'C-LEFT');
            save_iter = iter;
            wrapped_once = false;
            if (dlist_next(iter)) {
               while(!show_all_recorded || want_same_buffer) {
                  ip = (xretrace_item*)dlist_getp(iter);
                  if (want_same_buffer) {
                     if (ip->buf_name != same_buffer_name) 
                     {
                        if (!dlist_next(iter)) {
                           if (!wrapped_once && (keyt :== 'C-LEFT')) {
                              wrapped_once = true;
                              iter = dlist_begin(*list_ptr);
                              continue;
                           }
                           iter = save_iter;
                           break;
                        }
                        continue;
                     }
                     if (show_all_recorded) {
                        // it's the same buffer and we want to see all lines, so break
                        break;
                     }
                     // it's the same buffer but we want to check granularity
                  }
                  else
                  {
                     // if it's a new buffer we don't need to check viewing granularity
                     if (ip->buf_name != _mdi.p_child.p_buf_name) 
                        break;
                  }
                  // check the viewing granularity to see if we need to skip this line
                  if (ip->marker_id_valid && _LineMarkerGet(ip->line_marker_id, info1) == 0)
                     xline = info1.LineNum;
                  else
                     xline = ip->last_line;
                  if (abs(xline - _mdi.p_child.p_line) >= (int)xcfg.retrace_cursor_line_distance_viewing_granularity) 
                     break;
                  if (!dlist_next(iter)) {
                     iter = dlist_end(*list_ptr);
                     break;
                  }
               } 
               break;
            }
            else
            {
               if (keyt :== 'C-LEFT' || want_same_buffer) {
                  iter = dlist_begin(*list_ptr);
                  break;
               }
               // for other keys, don't wrap
            }
            message('End of retrace history.');
            iter = dlist_end(*list_ptr);
            break;

         case 'PAD-PLUS' :
         case 'C-RIGHT' :
         case 'RIGHT' :
         case 'C- ' :
            // step to "prev" item
            show_all_recorded = (keyt == 'C-RIGHT');
            save_iter = iter;
            wrapped_once = false;
            if (dlist_prev(iter)) {
               while(!show_all_recorded || want_same_buffer) {
                  ip = (xretrace_item*)dlist_getp(iter);
                  if (want_same_buffer) {
                     if (ip->buf_name != same_buffer_name) 
                     {
                        if (!dlist_prev(iter)) {
                           if (!wrapped_once && (keyt :== 'C-RIGHT')) {
                              wrapped_once = true;
                              iter = dlist_end(*list_ptr);
                              continue;
                           }
                           iter = save_iter;
                           break;
                        }
                        continue;
                     }
                     if (show_all_recorded) {
                        // it's the same buffer and we want to see all lines, so break
                        break;
                     }
                     // it's the same buffer but we want to check granularity
                  }
                  else
                  {
                     // if it's a new buffer we don't need to check viewing granularity
                     if (ip->buf_name != _mdi.p_child.p_buf_name) 
                        break;
                  }
                  if (ip->marker_id_valid && _LineMarkerGet(ip->line_marker_id, info1) == 0)
                     xline = info1.LineNum;
                  else
                     xline = ip->last_line;
                  if (abs(xline - _mdi.p_child.p_line) >= (int)xcfg.retrace_cursor_line_distance_viewing_granularity) 
                     break;
                  if (!dlist_prev(iter)) {
                     iter = dlist_begin(*list_ptr);
                     break;
                  }
               } 
               break;
            }
            else
            {
               if (keyt :== 'C-RIGHT' || want_same_buffer) {
                  iter = dlist_end(*list_ptr);
                  break;
               }
               // for other keys, don't wrap
            }
            message('Start of retrace history.');
            iter = dlist_begin(*list_ptr);
            break;
         case 'ESC' :
            double curTime = (double)_time('B');
            if ( (curTime - startTime) < 500)
            {
               // 'ESC' seems to be registering as some keypresses when first starting
               // this event loop as well as after any key is hit. Filter out any occurring in a
               // short time from the beginning as well as after any key is pressed.
               // See: https://community.slickedit.com/index.php/topic,16598.msg67541.html#msg67541
               //      https://community.slickedit.com/index.php/topic,16598.msg71577.html#msg71577
               continue;
            }
            //dsay("Event loop ESC return");
            // exit back where we started
            edit('+Q +BI ' :+ start_buf_id);
            message('');  // clear
            _mdi.p_child.p_line = startline;
            _mdi.p_child.p_col = startcol;
            center_line();
            return;
         case 'INS' :
            // show xretrace options dialog
            xretrace_show_control_panel();
            return;
         case 'F9' :
            show_all_recorded = !show_all_recorded;
            break;
         case 'C-PGDN' :
            set_bookmark(get_bookmark_name());
            break;
         case 'PGDN' :
            toggle_bookmark();
            break;
         case 'DOWN' :
         case 'UP' :
         case 'C-S- ' :
         case 'ENTER' :
            // exit where we are
            message('End retrace at   ' :+ _mdi.p_child.p_buf_name);
            return;

         case 'F1' :
         case 'F2' :
            // show help
            // fp('-n xretrace_cursor_step_thru_history');  // doesn't work
            xretrace_hide_popup_window();
            edit(maybe_quote_filename(XRETRACE_MODULE_NAME));
            if (keyt == 'F1') {
               goto_line(XRETRACE_KEYS_HELP_LINE);
            }
            return;
         case 'C-F4' :
            if (_message_box('Reset xretrace lists & clear markers?', "xretrace", MB_YESNO) == IDYES)
            {
               xretrace_reset();
               return;
            }
            break;
         case 'A-F4' :
            if (_message_box('Disable xretrace', "xretrace", MB_YESNO) == IDYES)
            {
               xretrace_disable();
               return;
            }
            break;
      }
   }
}




static void retrace_steps_event_loop(boolean list_selector, int popup_wid, boolean one_shot = false, boolean step_buffers = false)
{
   retrace_steps_event_loop2(list_selector, popup_wid, one_shot, null, step_buffers);
   // if we exit at the first item in the list, it gets removed here so that
   // the first item in the list is where we want to go next
   check_and_remove_first_entry_in_retrace_cursor_list();
}




static boolean check_xretrace_is_running()
{
   if (xretrace_not_running) {
      if (_message_box('xretrace is not running.'\r'Start xretrace now?', "xretrace", MB_YESNO) == IDYES) {
         xretrace_not_running = false;
         init_xretrace();
         message('xretrace is running.');
         return false;
      };
      return false;
   }
   return true;
}


/**
 * xretrace_cursor_steps runs an event loop to retrace where the cursor has
 * been.  A popup window shows relevant keys.  F5 hides/shows the popup.
 *
 * @see xretrace_modified_line_steps 
 * @see xretrace_modified_line 
 * @see xretrace_cursor 
 * @see xretrace_cursor_back 
 * @see xretrace_cursor_fwd 
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_cursor_steps() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   if (!check_xretrace_is_running()) 
      return;
   if (goback_is_loaded)
      goback_set_buffer_history_pending_mode();
   update_retrace_cursor_list(true);
   xretrace_history_enabled = false;
   int wid = xretrace_show_popup_window();
   retrace_steps_event_loop(true, wid);
   clear_message();
   xretrace_hide_popup_window();
   xretrace_history_enabled = true;
   if (goback_is_loaded)
      goback_process_pending_buffer_history();
}


/**
 * xretrace_modified_line_steps runs an event loop to retrace modified lines.  A
 * popup window shows relevant keys.  F5 hides/shows the popup.
 *
 * @see xretrace_cursor_steps 
 * @see xretrace_modified_line 
 * @see xretrace_cursor 
 * @see xretrace_cursor_back 
 * @see xretrace_cursor_fwd 
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_modified_line_steps() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   if (!check_xretrace_is_running()) 
      return;
   if (goback_is_loaded)
      goback_set_buffer_history_pending_mode();
   update_modified_lines_list();
   update_retrace_cursor_list(true);
   xretrace_history_enabled = false;
   int wid = xretrace_show_popup_window();
   retrace_steps_event_loop(false, wid);
   clear_message();
   xretrace_hide_popup_window();
   xretrace_history_enabled = true;
   if (goback_is_loaded)
      goback_process_pending_buffer_history();
}


/**
 * xretrace_modified_line goes to the most recent modified line. 
 *  
 * @see xretrace_modified_line_steps 
 * @see xretrace_cursor_steps 
 * @see xretrace_cursor 
 * @see xretrace_cursor_back 
 * @see xretrace_cursor_fwd 
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_modified_line() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   if (!check_xretrace_is_running()) 
      return;
   // always force where we are now onto the retrace list so we can go back to
   // exactly where we were each time this command is used
   update_retrace_cursor_list(true);
   retrace_steps_event_loop(false, -1, true);
}


/**
 * xretrace_cursor goes to the previous cursor location as recorded by xretrace.
 *
 * @see xretrace_modified_line_steps 
 * @see xretrace_cursor_steps 
 * @see xretrace_modified_line 
 * @see xretrace_cursor_back 
 * @see xretrace_cursor_fwd 
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_cursor() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   deselect();
   if (!check_xretrace_is_running()) 
      return;
   if (dlist_is_empty(retrace_cursor_list)) {
      message('xretrace list is empty');
      xretrace_cursor_fwd_back_state = 0;
      return;
   }
   if (xretrace_cursor_fwd_back_state > 0) {
      //fwd_back_iter = dlist_begin(retrace_cursor_list);
      //retrace_steps_event_loop2(true, -1, true, fwd_back_iter);
      //check_and_remove_first_entry_in_retrace_cursor_list();
      //xretrace_cursor_fwd_back_state = 0; 
      
      xretrace_cursor_fwd(); 
      return;
   }
   // always force where we are now onto the retrace list so we can go back to
   // exactly where we were each time this command is used
   update_retrace_cursor_list(true);
   retrace_steps_event_loop(true, -1, true);
}


/**
 * xretrace_cursor_back goes to the next location in the retrace list, if any. 
 * If the cursor is moved off the line, then the position in the
 * foward/back list is forgotton and the next use of xretrace_cursor_back will 
 * start at the beginning of the list again. 
 *
 * @see xretrace_modified_line_steps 
 * @see xretrace_modified_line 
 * @see xretrace_cursor_steps 
 * @see xretrace_cursor 
 * @see xretrace_cursor_fwd 
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_cursor_back() name_info(',')
{
   if (!check_xretrace_is_running()) 
      return;
   if (dlist_is_empty(retrace_cursor_list)) {
      message('xretrace list is empty');
      xretrace_cursor_fwd_back_state = 0;
      return;
   }
   deselect();
   if (xretrace_cursor_fwd_back_state <= 0) {
      // force where we are now onto the retrace list
      update_retrace_cursor_list(true);
      xretrace_cursor_fwd_back_state = 1;
      fwd_back_iter = dlist_begin(retrace_cursor_list);
   }
   dlist_iterator xiter = fwd_back_iter;
   if (!dlist_next(xiter)) {
      return;
   }
   fwd_back_iter = xiter;
   retrace_steps_event_loop2(true, -1, true, xiter);
   return;
}


/**
 * xretrace_cursor_fwd goes to the previous location in the retrace list, if 
 * any. If the cursor is moved off the line, then the position in the 
 * foward/back list is forgotton and the next use of xretrace_cursor_fwd will 
 * do nothing until xretrace_cursor_back has been used.
 *
 * @see xretrace_modified_line_steps 
 * @see xretrace_modified_line 
 * @see xretrace_cursor_steps 
 * @see xretrace_cursor 
 * @see xretrace_cursor_back
 * @see xretrace_show_control_panel 
 **/
_command void xretrace_cursor_fwd() name_info(',')
{
   if (!check_xretrace_is_running()) 
      return;
   if (dlist_is_empty(retrace_cursor_list)) {
      xretrace_cursor_fwd_back_state = 0;
      return;
   }
   if (xretrace_cursor_fwd_back_state > 0) {
      if (!dlist_prev(fwd_back_iter)) {
         xretrace_cursor_fwd_back_state = 0;
         return;
      }
      retrace_steps_event_loop2(true, -1, true, fwd_back_iter);
      if (dlist_iterator_at_start(fwd_back_iter)) {
         check_and_remove_first_entry_in_retrace_cursor_list();
         xretrace_cursor_fwd_back_state = 0;
         return;
      }
   }
}


_command void xretrace_cursor_prev_buffer() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   deselect();
   if (!check_xretrace_is_running()) 
      return;
   if (dlist_is_empty(retrace_cursor_list)) {
      message('xretrace list is empty');
      xretrace_cursor_fwd_back_state = 0;
      return;
   }
   // always force where we are now onto the retrace list so we can go back to
   // exactly where we were each time this command is used
   update_retrace_cursor_list(true);
   retrace_steps_event_loop(true, -1, true, true);
}


_command void xretrace_cursor_prev_buffer_all() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   deselect();
   if (!check_xretrace_is_running()) 
      return;
   if (dlist_is_empty(retrace_cursor_list)) {
      message('xretrace list is empty');
      xretrace_cursor_fwd_back_state = 0;
      return;
   }
   // always force where we are now onto the retrace list so we can go back to
   // exactly where we were each time this command is used
   update_retrace_cursor_list(true);
   int wid = xretrace_show_popup_window();
   retrace_steps_event_loop(true, wid, false, true);
   xretrace_hide_popup_window();
}


static int next_buffer_marked_line(dlist * list_ptr)
{
   int next_line = p_Noflines + 1;
   int first_line = p_Noflines + 1;
   xretrace_item * ip;
   VSLINEMARKERINFO info1;
   dlist_iterator iter = dlist_begin(*list_ptr);
   for( ; dlist_iter_valid(iter); dlist_next(iter)) {
      ip = dlist_getp(iter);
      if (ip->marker_id_valid && (_LineMarkerGet(ip->line_marker_id, info1) == 0)) {
         ip->last_line = info1.LineNum;
      }
      if ( ip->last_line > 0 ) {
         if ( ip->last_line < first_line ) {
            first_line = ip->last_line;
         }
         if ( ip->last_line > p_line && ip->last_line < next_line) {
            next_line = ip->last_line;
         }
      }
   }
   if ( next_line < p_Noflines ) {
      p_line = next_line;
   }
   else if ( first_line < p_Noflines ) {
      p_line = first_line;
   }
   else
   {
      return 1;
   }
   center_line();
   return 0;  // success
}



_command void next_buffer_visited_line() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   next_buffer_marked_line(ptr_retrace_cursor_list_for_buffer);

}

_command void next_buffer_modified_line() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   if (next_buffer_marked_line(ptr_retrace_modified_lines_list_for_buffer) != 0)
      next_buffer_visited_line();
}

_command void next_buffer_bookmark() name_info(','VSARG2_READ_ONLY|VSARG2_REQUIRES_EDITORCTL)
{
   if (next_buffer_marked_line(ptr_bookmark_list_for_buffer) != 0)
      next_buffer_modified_line();
}


static void retrace_timer_callback1()
{
   if (!_use_timers || retrace_timer_handle < 0) 
      return;

   if (_no_child_windows() || !xretrace_history_enabled) {
      retrace_startup_counter = 0;
      return;
   }
   else if (retrace_current_buf_id != _mdi.p_child.p_buf_id ||
            retrace_current_buf_name != _mdi.p_child.p_buf_name)
   {
      retrace_current_buf_id = _mdi.p_child.p_buf_id;
      retrace_current_buf_name = _mdi.p_child.p_buf_name;
      if (++retrace_startup_counter < 20) 
         return;
   }
   retrace_lower_line = retrace_upper_line = retrace_current_line = _mdi.p_child.p_line;
   retrace_current_col = _mdi.p_child.p_col;
   set_retrace_region_line_marker();
   check_buffer_ignore();
   _kill_timer(retrace_timer_handle);
   retrace_timer_handle = _set_timer(retrace_timer_rate, retrace_timer_callback2);
   buffer_switch_setup_buffer_retrace_lists();
   add_markup_to_xbar_for_edwin(_mdi.p_child, *ptr_retrace_cursor_list_for_buffer, 
                                *ptr_retrace_modified_lines_list_for_buffer, *ptr_bookmark_list_for_buffer);
}


int my_find_or_add_picture(_str filename)
{
   typeless temp_config_modify;
   temp_config_modify = _config_modify;
   index := find_index(filename, PICTURE_TYPE);
   if (!index) {
      index = _update_picture(-1, filename);
      if (temp_config_modify == 0) {
         _config_modify = 0;
      }
   }
   return index;
}



void init_xretrace()
{
   xretrace_load_config();

   // overwrite is disallowed with the retrace lists because they hold a line
   // marker id that has to be released
   dlist_construct(retrace_modified_lines_list, (int)xcfg.retrace_modified_lines_max_history_length, false);
   dlist_construct(retrace_cursor_list, (int)xcfg.retrace_cursor_max_history_length, false);

   dlist_construct(track_demodified_list, 100, false);

   xretrace_history_enabled = true;
   xretrace_cursor_fwd_back_state = 0;

   //retrace_max_line_range = (int)xcfg.retrace_cursor_line_distance_recording_granularity;
   //retrace_mod_max_line_range = 4;

   retrace_line_was_modified = false;
   retrace_use_line_modify_flag = true;
   retrace_undo_flag = false;
   retrace_ignore_current_buffer = false;
 
   retrace_region_line_marker_set = false;
   modified_region_line_marker_set = false;

   retrace_startup_counter = 0;
   retrace_no_re_entry = 0;
   retrace_current_buf_id = -1;
   retrace_current_buf_name = '';
   retrace_lower_line = retrace_upper_line = -1;
   retrace_current_line = retrace_current_col = -1;

   retrace_marker_type_id = _MarkerTypeAlloc();
   retrace_marker_type_id_mod = _MarkerTypeAlloc();
   retrace_marker_type_id_demod = _MarkerTypeAlloc();

   _MarkerTypeSetPriority(retrace_marker_type_id_demod, 242);
   _MarkerTypeSetPriority(retrace_marker_type_id, 241);
   _MarkerTypeSetPriority(retrace_marker_type_id_mod, 240);

   xretrace_has_been_started_id = XRETRACE_HAS_BEEN_STARTED_ID;

   retrace_option_clear_modify_continually = false;
   retrace_option_land_on_line_clear_modify = true;

   retrace_cursor_min_region_pause_time_counter = 1;
   previous_number_of_lines_in_buffer = number_of_lines_in_buffer = 0;

   // doesn't work ??
   //if (find_index('goback_process_pending_buffer_history', PROC_TYPE)) {
   //   goback_is_loaded = true;
   //}


   retrace_timer_rate = (int)xcfg.retrace_timer_interrupt_sampling_interval;
   if (retrace_timer_rate < 100 || retrace_timer_rate > 2000) 
      retrace_timer_rate = 500;
   retrace_timer_handle = _set_timer(retrace_timer_rate, retrace_timer_callback1);
   xretrace_not_running = false;

   retrace_line_marker_pic_index_cur = _find_or_add_picture(XRETRACE_BITMAPS_PATH :+ '_xretrcur.png@native'); 
   retrace_line_marker_pic_index_mod = _find_or_add_picture(XRETRACE_BITMAPS_PATH :+ '_xretrmod.png@native'); 
   retrace_line_marker_pic_index_demod = _find_or_add_picture(XRETRACE_BITMAPS_PATH :+ '_xretrdemod.png@native'); 
   //retrace_line_marker_pic_index_inv = _find_or_add_picture(XRETRACE_BITMAPS_PATH :+ '_xretrinv.png'); 
   retrace_line_marker_pic_index_inv = 0;

   if (xcfg.show_retrace_cursor_line_markers) 
      retrace_line_marker_pic_index_cur_now = retrace_line_marker_pic_index_cur;
   else
      retrace_line_marker_pic_index_cur_now = retrace_line_marker_pic_index_inv;

   if (xcfg.show_retrace_modified_line_markers) 
      retrace_line_marker_pic_index_mod_now = retrace_line_marker_pic_index_mod;
   else
      retrace_line_marker_pic_index_mod_now = retrace_line_marker_pic_index_inv;

}


_command void xretrace_hide_mod_bitmaps() name_info(',')
{
   update_modified_lines_list();
   swap_retrace_line_bitmaps(retrace_modified_lines_list, retrace_line_marker_pic_index_inv);
   retrace_line_marker_pic_index_mod_now = retrace_line_marker_pic_index_inv;
}


_command void xretrace_show_mod_bitmaps() name_info(',')
{
   update_modified_lines_list();
   swap_retrace_line_bitmaps(retrace_modified_lines_list, retrace_line_marker_pic_index_mod);
   retrace_line_marker_pic_index_mod_now = retrace_line_marker_pic_index_mod;
}
 

 
_command void xretrace_hide_cur_bitmaps() name_info(',')
{
   update_retrace_cursor_list(true);
   swap_retrace_line_bitmaps(retrace_cursor_list, retrace_line_marker_pic_index_inv);
   retrace_line_marker_pic_index_cur_now = retrace_line_marker_pic_index_inv;
}


_command void xretrace_show_cur_bitmaps() name_info(',')
{
   update_retrace_cursor_list(true);
   swap_retrace_line_bitmaps(retrace_cursor_list, retrace_line_marker_pic_index_cur);
   retrace_line_marker_pic_index_cur_now = retrace_line_marker_pic_index_cur;
}


int callback_retrace2(int cmd, dlist_iterator & it)
{
   VSLINEMARKERINFO info1;
   int xline;
   if (cmd == LIST_CALLBACK_PROCESS_ITEM) {
      xretrace_item * ip = dlist_getp(it);
      int lpos = dlist_get_distance(it, true);
      if (ip->marker_id_valid && _LineMarkerGet(ip->line_marker_id, info1) == 0)
         xline = info1.LineNum;
      else
         xline = ip->last_line;

      say('List item ' :+ ip->buf_name :+ ' ' :+ xline :+ ' ' :+ ip->col :+
                 ' Pos ' :+ lpos);
   }
   return 0;
}
           

_command void xretrace_dump_modified_lines_list() name_info(',')
{
   dlist_iterate_list(retrace_modified_lines_list, 'callback_retrace2', true);
   say('Press F1 for help in this window');
}



_command void xretrace_dump_retrace_cursor_list() name_info(',')
{
   dlist_iterate_list(retrace_cursor_list, 'callback_retrace2', true);
   say('Press F1 for help in this window');
}

_command void xretrace_dump_modified_lines_list_for_buffer() name_info(',')
{
   dlist_iterate_list(*ptr_retrace_modified_lines_list_for_buffer, 'callback_retrace2', true);
   say('Press F1 for help in this window');
}

void xretrace_dump_list(dlist & the_list)
{
   dlist_iterate_list(the_list, 'callback_retrace2', true);
   say('Press F1 for help in this window');
}

_command void xretrace_dump_retrace_cursor_list_for_buffer() name_info(',')
{
   dlist_iterate_list(*ptr_retrace_cursor_list_for_buffer, 'callback_retrace2', true);
   say('Press F1 for help in this window');
}


_command void xretrace_kill_timer() name_info(',')
{
   if ( retrace_timer_handle != -1 ) {
      _kill_timer(retrace_timer_handle);
      retrace_timer_handle = -1;
   }
}


_command void xretrace_clear_all_markers() name_info(',')
{
   if (xretrace_has_been_started_id == XRETRACE_HAS_BEEN_STARTED_ID) {
      dlist_reset(track_demodified_list);
      _LineMarkerRemoveAllType(retrace_marker_type_id);
      _LineMarkerRemoveAllType(retrace_marker_type_id_mod);
      _LineMarkerRemoveAllType(retrace_marker_type_id_demod);
   }
}


_command void xretrace_reset() name_info(',')
{
   restore_demodified_lineflags_in_buffer();
   xretrace_clear_all_markers();
   init_xretrace();
}


void _on_load_module_xretrace(_str module_name)
{
   _str sm = strip(module_name, "B", "\'\"");
   if (strip_filename(sm, 'PD') == 'xretrace.e') {
      xretrace_kill_timer();
      xretrace_clear_all_markers();
   }
}


void show_xretrace_options_help()
{
   edit(maybe_quote_filename(XRETRACE_MODULE_NAME));
   goto_line(XRETRACE_SETTINGS_HELP_LINE);

}


void xretrace_add_bookmark_for_buffer(_str filename, int wid, int line, int col)
{
   xretrace_item   item;
   dlist * dlptr = buffer_bookmark_list._indexin(filename);
   if ( !dlptr ) {
      // create a new list for this buffer and add it to the hash array
      dlist temp;
      dlist_construct(temp, 20, false);
      buffer_bookmark_list:[filename] = temp;
      dlptr = buffer_bookmark_list._indexin(filename);
   }
   item.buf_name = filename;
   item.window_id = wid;
   item.last_line = line;
   item.mid_line = line;
   item.col = col;
   item.flags = 0;
   item.line_marker_id = _LineMarkerAdd(wid, line, 1, 1,
                              retrace_line_marker_pic_index_cur_now, retrace_marker_type_id, "xretrace" );
   item.marker_id_valid = true;

   if (!dlist_push_front(* dlptr, item))
   {
      // if the list is full we remove the oldest and clear its line marker.
      dlist_iterator it = dlist_end(* dlptr);
      xretrace_item * mp = dlist_getp(it);
      if (mp->marker_id_valid) {
         _LineMarkerRemove(mp->line_marker_id);
      }
      dlist_pop_back(* dlptr);
      // push_front should never fail here
      if (!dlist_push_front(* dlptr, item))
         _LineMarkerRemove(item.line_marker_id);
   }
   save_retrace_data_for_file(filename);
}




void xretrace_remove_bookmark_for_buffer(_str filename, int line)
{
   xretrace_item * ip;
   dlist * dlptr = buffer_bookmark_list._indexin(filename);
   if ( !dlptr ) return;

   dlist_iterator iter = dlist_begin(*dlptr);
   while( dlist_iter_valid(iter) ) {
      ip = dlist_getp(iter);
      if ( ip->last_line == line ) {
         _LineMarkerRemove(ip->line_marker_id);
         dlist_erase(iter);
         continue;
      }
      dlist_next(iter);
   }
   save_retrace_data_for_file(filename);
}


definit()
{
   //myerror();
   if (arg(1)=="L") {
      //If this is NOT an editor invocation
      xretrace_load_config();
      xretrace_kill_timer();
       //buffer_history_suspend = true;
      // this shouldn't be necessary because _on_load_module does it
      xretrace_clear_all_markers();
      buffer_retrace_cursor_list._makeempty();
      buffer_retrace_modified_lines_list._makeempty();
      buffer_bookmark_list._makeempty();
   }
   files_active_since_startup._makeempty();
   retrace_no_re_entry = 0;
   goback_is_loaded = false;
   if (def_xretrace_no_delayed_start && !file_exists(_ConfigPath() :+ 'DontRunMyMacros.txt')) {
      init_xretrace();
      xretrace_not_running = false;
   } else {
      xretrace_not_running = true;
      xretrace_has_been_started_id = 0;
   }
}


// _command void close_and_load_xbar() name_info(',')
// {
//    int wid = p_window_id;
//    int k;
//    xretrace_disable();
//    delete_xbar_windows();
//    p_window_id = wid;
//    force_load('xbar1.e');
//    //execute('show_tool_window -current-mdi xbar1');
//    init_xretrace();
// }

_command void show_xretrace_scrollbar() name_info(',')
{
   execute('show_tool_window -current-mdi xretrace_scrollbar_form');
}

  
  
  


