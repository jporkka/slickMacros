
// xretrace_not_plugin.sh is copied to xretrace.sh by xload_macros.e when the non plugin xretrace is loaded
// XRETRACE_IS_PLUGIN is undefined for non plugin

#define XRETRACE_VERSION '2.0'

#undef XRETRACE_IS_PLUGIN 

#define XRETRACE_PATH _ConfigPath() :+ 'UserMacros' :+ FILESEP :+ 'xretrace' :+ FILESEP

#define XRETRACE_BITMAPS_PATH  XRETRACE_PATH :+ "bitmaps" :+ FILESEP



#define XRETRACE_MODULE_NAME XRETRACE_PATH :+ 'xretrace.e'

#define  XRETRACE_DATA_PATH  'c:/temp'
#define  XRETRACE_USE_SUBFOLDER YES

