



/******************************************************************************
*  $Revision: 1.4 $
******************************************************************************/



#include "slick.sh"

#import 'dlinklist.e'



#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)




struct buffer_item_s {
    int buf_id;
};



// goback_buffer_list is the linked list that holds the list of buffer IDs
static dlist goback_buffer_list;


// buffer_validate_list is an array that is populated by for_each_buffer and is used to
// validate the buffer IDs in goback_buffer_list
static int buffer_validate_list [];
static int buffer_validate_list_num_buffers;


// suspend_goback_buffer_history is set true to stop the _switchbuf callback
// from executing.  It can be set/cleared by the goback_toggle_buffer_list_history_enable()
// command and is temporarily set true by goback_step_thru_buffer_list
static boolean suspend_goback_buffer_history;

static boolean goback_buffer_pending_flag;
static int goback_buffer_pending_buf_id;
static boolean goback_buf_id_is_pending;

static int goback_buffer_list_array[];


static int switchbuf_goback_no_re_entry;


static void move_buf_id_to_front(int buf_id)
{
   dlist_iterator iter = dlist_iterator_new(goback_buffer_list);
   while (dlist_next(iter)) {
      buffer_item_s * gip = dlist_getp(iter);
      if (gip->buf_id == buf_id) {
         dlist_move_to_front(iter);
         return;
      }
   }
   buffer_item_s it;
   it.buf_id = buf_id;
   dlist_push_front(goback_buffer_list, it);
}


// goback_buffer_for_each_buf_list1() is called by for_each_buffer()
// for_each_buffer steps thru visible buffers from "oldest" to
// most recently accessed
int goback_buffer_for_each_buf_list1()
{
    buffer_validate_list[buffer_validate_list_num_buffers++] = p_buf_id;
    return 0;
}


// The list of buf_ids in goback_buffer_list is validated by using
// for_each_buffer to get a list of current buf_ids.  buf_ids that no longer
// exist are removed from goback_buffer_list.
static void validate_goback_buffer_list()
{
    buffer_validate_list_num_buffers = 0;
    _mdi.p_child.for_each_buffer( 'goback_buffer_for_each_buf_list1' );

    dlist_iterator iter = dlist_iterator_new(goback_buffer_list);
    dlist_iterator iter2 = iter;
    while (dlist_next(iter)) {
       buffer_item_s * gip = dlist_getp(iter);
       int bufid = gip->buf_id;
       int x1;
       for (x1 = buffer_validate_list_num_buffers - 1; x1 >= 0; --x1) {
           if (bufid == buffer_validate_list[x1])
               break;
       }
       if (x1 < 0) {
          // not found so remove
          dlist_erase(iter);
          iter = iter2;
       }
       else {
          iter2 = iter;
       }
    }
}


static void switchbuf_goback_buffer_list()
{
   static int last_buf_id, buf_id;
   // buf_id = _mdi.p_child.p_buf_id;
   buf_id = p_buf_id;
   if (last_buf_id == buf_id) {
      return;
   }
   last_buf_id = buf_id;

   if (!suspend_goback_buffer_history) {
      if (_mdi.p_child.p_buf_flags & HIDE_BUFFER) {
         return;
      }
      if (pos('.',_mdi.p_child.p_buf_name) == 1) {
         return;
      }
      /************************************************************************
      _str this_buffer = _mdi.p_child.p_buf_name;

      if (this_buffer == '') {
         return;
      }
      if (this_buffer == '.command') {
         return;
      }
      if (this_buffer == '.process') {
         return;
      }
      if (this_buffer == '.slickc_stack') {
         return;
      }
      if (this_buffer == '.References Window Buffer') {
         return;
      }
      if (this_buffer == '.Tag Window Buffer') {
         return;
      }
      ************************************************************************/

      if (goback_buffer_pending_flag) {
         goback_buffer_pending_flag = false;
         goback_buf_id_is_pending = true;
         goback_buffer_pending_buf_id = buf_id;
      } else {
         if (goback_buf_id_is_pending) {
            if (goback_buffer_pending_buf_id == buf_id)
               return;
            goback_buf_id_is_pending = false;
            move_buf_id_to_front(goback_buffer_pending_buf_id);
         }
         move_buf_id_to_front(buf_id);
      }
   }
}


// Functions that start with _switchbuf_ get called via call_list when a new
// buffer becomes active.
void _switchbuf_goback_buffer()
{
   // This code protects against re-entry but its main job is to avoid calling
   // the switchbuf_goback_buffer_list() function if the last call didn't exit
   // normally.  This avoids getting repeated "slick C stacks" that could make
   // the editor unusable.
   if (switchbuf_goback_no_re_entry > 0) {
      return;
   }
   ++switchbuf_goback_no_re_entry;
   if (switchbuf_goback_no_re_entry == 1) {
      switchbuf_goback_buffer_list();
   }
   --switchbuf_goback_no_re_entry;
}



/*****************************************************************************
int callback_gb1(int cmd, dlist_iterator & it)
{
   if (cmd == LIST_CALLBACK_PROCESS_ITEM) {
      message('List item ' :+ ((buffer_item_s*)dlist_getp(it))->buf_id :+
                 ' Pos ' :+ dlist_get_distance(it));
   }
   return 0;
}

_command void show_goback() name_info(',')
{
   dlist_iterate_list(goback_buffer_list, 'callback_gb1');
}
******************************************************************************/


void goback_set_buffer_history_pending_mode()
{
    goback_buffer_pending_flag = true;
}


void goback_process_pending_buffer_history()
{
    if (!suspend_goback_buffer_history)
    {
        if (goback_buf_id_is_pending) {
            move_buf_id_to_front(goback_buffer_pending_buf_id);
        }
    }
    goback_buf_id_is_pending = false;
    goback_buffer_pending_flag = false;
}


void goback_build_buffer_list_array(int (&blist)[])
{
    blist._makeempty();
    dlist_iterator iter = dlist_iterator_new(goback_buffer_list);
    while (dlist_next(iter)) {
       buffer_item_s * gip = dlist_getp(iter);
       blist[blist._length()] =  gip->buf_id;
    }
}



// goback_step_thru_buffer_list steps through the buffers recently visited.
//    F12 cycles the two most recent buffers
//    C-F12 cycles 3 most recent buffers
//    Numeric keys (n) 1 - 9 cycle that number with immediate jump to buffer n
//    Up, down, left, right cycle the full list
//    ESC exits
//    Any other key exits and is currently ignored - if you want such keys to
//    be processed, uncomment the call to call_key.
//
// if parameter cmode is true, the previous buffer is switched to, with immediate exit
_command void goback_step_thru_buffer_list(boolean cmode = false)
{
   if (suspend_goback_buffer_history)
      return;

   // pos of zero is first buffer in the list
   // on entry, go to the second buffer in the list

   int lmpos = 1,mpos = 1,cpos = 1;
   _str keyt = '';
   typeless key;
   boolean direction = true;

   if (_Nofbuffers() <= 1)
      return;

   validate_goback_buffer_list();
   goback_build_buffer_list_array(goback_buffer_list_array);
   if (goback_buffer_list_array._length() == 0)
      return;

   suspend_goback_buffer_history = true;

   for (;;)
   {
      if (cpos >= goback_buffer_list_array._length()) {
         cpos = 0;
         mpos = lmpos = goback_buffer_list_array._length()-1;
      }

      if (cmode) {
         suspend_goback_buffer_history = false;
         if (cpos >= goback_buffer_list_array._length())
             cpos = 0;
         p_buf_id = goback_buffer_list_array[cpos];
         edit('+B ' p_buf_name);
         return;
      }

      if (cpos >= goback_buffer_list_array._length())
          cpos = 0;
      p_buf_id = goback_buffer_list_array[cpos];
      message('Posn  ' :+ (cpos+1) :+ '    ' :+ strip_filename(p_buf_name,'D''P'));

      key = get_event('N');   // refresh screen and get a key
      keyt = event2name(key);
      direction = true;
      switch (keyt) {
         case 'F12' :
            mpos = 1;
            break;
         case 'C-F12' :
            mpos = 2;
            break;

         case 'UP' :
         case 'LEFT' :
            direction = false;
         case 'RIGHT' :
         case 'DOWN' :
            mpos = lmpos = goback_buffer_list_array._length()-1;
            break;

         case '1' :
         case '2' :
         case '3' :
         case '4' :
         case '5' :
         case '6' :
         case '7' :
         case '8' :
         case '9' :
            mpos = (int)key - 1;
            break;

         case 'ESC' :
            suspend_goback_buffer_history = false;
            edit('+b ' p_buf_name);
            message(strip_filename(p_buf_name,'D''P'));
            return;

         default:
            suspend_goback_buffer_history = false;
            edit('+b ' p_buf_name);
            message(strip_filename(p_buf_name,'D''P'));
            //if (length(keyt)==1) {
            //   call_key(key);
            //}
            return;
      }

      if (lmpos != mpos) {
         // change of key, go straight to new pos
         cpos = lmpos = mpos;
      } else {
         // same key or special key, step one position
         if (direction) {
            if (cpos < mpos)
               ++cpos;
            else
               cpos = 0;
         } else {
            if (cpos > 0)
               --cpos;
            else
               cpos = mpos;
         }
      }
   }
}

// switch to the previous buffer
_command void goback_last_buffer()
{
    if (!suspend_goback_buffer_history)
        goback_step_thru_buffer_list(true);
    else
       message('buffer history is currently disabled');
}


_command void goback_toggle_buffer_list_history_enable(){
    if (suspend_goback_buffer_history)
    {
        suspend_goback_buffer_history = false;
        message('buffer history enabled');
    }
    else
    {
        suspend_goback_buffer_history = true;
        message('buffer history disabled');
    }
}


_command void goback_enable_buffer_list_history(){
    suspend_goback_buffer_history = false;
}


_command void goback_suspend_buffer_list_history(){
    suspend_goback_buffer_history = true;
}


/**
 * Goes to bookmark identified by a letter or number corresponding to the
 * key pressed which invoked this command.  This command may only be bound
 * to the keys Alt+0..Alt+9, Alt+A..Alt+Z, Ctrl+1..Ctrl+9, and Ctrl+A..Ctrl+Z.
 *
 * Unlike alt_gtbookmark, this function does a _switchbuf_goback_buffer_list call
 * to get the newly selected buffer to the top of the buffer-list history
 *
 * @appliesTo Edit_Window
 *
 * @see set_bookmark
 * @see goto_bookmark
 * @see next_bookmark
 * @see prev_bookmark
 * @see alt_bookmark
 * @see alt_gtbookmark
 * @categories Bookmark_Functions
 */
_command alt_gtbookmark_new() name_info(','VSARG2_LASTKEY|VSARG2_EDITORCTL)
{
    alt_gtbookmark();
    _switchbuf_goback_buffer();
}



definit ()
{
    dlist_construct(goback_buffer_list, 100, true);
    switchbuf_goback_no_re_entry = 0;
}


     



