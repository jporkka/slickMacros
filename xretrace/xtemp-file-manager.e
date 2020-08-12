

#include "slick.sh"

#pragma option(strictsemicolons,on)
//#pragma option(strict,on)
//#pragma option(autodecl,off)
#pragma option(strictparens,on)

#include "tagsdb.sh"
#import "tagwin.e"
#import 'DLinkList.e'

#define MY_NAME 'xtemp-file-manager.ex'


/* =============================================================================================================
//
//                                       Temporary file manager utility
// 
// command xtemp_new_temporary_file           -  creates a new temporary file
// command xtemp_new_temporary_file_no_keep   -  creates a new "no keep" temporary file.
// 
// This code provides commands for creating temporary text files and uses a 2 second timer callback function to
// maintain the list of temporary files.  This utility can also be used for files that you want to remain open
// across workspace open / close operations.  Any file that is placed in the TEMP_FILES_PATH folder is subject
// to the attempts of this tool to keep them open across workspace open / close.  This is achieved by
// remembering the list of "temporary" files that were open before a workspace is closed followed by the closing
// of any "temporary" files when a workspace is opened, followed by the re-opening of the original list of
// temporary files.
// 
// ==============================================================================================================
// NOTE !!!!!!!!  - at startup, the mechanism for managing the list of temporary files as described above,
//                  is NOT RUNNING.  To start it, use the command start_xtemp_files_handler, to stop it,
//                  use the command stop_xtemp_files_handler.  When a temporary file is created, if the
//                  handler is not running, you are asked if you want to start it.
// ==============================================================================================================
//
// The folder used to hold the temporary files is named 'xtemporary_files' and it is created in the user config
// folder by default. Temporary files are given names DA-xxxxxx.txt where xxxxxx starts at 000001 and wraps at
// 999999.  The current xxxxxx value is stored in 'AA-index.txt' in the temporary files folder.  The list of
// currently open temporary files is stored in a file 'AA_xtemporary_file_list.txt' in the temporary files folder.
// 
// If you want the temporary files to be in a fixed place independent of the configuration folder,
// change TEMP_FILES_PATH as needed. 
// Use single quotes. e.g.
//
// #define TEMP_FILES_PATH 'C:\Users\someone\xtemporary_files' :+ FILESEP
// or
// #define TEMP_FILES_PATH  _ConfigPath() :+ 'xtemporary_files' :+  FILESEP
// 
// 
// The utility tries to keep the current list of open temporary files independently of workspaces so when a
// workspace is opened, any temporary files that were loaded as part of the workspace are immediately closed
// and the temporary files that were already open before the workspace was opened are re-loaded.  Hence the same
// set of temporary files is kept open regardless of workspace open / close.
// 
// There are two types of temporary files  - "no keep" files have name "NoKeep-xxxxxx.txt" and these are excluded
// from the list of temporary files that this utility tries to keep open.  Hence when a workspace is opened or
// closed or when SlickEdit is re-started, the "NoKeep" files are closed.  SlickEdit always gives the chance of
// saving the "no keep" files to disk if you want.  (Attempts to delete the NoKeep files when slick closes were
// unsuccessful and caused problems on re-start).
// 
// 
// This utility uses an _on_load_ function to try to kill the 2 second timer callback after the macro file is 
// compiled so that slick doesn't generate a slick c stack when it finds that the function pointer value is invalid - 
// 
// >>>>>>>>>>>>>>>>>  This mechanism requires the MY_NAME #define at the top of this file to be set <<<<<<<<<<<<<<<<<<
// >>>>>>>>>>>>>>>>>  to the name of this source file so that the _on_load_ function can check it.  <<<<<<<<<<<<<<<<<<
// 
// 
// 
// ===================================================================================================================
//                                     Implementation detail follows
// ===================================================================================================================
// 
// When slick closes, the function _exit_xtemp_handle_temporary_files() is used to save the current list of 
// temporary files to disk ('AA_xtemporary_file_list.txt' in the temporary files folder).
//
// When a buffer is opened, _buffer_add_xtemp_files() is called (from a call_list) to initiate the
// re-generation of the current list.
//
// When a buffer is closed, _cbquit_xtemp_file_close() is called to initiate the re-generation of the current 
// list and it tries to re-start the 2 second timer callback so that when a workspace is closed, the function
// _wkspace_close_xtemp_save_file_list gets a chance to write the list of temporary files to disk before the 
// timer callback re-generates the list.
//
// When a workspace is closed, _wkspace_close_xtemp_save_file_list immediately saves the current list of
// temporary files to disk.
// 
// When a workspace is opened, _workspace_opened_handle_xtemp_files remembers the list of currently open
// temporary files so that it can close them in the 2 second timer callback.  These files get included in
// the workspace by slick.  It also sets xtemp_remember_first_file so that the currently open buffer can
// be made active again after the list of remembered files is closed.
// 
// When slick is re-started or this module is loaded, definit calls xtemp_load_temporary_file_list() to read the
// list of current/ last-active temporary files - it reads the list - it doesn't open the temporary files.  On
// re-start, workspace open results in the temporary files being loaded  - or if no workspace is opened, slick
// loads whatever files were open when it closed  - hence definit doesn't need to load any temporary files.
// 
// =============================================================================================================*/

// the timer must be global
int               xtemp_list_maintain_timer;

static dlist      xtemp_files_list;

static boolean    xtemp_ignore_cbquit;
static _str       xtemp_remember_first_file;
static boolean    xtemp_list_regenerate_needed;
static boolean    xtemp_wkspace_has_been_opened;
static boolean    xtemp_wkspace_has_been_closed;

static _str       remember_temp_files_from_workspace[];
static boolean    xtemp_list_active;
static _str       xtemp_files_path;


// define an environment variable xtemp_files_path OR change the #define below
#define TEMP_FILES_PATH  _ConfigPath() :+ 'xtemporary_files' :+  FILESEP

// if you want the temporary files to be in a fixed place independent of the configuration folder,
// change TEMP_FILES_PATH as needed. 


#define NOKEEP_PREFIX  'NoKeep-'

#define XTEMP_FILE_LIST_FILENAME  xtemp_files_path :+ 'AA_xtemporary_file_list.txt'

#define XXSTR(a) XSTR(a)
#define XSTR(a) #a
#define XSHOW_SEARCH_CONTEXT_FUNCTION   xshow_search_context_function

#define XSSRC_FALLBACK_FILE _ConfigPath() :+ 'xsearch_results_with_context.txt'



_command _str xtemp_new_temporary_file_no_keep(_str ext = '.txt', boolean quiet = false, boolean just_get_name = false) name_info(',')
{
   return xtemp_new_temporary_file(true, '', ext, quiet, just_get_name);
}


_command _str xtemp_new_temporary_file(boolean nokeep = false, _str aprefix = 'DA-', _str ext = '.txt', boolean quiet = false, boolean just_get_name = false) name_info(',')
{
   xtemp_list_regenerate_needed = true;
   if ( nokeep ) {
      aprefix = NOKEEP_PREFIX;
   }
   _str xpath = xtemp_files_path;
   if (!path_exists(xpath)) {
      if (make_path(xpath) != 0)
         _message_box('Invalid path : ' :+ xpath :+ \n 'Set environment variable xtemp_files_path or #define TEMP_FILES_PATH', 
                      MB_OK);
   }
   
   if ( !xtemp_list_active ) {
      if (_message_box('xtemp file handler is not running.'\n'Start it now?', "xtemp file handler", MB_YESNO) == IDYES) {
         start_xtemp_files_handler();
         message('xtemp file handler is running.');
      };
   }

   _str index_filename = xpath :+ 'AA-index.txt';
   boolean already_exists = file_exists(index_filename);
   boolean was_open = false;
   tempView := 0;
   origView := 0;
   // _open_temp_view creates the file if it doesn't exist
   status := _open_temp_view(index_filename, tempView, origView, "", was_open, false, false, 0, true);
   if (status) {
      if ( !quiet ) {
         _msg_box("Error reading/creating index file:\n" :+ index_filename :+ "\nErrorcode - " :+ status);
      }
      return '';
   }
   int xx = 1;
   if ( already_exists ) {
      top();
      typeless line = "";
      get_line(line);
      parse line with auto xval .;
      if ( isnumber(xval) ) {
         xx = (int)xval;
         if ( xx > 999999) {
            xx = 1;
         }
      }
   }
   int mm;
   for ( mm = 0 ; mm < 1000; ++mm, ++xx ) {
      _str fn = (_str)xx;
      // add zeroes at front
      while ( fn._length() < 6 ) {
         fn = '0' :+ fn;
      }
      _str target_filename = xpath :+ aprefix :+ fn :+ ext;
      if ( !file_exists(target_filename) ) {
         // update index file
         top();
         replace_line(xx + 1);
         _save_file('+O');   // no backup
         _delete_temp_view(tempView);
         p_window_id = origView;
         if ( !just_get_name ) {
            edit(maybe_quote_filename(target_filename));
            bottom();
         }
         return target_filename;
      }
   }
   if ( !quiet ) {
      _message_box("Search limit exceeded.  Update index file:\n" :+ index_filename :+ "\nwith a free six digit number");
   }
   _delete_temp_view(tempView);
   p_window_id = origView;
   return '';
}


// if a temporary file is closed, start the list regenerate timer
void _cbquit_xtemp_file_close(int bufId, _str bufName)
{
   if ( xtemp_ignore_cbquit || !xtemp_list_active ) {
      return;
   }
   if ( pos(xtemp_files_path, bufName )) {
      xtemp_list_regenerate_needed = true;
      // try to restart the timer so that _wkspace_close_xtemp_save_file_list gets called before maintain
      xtemp_kill_maintain_timer();
      start_xtemp_list_maintain_timer();
      //say(' quit ' :+ bufName);
   }
}


void _wkspace_close_xtemp_save_file_list()
{
   //say('wkspace close hook');
   // all buffers have already been closed by slick but there's a delay before
   // the list is regenerated, allowing the list to be saved as it was before the workspace was closed
   xtemp_save_file_list_to_disk();
   xtemp_wkspace_has_been_closed = true;
}


// "_buffer_add" fires for every file when a workspace is opened as well as on file open (I think).
void _buffer_add_xtemp_files(int newBufId, _str bufName)
{
   if ( pos(xtemp_files_path, bufName )) {
      _str fn2 = strip_filename(bufName, 'PDE');
      if ( substr(fn2,1,length(NOKEEP_PREFIX)) != NOKEEP_PREFIX) {
         xtemp_list_regenerate_needed = true;
      }
   }
}


// used after workspace open
static void close_remembered_files()
{
   if (remember_temp_files_from_workspace._length() < 1)
      return;

   xtemp_ignore_cbquit = true;
   int k = 0;
   for ( ;k < remember_temp_files_from_workspace._length(); ++k) {
      edit(remember_temp_files_from_workspace[k]);
      if ( xtemp_remember_first_file == remember_temp_files_from_workspace[k] ) {
         xtemp_remember_first_file = '';
      }
      quit(false);
   }
   remember_temp_files_from_workspace._makeempty();
   xtemp_ignore_cbquit = false;
}


// for each buffer callback
int xtemp_remember_file()
{
   if ( pos(xtemp_files_path, p_buf_name ) ) {
      remember_temp_files_from_workspace[remember_temp_files_from_workspace._length()] = p_buf_name;
   }
   return 0;
}


// this callback function makes a list of the temporary files that were open
// when the workspace was opened so that it can close them at the next timer callback
// or when the xtemp file handler is made active
void _workspace_opened_handle_xtemp_files()
{
   //say('wkspace opened hook');
   xtemp_wkspace_has_been_opened = true;
   remember_temp_files_from_workspace._makeempty();
   if ( _no_child_windows() ) {
      return;
   }
   // later, close any temporary files that the workspace has remembered
   for_each_buffer('xtemp_remember_file');
}


// for each buffer callback
// Open buffers that have the path of the temporary-files directory as part of their
// name are added to the list, excluding NOKEEP_PREFIX files - i.e. files with NOKEEP_PREFIX as the prefix
// of their name.  The array remember_temp_files_from_workspace does not exclude any files
// which has the effect of closing the nokeep files when a workspace is opened or when slick starts.
int xtemp_add_file_to_list()
{
   if ( pos(xtemp_files_path, p_buf_name )) {
      _str fn2 = strip_filename(p_buf_name, 'PDE');
      if ( substr(fn2,1,length(NOKEEP_PREFIX)) != NOKEEP_PREFIX ) {
         _str s1 = p_buf_name;
         dlist_push_back(xtemp_files_list, s1);
      }
   }
   return 0;
}

static void xtemp_regenerate_temporary_files_list()
{
   dlist_reset(xtemp_files_list);
   for_each_buffer('xtemp_add_file_to_list');
}



// xtemp_list_maintain_callback fires every 2 seconds
static void xtemp_list_maintain_callback()
{
   _kill_timer(xtemp_list_maintain_timer);
   if ( !xtemp_list_active ) {
      return;
   }

   if ( xtemp_wkspace_has_been_opened ) {
      xtemp_wkspace_has_been_opened = false;
      xtemp_wkspace_has_been_closed = false;
      xtemp_remember_first_file = _mdi.p_child.p_buf_name;
      close_remembered_files();
      xtemp_load_temporary_files_from_list();
      if ( xtemp_remember_first_file != '' ) {
         edit('+b ' :+ xtemp_remember_first_file);
      }
   } 
   else if ( xtemp_wkspace_has_been_closed ) {
      // keep the temporary files open when the workspace is closed 
      // this operation is cancelled if another workspace has been opened
      xtemp_wkspace_has_been_closed = false;
      xtemp_load_temporary_files_from_list();
   }
   else if ( xtemp_list_regenerate_needed ) 
   {
      //say(' list regenerate callback 2');
      xtemp_list_regenerate_needed = false;
      xtemp_regenerate_temporary_files_list();
      xtemp_save_file_list_to_disk();
   }
   start_xtemp_list_maintain_timer();
}


_command void start_xtemp_files_handler() name_info(',')
{
   if ( !xtemp_list_active ) {
      _kill_timer(xtemp_list_maintain_timer);
      xtemp_list_active = true;
      xtemp_load_temporary_file_list();
      xtemp_wkspace_has_been_closed = false;
      xtemp_list_maintain_timer = _set_timer(500, xtemp_list_maintain_callback);
   }
}

_command void stop_xtemp_files_handler() name_info(',')
{
   if ( xtemp_list_active ) {
      _kill_timer(xtemp_list_maintain_timer);
      xtemp_list_active = false;
      xtemp_wkspace_has_been_opened = false;
      xtemp_wkspace_has_been_closed = false;
   }
}


_command void xtemp_kill_maintain_timer() name_info(',')
{
   _kill_timer(xtemp_list_maintain_timer);
}

static void start_xtemp_list_maintain_timer()
{
   xtemp_list_maintain_timer = _set_timer(2000, xtemp_list_maintain_callback);
}


// load the files
static void xtemp_load_temporary_files_from_list()
{
   //say(' load temporary ');
   dlist_iterator iter = dlist_begin(xtemp_files_list);
   for ( ; dlist_iter_valid(iter); dlist_next(iter)) {
      _str fn = * dlist_getp(iter);
      if ( file_exists(fn) ) {
         edit( maybe_quote_filename(fn));
      }
   }
}

// load the list, (not the files)
static void xtemp_load_temporary_file_list()
{
   _str filename = XTEMP_FILE_LIST_FILENAME;
   _str line;
   // max 1000 temporary files open
   dlist_construct(xtemp_files_list, 1000, false);
   if (file_exists(filename)) {
      tempView := 0;
      origView := 0;
      status := _open_temp_view(filename, tempView, origView);
      if (!status) {
         top();
         for ( ;; ) {
            get_line(line);
            if ( line._length() > 0 ) {
               if ( pos(xtemp_files_path, line )) {
                  dlist_push_back(xtemp_files_list, line);
               }
            }
            if ( down() ) {
               break;
            }
         }
      }
      _delete_temp_view(tempView);
      p_window_id = origView;
   }
}


// save the list to disk, (not the files)
static void xtemp_save_file_list_to_disk()
{
   _str filename = XTEMP_FILE_LIST_FILENAME;
   tempView := 0;
   origView := 0;
   boolean was_open;
   // _open_temp_view creates the file if it doesn't exist or wipes it if it does
   status := _open_temp_view(filename, tempView, origView, "", was_open, true, false, 0, true);
   if ( !status ) {
      top();
      dlist_iterator iter = dlist_begin(xtemp_files_list);
      for ( ; dlist_iter_valid(iter); dlist_next(iter)) {
         insert_line(*dlist_getp(iter));
      }
      _save_file('+O');
      _delete_temp_view(tempView);
   }
   p_window_id = origView;
}



static _str nokeep_files_to_delete[];

// this function is currently not called
int xtemp_maybe_discard_file()
{
   _str fn = p_buf_name;
   if ( pos(xtemp_files_path, p_buf_name )) {
      _str fn2 = strip_filename(p_buf_name, 'PDE');
      if ( substr(fn2,1,length(NOKEEP_PREFIX)) :== NOKEEP_PREFIX ) {
         nokeep_files_to_delete[nokeep_files_to_delete._length()] = fn;
      }
   }
   return 0;
}


static boolean is_this_a_nokeep_file(_str fn)
{
   if ( pos(xtemp_files_path, fn )) {
      _str fn2 = strip_filename(fn, 'PDE');
      if ( substr(fn2,1,length(NOKEEP_PREFIX)) :== NOKEEP_PREFIX ) {
         return true;
      }
   }
   return false;
}


// this function is currently not called
static void close_and_delete_nokeep_buffers()
{
   nokeep_files_to_delete._makeempty();
   for_each_buffer('xtemp_maybe_discard_file');
   int k = 0;
   for ( ; k < nokeep_files_to_delete._length(); ++k ) {
      edit(nokeep_files_to_delete[k]);
      if ( pos(xtemp_files_path, p_buf_name )) {
         quit();
         delete_file(nokeep_files_to_delete[k]);
      }
   }
}

// slick is closing, save the list and discard no-keep files
void _exit_xtemp_handle_temporary_files()
{
   xtemp_wkspace_has_been_closed = false;
   xtemp_wkspace_has_been_opened = false;
   xtemp_list_regenerate_needed = false;
   if ( xtemp_list_active ) {
      xtemp_save_file_list_to_disk();
   }
   // this deletes the no-keep files but causes problems on restart
   //for_each_buffer('xtemp_maybe_discard_file');
}

void _on_load_module_xtemp_files(_str module_name)
{
   _str sm = strip(module_name, "B", "\'\"");
   if (strip_filename(sm, 'PD') == MY_NAME) {
      //say('on load kill');
      xtemp_kill_maintain_timer();
   }
}

#if 0
static void xmy_grep_cursor()
{
   // now get the destination information and
   // submit it to the preview window
   _str filename;
   int linenum, col;
   int status = _mffindGetDest(filename, linenum, col, true);
   if(status == 0) {
      VS_TAG_BROWSE_INFO cm;
      tag_browse_info_init(cm);
      cm.member_name = "Search result";
      cm.file_name = filename;
      cm.line_no   = linenum;
      cm.column_no = col;
      cb_refresh_output_tab(cm, true, true, false, APF_SEARCH_RESULTS);
   }
}

static _str search_results_first_filename;


// this function is added to the grep context menu
_command void XSHOW_SEARCH_CONTEXT_FUNCTION() name_info(',')
{
   // current buffer is the search results window  - get its name before we do anything else
   _str bufn = p_buf_name;
   //close_and_delete_nokeep_buffers();   

   // open the search results in an edit window - see grep_command_menu() 's' option
   //edit('+q +b 'maybe_quote_filename(bufn), EDIT_NOADDHIST);

   _str target_filename = xtemp_new_temporary_file_no_keep('.gcs', true, true);
   if ( target_filename == '' ) {
      target_filename = XSSRC_FALLBACK_FILE;
   }

   // jump through some hoops to preserve search highlighting and +- markers as well as
   // avoiding contaminating the grep window because we might need it again

   // open the ".search" buffer again and save it with a new name  - this preserves the 
   // search highlighting and the +- show/hide markers in the left gutter
   edit('+q +b 'maybe_quote_filename(bufn), EDIT_NOADDHIST);
   if (save_as('+ftext ' :+ target_filename) == 0) 
   {
      edit('+q +b 'maybe_quote_filename(bufn), EDIT_NOADDHIST);
      quit();

      edit('+ftext ' :+ target_filename, EDIT_NOADDHIST);

      if ( p_buf_name != target_filename ) {
         delay(500);
         if ( p_buf_name != target_filename ) {
            _message_box("Error opening file\n" :+ target_filename);
            return;
         }
      }

      xadd_context_to_search_results();
      find("^find","LI-?");
      _save_file();
      _set_read_only(true,true, true, false);
      xfloat1();
       
      //_SetEditorLanguage(_Filename2LangId(search_results_first_filename));
      //_SetEditorLanguage("grep");
   }
   else {
      _message_box("Error creating file\n" :+ target_filename);
   }
}


  
_command int xgrep_goto() name_info(','VSARG2_NOEXIT_SCROLL|VSARG2_READ_ONLY|VSARG2_CMDLINE|VSARG2_REQUIRES_EDITORCTL)
{
   _str filename;
   int linenum, col;
   int status = _mffindGetDest(filename, linenum, col);
   if(status == 0) {
      status = _mffindGoTo(filename,linenum,col,false);
   }
   return (status);
}
  

_command void xadd_context_to_search_results() name_info(',')
{
   #define NUM_CONTEXT_LINES 5
   _str lines_above[];
   _str lines_below[];
   _str s1, fn1, fn2, repl;
   int k1, k2;
   _str blank1 = "";
   _str sep2 = "---------------------------------------- ";
   _str sep3 = " ----------------------------------------------------------------";
   boolean skipf = true;

   _str sr = p_buf_name;
   search_results_first_filename = '';
   top();
   if (down() != 0)
      return;
   while( 1 ) {
      while(1) {
         get_line(s1);
         if ( pos("File", s1 ) == 1 ) {
            // todo - remember the name of the file  - we might need to close it
            fn1 = substr(s1,6);
            fn2 = strip_filename(fn1, 'PD');
            if ( search_results_first_filename == '' ) {
               search_results_first_filename = fn1;
            }
            skipf = is_this_a_nokeep_file(fn1);
            if ( skipf ) {
               if (down() != 0)
                  return;
               up();
               _delete_line();
            } 
            else {
               up();
               insert_line(blank1);  // inserts after the current line
               down();  // down to the filename line
               if (down() != 0) {
                  return;
               }
            }
            continue;
         } 
         else if ( pos("Total found:", s1 ) == 1 ) {
            up();
            insert_line(blank1);
            insert_line(sep3);
            find("^find","LI-?");
            insert_line(s1);
            return;
         }
         else if ( !skipf ) {
            // get the context for this line
            break;
         }
         else {   // skipf is true
            if (down() != 0)
               return;
            up();
            _delete_line();
         }
         // continue the while loop
      }

      // cursor is on the listed line in the search results
      // switch to the target file
      if (xgrep_goto() != 0)
      {
         if (down() != 0)
            return;
         continue;
      }
      get_line(repl);

      // get lines above
      lines_above._makeempty();
      k1 = 0;
      while ( k1 < NUM_CONTEXT_LINES ) {
         if ( up(1) != 0 ) {
            break;
         }
         get_line(lines_above[k1++]);
      }
      down(k1);

      // get lines below
      lines_below._makeempty();
      k1 = 0;
      while ( k1 < NUM_CONTEXT_LINES ) {
         if ( down(1) != 0 ) {
            break;
         }
         get_line(lines_below[k1++]);
      }
      up(k1);  // don't have to do this

      edit(sr);       // back to the search results buffer
      // cursor is on the listed line in the search results

      s1 = strip(s1, 'L');
      k2 = pos(':', s1);
      replace_line(" " :+ repl);  // remove line col prefix, add a leading space
      up();
      insert_line(blank1);  // inserts after the current line
      insert_line(substr(s1, 1, k2) :+ sep2 :+ fn2 :+ sep3);
      insert_line(blank1);  // inserts after the current line

      // insert lines above
      k1 = lines_above._length();
      while ( k1-- ) {
         insert_line(" " :+ lines_above[k1]);
      }

      // insert lines below
      down();   // put the cursor on the listed line
      k1 = 0;
      while ( k1 < lines_below._length() ) {
         insert_line(" " :+ lines_below[k1++]);
      }
      down();  // move to the next search results line
   }
}


_command void set_grep_mode() name_info(',')
{
   _SetEditorLanguage("grep");
}
 
#endif
 

definit()
{
   xtemp_ignore_cbquit = false;
   remember_temp_files_from_workspace._makeempty();
   xtemp_wkspace_has_been_opened = false;
   xtemp_wkspace_has_been_closed = false;

   xtemp_files_path = get_env('xtemp_files_path');
   if ( xtemp_files_path == '' ) {
      set_env('xtemp_files_path', TEMP_FILES_PATH);
      xtemp_files_path = TEMP_FILES_PATH;
   }
   xtemp_files_path :+= FILESEP;
   
   if ( arg(1) == 'L' ) {
      _kill_timer(xtemp_list_maintain_timer);
   }
   xtemp_list_active = false;

   #if 0
   int index = find_index("_grep_menu_default", oi2type(OI_MENU));
   if (index) {
      int menu_handle = _mdi._menu_load(index,'P');
      int mh, mp;
      if ( _menu_find(menu_handle, XXSTR(XSHOW_SEARCH_CONTEXT_FUNCTION), mh, mp, 'M' ) == 0 ) {
         return;
      }
      // have to use index as menu handle 
      _menu_insert(index, -1,MF_ENABLED,"Show conte&xt",
                                XXSTR(XSHOW_SEARCH_CONTEXT_FUNCTION),"","help context menu","");
   }
   #endif
}




//defeventtab gpgrep4_keys;
//def  'ENTER'= xgrep_goto;


//def  'DEL'= grep_delete
//def  'C-UP'= grep_prev_file
//def  'C-DOWN'= grep_next_file
//def  'LBUTTON-DOUBLE-CLICK'= grep_goto_mouse


// defeventtab grep_keys;
// def  'ENTER'= grep_goto;
// def  'UP'= grep_cursor;
// def  'DOWN'= grep_cursor;
// def  'PGUP'= grep_cursor;
// def  'PGDN'= grep_cursor;
// def  'DEL'= grep_delete;
// def  'S-UP'= grep_prev_file;
// def  'S-DOWN'= grep_next_file;
// def  'C-UP'= preview_cursor_up;
// def  'C-DOWN'= preview_cursor_down;
// def  'C-PGUP'= preview_page_up;
// def  'C-PGDN'= preview_page_down;
// def  'LBUTTON-DOWN'= grep_cursor;
// def  'LBUTTON-DOUBLE-CLICK'= grep_lbutton_double_click;


