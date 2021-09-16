
#include "slick.sh"
#pragma option(strictsemicolons,on)
#pragma option(strict,on)
#pragma option(autodecl,off)
#pragma option(strictparens,on)


#if __VERSION__ < 25
#undef bool
#define bool boolean
#endif



static _str get_key_binding_name(_str keyname)
{
   int index = event2index(name2event(keyname));
   index = eventtab_index(_default_keys, _default_keys, index);
   if (index)
      return translate(name_name(index),'_','-');
   return '';
}


static output_key_binding(_str keyname, bool use_double = false)
{
   _str s = get_key_binding_name(keyname);
   if (s != '')  {
      if (use_double) {
         // use double quotes if the keyname contains a single quote
         _str k = substr(keyname :+ '"= ',1,16);
         insert_line('  "' :+ k :+ s :+ ';');
      }
      else {
         _str k = substr(keyname :+ "\'= ",1,16);
         insert_line("  \'" :+ k :+ s :+ ';');
      }
   }
}


static output_key_family(_str base_key)
{
   bool use_double = base_key == "'";
   output_key_binding(base_key, use_double);
   output_key_binding('S-' :+ base_key, use_double);
   output_key_binding('C-' :+ base_key, use_double);
   output_key_binding('A-' :+ base_key, use_double);
   output_key_binding('C-S-' :+ base_key, use_double);
   output_key_binding('A-S-' :+ base_key, use_double);
   output_key_binding('C-A-' :+ base_key, use_double);
   output_key_binding('C-A-S-' :+ base_key, use_double);
   insert_line('');
}


_command void xkey_bindings_show() name_info(','VSARG2_TEXT_BOX|VSARG2_REQUIRES_EDITORCTL|VSARG2_LINEHEX)
{
   _str fn = _ConfigPath() :+ 'keybindings' FILESEP 'group-keydefs.e';
   if ( !isdirectory(_ConfigPath() :+ 'keybindings') ) {
      mkdir(_ConfigPath() :+ 'keybindings');
   }
   if ( !file_exists(fn) ) {
      if (edit(' +t ' _maybe_quote_filename(fn))) {
         return;
      }
   }
   else
   {
      if (edit(_maybe_quote_filename(fn))) {
         return;
      }
   }
   if (p_buf_name != fn) {
      return;
   }
   delete_all();

   insert_line('');
   insert_line('');

   insert_line('  // ********************  FUNCTION KEYS  ********************');
   insert_line('');

   int k;
   for (k =1; k < 13; ++k) {
      output_key_family('F' :+ k);
   }

   insert_line('  // ********************  NON ALPHA-NUMERIC KEYS  ********************');
   insert_line('');

   output_key_family(' ');
   output_key_family('BACKSPACE');
   output_key_family('UP');
   output_key_family('DOWN');
   output_key_family('LEFT');
   output_key_family('RIGHT');
   output_key_family('ENTER');
   output_key_family('TAB');
   output_key_family('HOME');
   output_key_family('END');
   output_key_family('PGUP');
   output_key_family('PGDN');
   output_key_family('DEL');
   output_key_family('INS');
   output_key_family('[');
   output_key_family(']');
   output_key_family(',');
   output_key_family('.');
   output_key_family('/');
   output_key_family('\');
   output_key_family(';');
   output_key_family("'");
   output_key_family('=');
   output_key_family('-');
   output_key_family('`');
   output_key_family('PAD-PLUS');
   output_key_family('PAD-MINUS');
   output_key_family('PAD-STAR');
   output_key_family('PAD-SLASH');
   output_key_family('PAD5');

   insert_line('  // ********************  LETTERS  ********************');
   insert_line('');
   for (k = 0; k < 26; ++k) {
      output_key_family(_chr(k + 0x41));
   }

   insert_line('  // ********************  NUMBERS  ********************');
   insert_line('');
   for (k = 0; k < 10; ++k) {
      output_key_family(_chr(k + 0x30));
   }

   top();
}


static int kbt_menu_handle;

static add_key_to_menu(_str keyname)
{
   _str s = get_key_binding_name(keyname);
   if (s != '')  {
      _menu_insert(kbt_menu_handle, 0, MF_ENABLED, substr(keyname,1,15) :+ '  ' :+ s, s,"","",s);
   }
}


static generate_key_family_menu(_str base_key)
{
   add_key_to_menu('C-A-S-' :+ base_key);
   add_key_to_menu('C-A-' :+ base_key);
   add_key_to_menu('A-S-' :+ base_key);
   add_key_to_menu('C-S-' :+ base_key);
   add_key_to_menu('A-' :+ base_key);
   add_key_to_menu('C-' :+ base_key);
   add_key_to_menu('S-' :+ base_key);
   add_key_to_menu(base_key);
}


_menu key_binding_trainer_menu {
}


_command void xkey_binding_trainer() name_info(',')
{
   int index=find_index("key_binding_trainer_menu",oi2type(OI_MENU));
   if (!index) {
      return;
   }
   kbt_menu_handle=_menu_load(index,'P');
   message('Press a key');

   _str keyname = event2name(get_event());
   
   generate_key_family_menu(keyname);

   // Show the menu.
   int x = 100;
   int y = 100;
   x = mou_last_x('M')-x;y=mou_last_y('M')-y;
   _lxy2dxy(p_scale_mode,x,y);
   _map_xy(p_window_id,0,x,y,SM_PIXEL);
   int flags=VPM_LEFTALIGN|VPM_RIGHTBUTTON;
   int status=_menu_show(kbt_menu_handle,flags,x,y);
   _menu_destroy(kbt_menu_handle);

   // set the focus back
   if (_mdi.p_child._no_child_windows()==0) {
      _mdi.p_child._set_focus();
   }
}




