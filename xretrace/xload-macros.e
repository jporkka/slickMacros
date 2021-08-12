
#include "slick.sh"
#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)


#include "xretrace_not_plugin.sh"



static boolean       force_recompile;
static boolean       prompt_before_load;
static int           xdef_say_yes_no = 0;

static boolean       load_error;


// _command void xmysay(_str string="")
// {
//    if (xdef_say_yes_no != 0) 
//       say(string);
// }

static boolean xload_my_module(_str module = "")
{
   _str sm = strip(module, "B", '"');
   //xmysay(sm);
   if (!file_exists(sm)) {
      _message_box('File not found ' \n :+ sm);
      return false;
   }

   if ( prompt_before_load ) {
      int res = _message_box('Load module ?' \n :+ sm,'', MB_YESNO);
      if (res == IDNO) {
         return false;
      }
   }

   boolean was_open = false;
   int tempView = 0;
   int origView = 0;
   if ( force_recompile ) {
      int status = _open_temp_view(module, tempView, origView, "", was_open, false, false, 0, false);
      if (status) {
         _message_box('Unable to read file, error : '  :+ status :+ \n :+ module);
         return false;
      }
      _save_file('+o');
      _delete_temp_view(tempView);
      if ( was_open ) {
         edit(module);
      }
      p_window_id = origView;
   }
   if ( load(module) != 0 ) {
      load_error = true;
      _message_box('Error loading ' :+ module :+ \n 'Error msg is on the cmdline');
      return false;
   }
   return true;
}


static void load_my_module2(_str module)
{
   static boolean more;
   if (module == '') {
      more = true;
      return;
   }
   if (!more) {
      return;
   }
   more = xload_my_module(module);
   return;
}


static void xload_macros2(boolean recompile, boolean xprompt_before_load, boolean quiet = true)
{
   prompt_before_load = xprompt_before_load;
   load_my_module2('');

   if ( find_index('xretrace_disable', COMMAND_TYPE) != 0 && is_xretrace_running()) {
      int res = _message_box('Please shutdown xretrace (if not already) using the xretrace_disable command before loading.' \n \n :+ 'Continue?', '', MB_YESNO);
      if (res == IDNO) {
         load_error = true;
         return;
      }
   }
   if ( find_index('xretrace_delete_scrollbar_windows', COMMAND_TYPE) != 0 ) {
      int res = _message_box('Please shutdown xretrace windows (if not already) using' \n :+ 'the xretrace_delete_scrollbar_windows command before loading.' \n \n :+ 'Continue?', '', MB_YESNO);
      if (res == IDNO) {
         load_error = true;
         return;
      }
   }

   force_recompile = recompile;
   if (!quiet && recompile && 
       _message_box('Force source re-compile?', "xload macros", MB_YESNO) == IDYES) {
      force_recompile = true;
   };
   load_error = false;
   load_my_module2(XRETRACE_PATH :+ 'DLinkList.e');
   load_my_module2(XRETRACE_PATH :+ 'xretrace_popup.e');
   load_my_module2(XRETRACE_PATH :+ 'xretrace_scrollbar.e');
   load_my_module2(XRETRACE_PATH :+ 'xretrace.e');
   load_my_module2(XRETRACE_PATH :+ 'xtemp-file-manager.e');
   load_my_module2(XRETRACE_PATH :+ 'xxutils.e');
   load_my_module2(XRETRACE_PATH :+ 'xblock-selection-editor.e');
   load_my_module2(XRETRACE_PATH :+ 'xnotepad.e');
   load_my_module2(XRETRACE_PATH :+ 'xkeydefs.e');
}



/*
  This command is used to load xretrace, xxutils etc for a first installation.
  It allows for the fact that xretrace and the xretrace scrollbar may already be running
  and it terminates them if they are.
  When a configuration folder is upgraded during installation of a new release of
  slickedit, this function does not get called - but it doesn't need to be because slickedit
  automatically copies and rebuilds any macro files that are in the configuration folder.
*/
_command void load_xretrace_modules()
{
   xload_macros2(true, false);
}


_command void load_xretrace_modules_with_prompt()
{
   xload_macros2(true, true, false);
}


definit()
{
   if (arg(1)=="L") {
      // If this is NOT an editor invocation

      int res = _message_box('Load xretrace & xxutils ?' \n \n 'If you are installing a SlickEdit upgrade, you should select NO here.', '', MB_YESNO);
      if (res != IDNO) {
         load_xretrace_modules();
         if ( !load_error && find_index('xretrace_show_control_panel', COMMAND_TYPE) != 0 ) {
            xretrace_show_control_panel();
            _message_box( 'xretrace has been successfully loaded.' \n \n:+
                          'Use the "xretrace_options" command to set xretrace options.' \n \n :+ 
                               'Uncheck "retrace delayed start" for normal operation.');
         }
      }
      else
      {
         _message_box('Use the load_xretrace_modules command to load xretrace at any time.');
      }
   }
}

  
/* =======================================================================================================
 
  Guide for using the above macros
  xretrace, xtemp-file-manager, xxutils, xblock-selection-editor, xnotepad
 
  1) Unzip all files into a sub-folder of your configuration folder called "xretrace"
  2) Read the notes below and customize the paths if you want
  3) Backup your configuration folder
  4) Load this module xload-macros.e then run the command xload_macros.
     You will be prompted for which modules you want to load.
     DLinkList.e is needed by other modules  - no harm to load it.
     xretrace-whatever  - load all three or none
     xtemp-file-manager is needed by xxutils but it's sort of inactive until you enable it
     xnotepad  -  is needed by xxutils
     xblock-selection-editor - is optional  yyzz
 
 
  ********************************************************************************************************
  ****                            Before loading the above macros                                     ****
  ********************************************************************************************************
 
  >>>>>>>>>>>>>>>>>>>>>>>>>>   xretrace   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
  xretrace.e source file has the following at the start
 
  #define XRETRACE_PATH _ConfigPath() :+ 'xretrace' :+ FILESEP
  #define XRETRACE_MODULE_NAME XRETRACE_PATH :+ 'xretrace.e'
  #define  XRETRACE_DATA_PATH  'c:/temp'
  #define  XRETRACE_USE_SUBFOLDER YES

  It is recommended that XRETRACE_PATH be left as is - anything else is untested.
 
  As of October 2018 xretrace now includes a scrollbar and as well tracking cursor movement "globally"
  it separately tracks on a per file basis.  Per file there are three kinds - visited lines, modified
  lines and local bookmarks.  The information for this is kept in text files and there is a choice
  of  (1) one global folder   or (2) a subfolder of the source folder called xretrace_data.
 
  to get option 2 you need this
  #define  XRETRACE_USE_SUBFOLDER YES
 
  to get option 1 you need this
  #define  XRETRACE_DATA_PATH  'c:/somewhere'
  // #define  XRETRACE_USE_SUBFOLDER YES
 
  If option 1 is used, there is a mechanism for handling duplicate filenames.  This mechanism still
  happens if you use option 2 but there are never any duplicates since you can't have two files with
  the same name in the same folder.  Option 2 allows you to move the source folder around without
  losing the xretrace data.
 
  By default, xretrace does not become active when you load it for the first time.  You have to run
  xretrace_show_control_panel and turn off "xretrace delayed start".
 
 
  >>>>>>>>>>>>>>>>>>>>>>>>>>   xtemp-file-manager   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
 
  This provides a command for creating a temporary file for use as a "scratch buffer" but it also
  tries to keep these files open across workspace switches.  In fact, any file that is kept in
  the designated folder will be kept open across workspace switches.  You can specify the location
  for the temporary files with an environment variable - xtemp_files_path or use the #define below.
  The folder does not have to be a sub-folder of a config folder.
 
  // define an environment variable xtemp_files_path OR change the #define below
  #define TEMP_FILES_PATH  _ConfigPath() :+ 'xtemporary_files' :+  FILESEP

 
 
  ********************************************************************************************************
  ****                                       Using xretrace                                           ****
  ********************************************************************************************************
 
  For even more detailed info, see the start of the xretrace source file.
  After loading the macros, run the command xretrace_show_control_panel to configure.
  Try the default options to start with, then consider turning off "xretrace delayed start" (so that
  xretrace is operational as soon as slickedit is started) and turning on "track modified lines"
  (if you have "color modified lines enabled" then don't turn on "track modified lines").
  The configuration dialog can also be accessed by pressing the "insert" key when one of the "event loop"
  commands is active - xretrace_cursor_steps or xretrace_modified_line_steps
 
  Commands are as follows
  xretrace_cursor                      - go to the most recent cursor location/region.
  xretrace_modified_line               - go to the most recently modified line/region.
  xretrace_modified_line_steps         - step through modified regions using an event loop.
  xretrace_cursor_steps                - step through visited regions using an event loop.
  xretrace_cursor_back                 - go to the previous cursor location in the retrace list.
  xretrace_cursor_fwd                  - go to the next cursor location in the retrace list.
  xretrace_show_control_panel          - set options

 
 
  ********************************************************************************************************
  ****                             Using xretrace scrollbar                                           ****
  ********************************************************************************************************
 
  This is a scrollbar with a difference.  It's slightly similar to minimap.
 
  Run the command    show_xretrace_scrollbar
  to make the scrollbar form visible, then dock the form somewhere and make it skinny  - say, less than
  one centimeter wide.
 
  The scrollbar does NOT work properly when it's floating - mouse click events stop working for some reason
  or it loses track of which edit buffer it's following, not sure.
 
  If you hover the mouse cursor over the scrollbar for a bit, the current scroll position of the edit window
  will track the mouse position as the mouse cursor moves up and down.  If you left click the mouse on the
  scrollbar the edit window will track the position.
 
  Right click on the scrollbar allows you to set or clear bookmarks, to close the scrollbar and to bring
  up the xretrace options dialog.  In this dialog there are 3 settings
 
  buffer_retrace_cursor_max_items         - max items to show on the scrollbar for cursor position
  buffer_retrace_modified_max_items       - max items to show on the scrollbar for modified lines
  buffer_retrace_bookmarks_max_items      - max items to show on the scrollbar for local bookmarks
 
  There are three commands associated with the scrollbar - these apply to the current buffer only
  next_buffer_visited_line       - cycles thru visited lines
  next_buffer_modified_line      - cycles thru modified lines, if none, thru visited lines
  next_buffer_bookmark           - cycles through the bookmarks shown on the scrollbar, if none, cycles
                                   thru modified lines, if none, thru visited lines
 
 
  ***************************************************************************************************************
  ****                             Using xtemp-file-manager                                                  ****
  ***************************************************************************************************************
 
  The commands for this are on the xxutils menu.
  xtemp_new_temporary_file          - creates a new temp file with name DA-nnnnnn.txt  - nnnnnn auto increments
  xtemp_new_temporary_file_no_keep  - creates a new temp file with name NoKeep-nnnnnn.txt
                                      Files that start with NoKeep are not kept open across workspace switch.
  start_xtemp_files_handler         - the temporary files handler does not become active when slick is started
                                      until you run this command.  If you create a temp file when the handler
                                      is not active it will; ask if you want to make it active.  When it's
                                      active it will try to keep temp files open across workspace switches.
  stop_xtemp_files_handler          - stops the handler.
 
 
  ***************************************************************************************************************
  ****                             Using xxutils, xnotepad and xblock selection editor                       ****
  ***************************************************************************************************************
 
  Run the command show_xmenu1 to bring up the popup menu - maybe bind to a key such as Ctrl-M
 
  Commands that are new to this menu are
  diff_last_two_buffers
  xnotepad                    - places selected text in a floating 'notepad' window.  If a notepad window
                                already exists, current selection is appended.
  xnotepad word               - copies the current word to a notepad window
  xappend_word_to_clipboard   - appends the current work to clipboard - similar to append_to_clipboard
  xtemp_new_temporary_file    - see previous section
 
  Commands from before
  xset_diff_region  and  xcompare_diff_region
      Used to compare a set of lines - saves trekking through the diff dialog and setting up pathnames and
      line ranges.  The regions can be in the same or different buffers.  Use xset to assign the first region,
      move the cursor to the second region and use xcompare to compare.  xset_diff_region will use selected
      lines if there are any, otherwise it chooses 50 lines from current cursor position.
      xcompare uses selected lines if any, otherwise compares from cursor position for a length equal to the
      number of lines in the first region, plus 20.

  xsave_named_toolwindow_layout    
  xload_named_toolwindow_layout   - save / restore toolwindow layout  For slick V23 this uses load_named_layout
                                    for older versions it uses a hack.
 
  xblock_resize_editor           - create a block selection then run this command to resize it
                                 
 
===============================================================================================================*/
