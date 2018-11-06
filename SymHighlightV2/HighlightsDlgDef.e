////////////////////////////////////////////////////////////////////////////////////
// SymHighlight
// Joe Porkka
// Bssed on the highlight code of MarkSun
////////////////////////////////////////////////////////////////////////////////////
#include 'slick.sh'

_form Highlights {
   p_backcolor=0x80000005;
   p_border_style=BDS_SIZABLE;
   p_caption="Highlights";
   p_forecolor=0x80000008;
   p_height=4260;
   p_width=5820;
   p_x=18690;
   p_y=5880;
   p_eventtab=Highlights;
   _command_button button_Close {
      p_auto_size=false;
      p_cancel=true;
      p_caption='X';
      p_default=false;
      p_height=180;
      p_tab_index=1;
      p_tab_stop=false;
      p_width=975;
      p_x=780;
      p_y=1140;
      p_eventtab=Highlights.ctlcommand1;
   }
   _tree_view ctl_tree {
      p_after_pic_indent_x=50;
      p_backcolor=0x80000005;
      p_border_style=BDS_FIXED_SINGLE;
      p_CheckListBox=true;
      p_ColorEntireLine=true;
      p_EditInPlace=true;
      p_delay=0;
      p_forecolor=0x80000008;
      p_Gridlines=TREE_GRID_BOTH;
      p_height=3960;
      p_LevelIndent=50;
      p_LineStyle=TREE_DOTTED_LINES;
      p_multi_select=MS_NONE;
      p_NeverColorCurrent=false;
      p_ShowRoot=false;
      p_AlwaysColorCurrent=true;
      p_SpaceY=50;
      p_scroll_bars=SB_VERTICAL;
      p_UseFileInfoOverlays=FILE_OVERLAYS_NONE;
      p_tab_index=4;
      p_tab_stop=true;
      p_width=4860;
      p_x=120;
      p_y=120;
      p_eventtab2=_ul2_tree;
   }
   _image ctl_del_button {
      p_auto_size=true;
      p_backcolor=0x80000005;
      p_border_style=BDS_NONE;
      p_forecolor=0x80000008;
      p_height=330;
      p_max_click=MC_SINGLE;
      p_message="Remove the Item Parameter from the List";
      p_Nofstates=1;
      p_picture="bbdelete.svg";
      p_stretch=false;
      p_style=PSPIC_BUTTON;
      p_tab_index=6;
      p_tab_stop=false;
      p_value=0;
      p_width=345;
      p_x=5130;
      p_y=600;
      p_eventtab2=_ul2_imageb;
   }
   _image ctl_new_button {
      p_auto_size=true;
      p_backcolor=0x80000005;
      p_border_style=BDS_NONE;
      p_forecolor=0x80000008;
      p_height=330;
      p_max_click=MC_SINGLE;
      p_message="Add a New Item to the End of the List";
      p_Nofstates=1;
      p_picture="bbadd.svg";
      p_stretch=false;
      p_style=PSPIC_BUTTON;
      p_tab_index=9;
      p_tab_stop=false;
      p_value=0;
      p_width=345;
      p_x=5130;
      p_y=180;
      p_eventtab2=_ul2_imageb;
   }
}

defmain()
{
   _config_modify_flags(CFGMODIFY_RESOURCE);
}
