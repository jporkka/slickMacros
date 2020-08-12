#pragma option(pedantic,on)
#include "slick.sh"
#import "main.e"
#import "stdprocs.e"

defmain()
{
   configDir := _ConfigPath();
   _maybe_append_filesep(configDir);
   userMacrosDir := configDir :+ "UserMacros";
   if (!isdirectory(userMacrosDir)) {
      mkdir(userMacrosDir);
   }
   _maybe_append_filesep(userMacrosDir);
   xretraceDir := userMacrosDir :+ "xretrace";
   if (!isdirectory(xretraceDir)) {
      mkdir(xretraceDir);
   }
   _maybe_append_filesep(xretraceDir);
   bitmapsDir := xretraceDir :+ "bitmaps";
   if (!isdirectory(bitmapsDir)) {
      mkdir(bitmapsDir);
   }
}

