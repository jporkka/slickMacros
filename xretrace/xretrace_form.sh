
#include "slick.sh"
#include "xretrace.sh"


_form xretrace_form {
   p_backcolor=0x80000005;
   p_border_style=BDS_DIALOG_BOX;
   p_caption="Xretrace  V2.12  Control Panel";
   p_forecolor=0x80000008;
   p_height=6412;
   p_width=9744;
   p_x=-11648;
   p_y=4186;
   p_eventtab=xretrace_form;
   _frame ctlframe1 {
      p_backcolor=0x80000005;
      p_caption='';
      p_forecolor=0x80000008;
      p_height=4858;
      p_tab_index=2;
      p_visible=false;
      p_width=4438;
      p_x=182;
      p_y=0;
      _check_box show_retrace_modified_line_markers_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  show retrace modified line markers";
         p_forecolor=0x80000008;
         p_height=306;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=1;
         p_tab_stop=true;
         p_value=0;
         p_width=3287;
         p_x=255;
         p_y=240;
      }
      _check_box show_retrace_cursor_line_markers_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  show retrace cursor line markers";
         p_forecolor=0x80000008;
         p_height=300;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=2;
         p_tab_stop=true;
         p_value=0;
         p_width=2940;
         p_x=255;
         p_y=1120;
      }
      _check_box show_demodified_line_markers_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  show de-modified line markers";
         p_forecolor=0x80000008;
         p_height=300;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=4;
         p_tab_stop=true;
         p_value=0;
         p_width=2700;
         p_x=255;
         p_y=2000;
      }
      _check_box show_most_recent_modified_line_markers_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  show retrace most recent modified line markers";
         p_forecolor=0x80000008;
         p_height=244;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=5;
         p_tab_stop=true;
         p_value=0;
         p_width=4127;
         p_x=255;
         p_y=680;
      }
      _check_box track_demodified_lines_with_line_markers_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  track de-modified lines with line markers";
         p_forecolor=0x80000008;
         p_height=300;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=6;
         p_tab_stop=true;
         p_value=0;
         p_width=3420;
         p_x=255;
         p_y=1560;
      }
      _check_box track_demodified_lines_with_lineflags_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  track de-modified lines with lineflags";
         p_forecolor=0x80000008;
         p_height=300;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=7;
         p_tab_stop=true;
         p_value=0;
         p_width=3120;
         p_x=255;
         p_y=2440;
      }
      _check_box retrace_delayed_start_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  retrace delayed start";
         p_forecolor=0x80000008;
         p_height=300;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=8;
         p_tab_stop=true;
         p_value=0;
         p_width=2220;
         p_x=255;
         p_y=2880;
      }
      _check_box track_modified_lines_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  track modified lines";
         p_forecolor=0x80000008;
         p_height=240;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=9;
         p_tab_stop=true;
         p_value=0;
         p_width=1830;
         p_x=255;
         p_y=3315;
      }
      _check_box capture_retrace_data_to_disk_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption="  capture retrace data to disk";
         p_forecolor=0x80000008;
         p_height=238;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=10;
         p_tab_stop=true;
         p_value=0;
         p_width=3108;
         p_x=252;
         p_y=3738;
      }
      _check_box no_touch_line_modify_flag_checkbox {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_caption='  don''t touch line modify flags';
         p_forecolor=0x80000008;
         p_height=238;
         p_style=PSCH_AUTO2STATE;
         p_tab_index=11;
         p_tab_stop=true;
         p_value=0;
         p_width=3108;
         p_x=252;
         p_y=4172;
      }
   }
   _sstab ctlsstab1 {
      p_FirstActiveTab=0;
      p_backcolor=0x80000005;
      p_DropDownList=false;
      p_forecolor=0x000000FF;
      p_height=315;
      p_NofTabs=2;
      p_Orientation=SSTAB_OBOTTOM;
      p_PictureOnly=false;
      p_tab_index=4;
      p_tab_stop=true;
      p_width=1395;
      p_x=600;
      p_y=7140;
      p_eventtab2=_ul2_sstabb;
      _sstab_container  {
         p_ActiveCaption="Select";
         p_ActiveEnabled=true;
         p_ActiveOrder=0;
         p_ActiveColor=0x00800080;
         p_ActiveToolTip='';
      }
      _sstab_container  {
         p_ActiveCaption="Value";
         p_ActiveEnabled=true;
         p_ActiveOrder=1;
         p_ActiveColor=0x00800080;
         p_ActiveToolTip='';
      }
   }
   _command_button ok_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Save and Close";
      p_default=false;
      p_height=406;
      p_tab_index=5;
      p_tab_stop=true;
      p_width=1260;
      p_x=240;
      p_y=5028;
   }
   _frame ctlframe2 {
      p_backcolor=0x80000005;
      p_caption='';
      p_forecolor=0x80000008;
      p_height=4858;
      p_tab_index=6;
      p_width=4914;
      p_x=4620;
      p_y=0;
      _text_box retrace_cursor_max_history_length_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=1;
         p_tab_stop=true;
         p_text="50";
         p_width=570;
         p_x=238;
         p_y=294;
         p_eventtab2=_ul2_textbox;
      }
      _label ctllabel1 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace cursor max history length";
         p_forecolor=0x80000008;
         p_height=303;
         p_tab_index=2;
         p_width=2835;
         p_word_wrap=false;
         p_x=945;
         p_y=285;
      }
      _text_box retrace_modified_lines_max_history_length_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=3;
         p_tab_stop=true;
         p_text="20";
         p_width=600;
         p_x=238;
         p_y=734;
         p_eventtab2=_ul2_textbox;
      }
      _text_box retrace_timer_interrupt_sampling_interval_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=4;
         p_tab_stop=true;
         p_text="250";
         p_width=600;
         p_x=238;
         p_y=1174;
         p_eventtab2=_ul2_textbox;
      }
      _text_box retrace_cursor_line_distance_recording_granularity_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=5;
         p_tab_stop=true;
         p_text="16";
         p_width=600;
         p_x=238;
         p_y=1614;
         p_eventtab2=_ul2_textbox;
      }
      _text_box retrace_cursor_line_distance_viewing_granularity_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=6;
         p_tab_stop=true;
         p_text="16";
         p_width=600;
         p_x=238;
         p_y=2054;
         p_eventtab2=_ul2_textbox;
      }
      _text_box retrace_cursor_min_region_pause_time_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=7;
         p_tab_stop=true;
         p_text="16";
         p_width=600;
         p_x=238;
         p_y=2494;
         p_eventtab2=_ul2_textbox;
      }
      _text_box retrace_cursor_min_line_pause_time_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=255;
         p_tab_index=8;
         p_tab_stop=true;
         p_text='4';
         p_width=600;
         p_x=238;
         p_y=2934;
         p_eventtab2=_ul2_textbox;
      }
      _label ctllabel2 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace modified lines max history length";
         p_forecolor=0x80000008;
         p_height=246;
         p_tab_index=9;
         p_width=3255;
         p_word_wrap=false;
         p_x=945;
         p_y=727;
      }
      _label ctllabel3 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace timer sampling interval";
         p_forecolor=0x80000008;
         p_height=300;
         p_tab_index=10;
         p_width=2970;
         p_word_wrap=false;
         p_x=945;
         p_y=1169;
      }
      _label ctllabel4 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace cursor line distance recording granularity";
         p_forecolor=0x80000008;
         p_height=245;
         p_tab_index=11;
         p_width=3827;
         p_word_wrap=false;
         p_x=945;
         p_y=1611;
      }
      _label ctllabel5 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace cursor line distance viewing granularity";
         p_forecolor=0x80000008;
         p_height=244;
         p_tab_index=12;
         p_width=3771;
         p_word_wrap=false;
         p_x=945;
         p_y=2053;
      }
      _label ctllabel6 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace cursor min region pause time intervals";
         p_forecolor=0x80000008;
         p_height=298;
         p_tab_index=13;
         p_width=3827;
         p_word_wrap=false;
         p_x=945;
         p_y=2495;
      }
      _label ctllabel7 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="retrace cursor min line pause time";
         p_forecolor=0x80000008;
         p_height=297;
         p_tab_index=14;
         p_width=2987;
         p_word_wrap=false;
         p_x=945;
         p_y=2937;
      }
      _text_box buffer_retrace_cursor_max_items_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=252;
         p_tab_index=15;
         p_tab_stop=true;
         p_text='8';
         p_width=602;
         p_x=238;
         p_y=3374;
         p_eventtab2=_ul2_textbox;
      }
      _label ctllabel8 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="buffer retrace max items";
         p_forecolor=0x80000008;
         p_height=294;
         p_tab_index=16;
         p_width=2492;
         p_word_wrap=false;
         p_x=945;
         p_y=3379;
      }
      _text_box buffer_retrace_modified_max_items_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=252;
         p_tab_index=17;
         p_tab_stop=true;
         p_text='8';
         p_width=602;
         p_x=238;
         p_y=3814;
         p_eventtab2=_ul2_textbox;
      }
      _label ctllabel9 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="buffer retrace max modfied items";
         p_forecolor=0x80000008;
         p_height=295;
         p_tab_index=18;
         p_width=2709;
         p_word_wrap=false;
         p_x=945;
         p_y=3821;
      }
      _text_box buffer_retrace_bookmarks_max_items_textbox {
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_FIXED_SINGLE;
         p_completion=NONE_ARG;
         p_forecolor=0x80000008;
         p_height=252;
         p_tab_index=19;
         p_tab_stop=true;
         p_text="20";
         p_width=602;
         p_x=238;
         p_y=4254;
         p_eventtab2=_ul2_textbox;
      }
      _label ctllabel10 {
         p_alignment=AL_LEFT;
         p_auto_size=false;
         p_backcolor=0x80000005;
         p_border_style=BDS_NONE;
         p_caption="buffer retrace max bookmarks";
         p_forecolor=0x80000008;
         p_height=294;
         p_tab_index=20;
         p_width=2492;
         p_word_wrap=false;
         p_x=945;
         p_y=4263;
      }
   }
   _command_button disable_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Disable xretrace";
      p_default=false;
      p_height=406;
      p_tab_index=7;
      p_tab_stop=true;
      p_width=1344;
      p_x=1666;
      p_y=5026;
   }
   _command_button dump_cursor_retrace_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Dump cursor retrace";
      p_default=false;
      p_height=406;
      p_tab_index=8;
      p_tab_stop=true;
      p_width=1918;
      p_x=6230;
      p_y=5026;
   }
   _command_button dump_mod_lines_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Dump mod lines retrace";
      p_default=false;
      p_height=406;
      p_tab_index=9;
      p_tab_stop=true;
      p_width=1932;
      p_x=6216;
      p_y=5572;
   }
   _command_button help_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Help";
      p_default=false;
      p_height=406;
      p_tab_index=10;
      p_tab_stop=true;
      p_width=1260;
      p_x=238;
      p_y=5586;
   }
   _command_button ctlcommand_reset {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Reset xretrace";
      p_default=false;
      p_height=406;
      p_tab_index=11;
      p_tab_stop=true;
      p_width=1316;
      p_x=3178;
      p_y=5026;
   }
   _command_button ctlcommand_debug {
      p_auto_size=false;
      p_cancel=false;
      p_caption="Toggle debug";
      p_default=false;
      p_height=406;
      p_tab_index=12;
      p_tab_stop=true;
      p_width=1442;
      p_x=4648;
      p_y=5026;
   }
   _command_button error_log_button {
      p_auto_size=false;
      p_cancel=false;
      p_caption="See error log";
      p_default=false;
      p_height=406;
      p_tab_index=13;
      p_tab_stop=true;
      p_width=1344;
      p_x=1680;
      p_y=5586;
   }
}
