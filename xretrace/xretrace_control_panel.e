
/******************************************************************************
*  $Revision: 1.1 $                                                            
******************************************************************************/

#ifndef XRETRACE_INCLUDING

// this module is normally #INCLUDEd by xretrace.e (I think the reason for this
// was because access to xretrace_config_data didn't work reliably at startup
// when they were separate modules.)

#include "slick.sh"


#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)

#endif


#include "xretrace_form.e"

defeventtab xretrace_form;

boolean def_xretrace_no_delayed_start;


#define XRETRACE_VERSION 'V1_00'

//_control ctlsstab1;
_control ctlframe1;
_control ctlframe2;

_control show_retrace_modified_line_markers_checkbox;
_control show_retrace_cursor_line_markers_checkbox;
_control show_most_recent_modified_line_markers_checkbox;
_control show_demodified_line_markers_checkbox;
_control track_demodified_lines_with_lineflags_checkbox;
_control track_demodified_lines_with_line_markers_checkbox;

_control retrace_timer_interrupt_sampling_interval_textbox;
_control retrace_cursor_max_history_length_textbox;
_control retrace_modified_lines_max_history_length_textbox;
_control retrace_cursor_line_distance_recording_granularity_textbox;
_control retrace_cursor_line_distance_viewing_granularity_textbox;
_control retrace_cursor_min_region_pause_time_textbox;
_control retrace_cursor_min_line_pause_time_textbox;
_control retrace_delayed_start_checkbox;
_control track_modified_lines_checkbox;
_control capture_retrace_data_to_disk_checkbox;

_control disable_button;
_control dump_cursor_retrace_button;
_control dump_mod_lines_button;

_control buffer_retrace_bookmarks_max_items_textbox;
_control buffer_retrace_modified_max_items_textbox;
_control buffer_retrace_cursor_max_items_textbox;

struct xretrace_config
{
   int track_demodified_lines_with_line_markers;
   int show_retrace_modified_line_markers;
   int show_retrace_cursor_line_markers;
   int show_most_recent_modified_line_markers;      
   int show_demodified_line_markers;       

   _str retrace_timer_interrupt_sampling_interval;
   _str retrace_cursor_max_history_length;
   _str retrace_modified_lines_max_history_length;

   _str retrace_cursor_line_distance_recording_granularity;
   _str retrace_cursor_line_distance_viewing_granularity;

   _str retrace_cursor_min_region_pause_time_str;
   int retrace_cursor_min_region_pause_time;
   _str retrace_cursor_min_line_pause_time_str;
   int retrace_cursor_min_line_pause_time;

   int track_demodified_lines_with_lineflags;
   int retrace_delayed_start;
   int track_modified_lines;
   _str buffer_retrace_cursor_max_items;
   _str buffer_retrace_modified_max_items;
   _str buffer_retrace_bookmarks_max_items;
   int capture_retrace_data_to_disk;
   int dummy;
};



xretrace_config xretrace_config_data;

_str xretrace_module_name;


xretrace_config * get_xretrace_config_data()
{
   return &xretrace_config_data;
}



#define CFG_FUNC_SET_DEFAULT 1
#define CFG_FUNC_SET_ITV_TO_PPV 2
#define CFG_FUNC_INSERT_ITEM 3
#define CFG_FUNC_SET_ITV_TO_VAL 4
#define CFG_FUNC_SET_PPV_TO_ITV 5

// in MAKE_CONFIG_FUNC macro, item_name becomes the name of a function used to
// perform operations for this item and is also the name of the item in the
// ini file and the member name of persistent_config_data struct.  
// For the CFG_FUNC_SET_ITV_TO_VAL operation, only the item whose
// name matches is affected.  ptype is used to typecast a value before it is
// assigned to the item.
#define MAKE_CONFIG_FUNC(item_name, property_name, default_val, ptype)    \
static void item_name(int what, xretrace_config * config_ptr, typeless val, _str field_name)\
{\
   switch (what) {\
      case CFG_FUNC_SET_DEFAULT : config_ptr->##item_name = (ptype)default_val; return;\
      case CFG_FUNC_SET_ITV_TO_PPV : config_ptr->##item_name = (ptype)property_name; return;\
      case CFG_FUNC_INSERT_ITEM : insert_line( #item_name '=' :+ config_ptr->##item_name); return;\
      case CFG_FUNC_SET_ITV_TO_VAL : \
         if (strcmp(field_name,#item_name) == 0) config_ptr->##item_name = (ptype)val;\
         return;\
      case CFG_FUNC_SET_PPV_TO_ITV : property_name = config_ptr->##item_name; return;\
      default : return;\
   }\
}



   // generate all the config functions

   MAKE_CONFIG_FUNC(show_retrace_cursor_line_markers, p_active_form.show_retrace_cursor_line_markers_checkbox.p_value, 0, int)
   MAKE_CONFIG_FUNC(show_most_recent_modified_line_markers, p_active_form.show_most_recent_modified_line_markers_checkbox.p_value, 0, int)
   MAKE_CONFIG_FUNC(show_demodified_line_markers, p_active_form.show_demodified_line_markers_checkbox.p_value, 0, int)
   MAKE_CONFIG_FUNC(track_demodified_lines_with_line_markers, p_active_form.track_demodified_lines_with_line_markers_checkbox.p_value, 0, int)
   MAKE_CONFIG_FUNC(track_demodified_lines_with_lineflags, p_active_form.track_demodified_lines_with_lineflags_checkbox.p_value, 0, int)

   MAKE_CONFIG_FUNC(retrace_timer_interrupt_sampling_interval, p_active_form.retrace_timer_interrupt_sampling_interval_textbox.p_text, '250', _str)
   MAKE_CONFIG_FUNC(retrace_cursor_max_history_length, p_active_form.retrace_cursor_max_history_length_textbox.p_text, '50', _str)
   MAKE_CONFIG_FUNC(retrace_modified_lines_max_history_length, p_active_form.retrace_modified_lines_max_history_length_textbox.p_text, '20', _str)
   MAKE_CONFIG_FUNC(retrace_cursor_line_distance_recording_granularity, p_active_form.retrace_cursor_line_distance_recording_granularity_textbox.p_text, '16', _str)
   MAKE_CONFIG_FUNC(retrace_cursor_line_distance_viewing_granularity, p_active_form.retrace_cursor_line_distance_viewing_granularity_textbox.p_text, '8', _str)
   MAKE_CONFIG_FUNC(retrace_cursor_min_region_pause_time_str, p_active_form.retrace_cursor_min_region_pause_time_textbox.p_text, '8', _str)
   MAKE_CONFIG_FUNC(retrace_cursor_min_line_pause_time_str, p_active_form.retrace_cursor_min_line_pause_time_textbox.p_text, '4', _str)
   MAKE_CONFIG_FUNC(retrace_delayed_start, p_active_form.retrace_delayed_start_checkbox.p_value, 1, int)
   MAKE_CONFIG_FUNC(track_modified_lines, p_active_form.track_modified_lines_checkbox.p_value, 1, int)
   MAKE_CONFIG_FUNC(show_retrace_modified_line_markers, p_active_form.show_retrace_modified_line_markers_checkbox.p_value, 0, int)

   MAKE_CONFIG_FUNC(buffer_retrace_cursor_max_items, p_active_form.buffer_retrace_cursor_max_items_textbox.p_text, '4', _str)
   MAKE_CONFIG_FUNC(buffer_retrace_modified_max_items, p_active_form.buffer_retrace_modified_max_items_textbox.p_text, '4', _str)
   MAKE_CONFIG_FUNC(buffer_retrace_bookmarks_max_items, p_active_form.buffer_retrace_bookmarks_max_items_textbox.p_text, '4', _str)

   MAKE_CONFIG_FUNC(capture_retrace_data_to_disk, p_active_form.capture_retrace_data_to_disk_checkbox.p_value, 0, int)

   // items added to this list should also be added to call_config_funcs below


#define CALL(item_name,val) item_name(what, config_ptr, val, field_name)

static call_config_funcs(int what, xretrace_config * config_ptr, typeless val = 0, _str field_name = '')
{
   CALL(show_retrace_cursor_line_markers, val);
   CALL(show_most_recent_modified_line_markers, val);
   CALL(show_demodified_line_markers, val);              
   CALL(track_demodified_lines_with_line_markers, val);              
   CALL(track_demodified_lines_with_lineflags, val);              
                                                             
   CALL(retrace_timer_interrupt_sampling_interval, val);
   CALL(retrace_cursor_max_history_length, val);
   CALL(retrace_modified_lines_max_history_length, val);
   CALL(retrace_cursor_line_distance_recording_granularity, val);
   CALL(retrace_cursor_line_distance_viewing_granularity, val);
   CALL(retrace_cursor_min_region_pause_time_str, val);
   CALL(retrace_cursor_min_line_pause_time_str, val);                 
   CALL(retrace_delayed_start, val);
   CALL(track_modified_lines, val);
   CALL(show_retrace_modified_line_markers, val);

   CALL(buffer_retrace_cursor_max_items, val);
   CALL(buffer_retrace_modified_max_items, val);
   CALL(buffer_retrace_bookmarks_max_items, val);
   CALL(capture_retrace_data_to_disk, val);


}

#undef CALL


static void xsave_config(xretrace_config * dptr, _str section_name, boolean no_form = false)
{
   // copy widget property values into item values
   if (!no_form)
      call_config_funcs(CFG_FUNC_SET_ITV_TO_PPV, dptr);

   xretrace_config_data.retrace_cursor_min_region_pause_time = 
             (int)xretrace_config_data.retrace_cursor_min_region_pause_time_str;
   xretrace_config_data.retrace_cursor_min_line_pause_time = 
             (int)xretrace_config_data.retrace_cursor_min_line_pause_time_str;
   call_list('_xretrace_config_update', &xretrace_config_data);

   int section_view, current_view;
   current_view = _create_temp_view(section_view);
   if (current_view == '') {
       return;
   }
   activate_view(section_view);
   top();


   insert_line('xretrace_config_version=' :+ XRETRACE_VERSION);
   // write all item values to the active view
   call_config_funcs(CFG_FUNC_INSERT_ITEM, dptr, 0);

   int res = _ini_replace_section(_config_path() :+ 'xretrace_config.ini', section_name, section_view);
   boolean temp = def_xretrace_no_delayed_start;
   def_xretrace_no_delayed_start = !xretrace_config_data.retrace_delayed_start;
   if (temp != def_xretrace_no_delayed_start) {
      _config_modify_flags(CFGMODIFY_DEFVAR);
   }
}


static void do_xretrace_load_config(xretrace_config * dptr, _str section_name)
{
    // set default values for all items
    call_config_funcs(CFG_FUNC_SET_DEFAULT, dptr);      

    int section_view, current_view;
    get_view_id(current_view);
    int res;
    res = _ini_get_section(_config_path() :+ 'xretrace_config.ini', section_name, section_view);
    if (res) {
        return;
    }
    activate_view(section_view);
    top();
    _insert_text(' '\r\n);  // _ini_parse_line does a down() first
    top();
    activate_view(current_view);
    _str field_name,value;
    int k = 0, maxl = 0;
    while ( k==0 ) {
        if (++maxl > 4000) {
            break;
        }
        k = _ini_parse_line(section_view,field_name,value);
        if (k==0) {
           // Set item value whose name matches the field name, to the parsed value
           call_config_funcs(CFG_FUNC_SET_ITV_TO_VAL, dptr, value, field_name);
        }
    }
    xretrace_config_data.retrace_cursor_min_region_pause_time = 
              (int)xretrace_config_data.retrace_cursor_min_region_pause_time_str;
    xretrace_config_data.retrace_cursor_min_line_pause_time = 
              (int)xretrace_config_data.retrace_cursor_min_line_pause_time_str;
    def_xretrace_no_delayed_start = !xretrace_config_data.retrace_delayed_start;
}


void xretrace_form.'ESC'()
{
   int pf = p_active_form;
   xsave_config(&xretrace_config_data, 'xretrace_config' );
   pf._delete_window();
}


void xretrace_form.on_create(_str arg1 = '')
{
    ctlframe1.p_visible = true;
    ctlframe2.p_visible = true;
    //ctlsstab1.p_ActiveTab = 0;
    //ctlframe2.p_x = ctlframe1.p_x;
    //ctlframe2.p_y = ctlframe1.p_y;
    //ctlframe2.p_height = ctlframe1.p_height;
    //ctlframe2.p_width = ctlframe1.p_width;

    do_xretrace_load_config(&xretrace_config_data, 'xretrace_config' );
    call_config_funcs(CFG_FUNC_SET_PPV_TO_ITV, &xretrace_config_data);
}

  
void xretrace_load_config()
{
   do_xretrace_load_config(&xretrace_config_data, 'xretrace_config' );
}


//void save_button.lbutton_up()
//{
//    xsave_config(&xretrace_config_data, 'xretrace_config' );
//}


void ok_button.lbutton_up()
{
   xsave_config(&xretrace_config_data, 'xretrace_config' );

   int form_id = _find_object('xretrace_form');
   if (form_id != 0) 
      form_id._delete_window('');
}


_command void xretrace_show_control_panel() name_info(',')
{
   show('-XY xretrace_form');
}


void track_demodified_lines_with_line_markers_checkbox.lbutton_up()
{
   xretrace_clear_all_demodified_line_markers();
}


void show_retrace_modified_line_markers_checkbox.lbutton_up()
{
   if (p_value) 
      xretrace_show_mod_bitmaps();
   else
      xretrace_hide_mod_bitmaps();
}


void show_most_recent_modified_line_markers_checkbox.lbutton_up()
{
   if (!p_value) 
      xretrace_hide_mod_bitmaps();
}


void show_retrace_cursor_line_markers_checkbox.lbutton_up()
{
   if (p_value) 
      xretrace_show_cur_bitmaps();
   else
      xretrace_hide_cur_bitmaps();
}


void show_demodified_line_markers_checkbox.lbutton_up()
{
   if (p_value) 
      xretrace_show_demodified_line_markers();
   else
      xretrace_hide_demodified_line_markers();
}


void retrace_delayed_start_checkbox.lbutton_up()
{
   if (p_value) 
      def_xretrace_no_delayed_start = false;
   else
      def_xretrace_no_delayed_start = true;
}


void dump_cursor_retrace_button.lbutton_up()
{
   xretrace_dump_retrace_cursor_list();
}


void dump_mod_lines_button.lbutton_up()
{
   xretrace_dump_modified_lines_list();
}


void disable_button.lbutton_up()
{
   xretrace_disable();
}


void help_button.lbutton_up()
{
   show_xretrace_options_help();
}

//void ctlsstab1.on_change(int reason)
//{
//   xretrace_config_data.show_most_recent_modified_line_markers = 1;
//   if (reason == CHANGE_TABACTIVATED) {
//      switch (p_ActiveTab) {
//         case 0 :
//            ctlframe1.p_visible = true;
//            ctlframe2.p_visible = false;
//            return;
//         case 1 :
//            ctlframe1.p_visible = false;
//            ctlframe2.p_visible = true;
//            return;
//      }
//   }
//
//}



