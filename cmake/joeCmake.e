////////////////////////////////////////////////////////////////////////////////////
#pragma option(pedantic,on)
#region Imports
#include "slick.sh"
#require "se/lang/api/LanguageSettings.e"
#import "stdprocs.e"
#import "c.e"
#endregion

using se.lang.api.LanguageSettings;

int cmake_proc_search(_str &proc_name,int find_first)
{
   int status=0;
   if (find_first) {
      _str name_re='';
      if (proc_name=='') {
         name_re = _clex_identifier_re();
      } else {
         name_re='[a-zA-Z_][a-zA-Z_0-9]*';
      }
      name_re='[a-zA-Z_][a-zA-Z_0-9]*';

      _str searchFun   = '(^(\o:b|)(function(?:[ \t]*))\((?:[ \t]*)(?P<FNAME>'name_re') *.*\))';
      _str searchMacro   = '(^(\o:b|)(macro(?:[ \t]*))\((?:[ \t]*)(?P<MNAME>'name_re') *.*\))';
      _str searchGVar   = '(^(\o:b|)(set(?:[ \t]*))\((?:[ \t]*)(?P<VNAME>'name_re') *.*\))';
      _str searchFor = searchFun '|' searchMacro '|' searchGVar ;
      status=search(searchFor,'UHI@XSC');
   } else {
      status=repeat_search();
   }
   if (length(get_match_text('VNAME')) != 0)
   {
       proc_name=get_match_text('VNAME')'(gvar)';
   }
   else if (length(get_match_text('FNAME')) != 0)
   {
       proc_name=get_match_text('FNAME')'(func)';
   }
   else if (length(get_match_text('MNAME')) != 0)
   {
       proc_name=get_match_text('MNAME')'(func)';
   }
   else
   {
   }
   return(status);
}


